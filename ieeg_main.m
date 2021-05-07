function [] = ieeg_main(varargin)

    %% Purpose: Run through batch analysis for subjects
    % Current analysis flow:
    %                       1. create labels csv
    %                       2. format TFR into MNTS
    %                          tfr = time frequency representation, mnts = multineuron time series
    %                       3. PCA (principal component analysis)
    %                       3a. Plotting of PCA weights
    %                       4. PCA MNTS into PSTH (psth = peri-stimulus time histogram)
    %                       4a. Plot PCA PSTH
    %                       5. Visualization of data (tfr, pca % var, electrode weighting, psth)
    %                       6. lds (in the works)
    %% Input:
    % While there is no input, it expects a certain file layout + config csv
    % File layout:
    %              project_dir:
    %                          pre_processed:
    %                                        subject_dirs
    % config: filename: ieeg_config.csv
    % Rows: 1 row per subject
    % Columns:
    %          dir_name: String: Name of directory with data
    %          include_dir: Boolean: To include directory in pipeline
    %          include_sessions: "Numeric Array: List of numbers that correlate to file and if to use the file or not. 
    %          If array is left empty, it will take all files"
    %          make_labels: Boolean: Create labels with electrodes for each file included in pipeline
    %          create_mnts: Boolean: Create MNTS format from the pre-processed data
    %          select_features: "String: Controls the powers and chan_group used to create the MNTS
    %          Format: power+power:chan_group+chan_group,power:chan_group,etc.
    %          If empty it will powers (m) and chan_group (n) and run pca on all for m * n times"
    %          do_pca: Boolean: Controls if pca is ran on the MNTS with features defined in select features
    %          use_z_mnts: Boolean: Controls if z scored MNTS is used as input to PCA
    %          feature_filter: "String: Controls output of PCA. 
    %                           'all': Use all PCs
    %                           'pcs': Set specific # of pcs to use set in feature value
    %                           'percent_var': use min components required to meet x% set in feature value"
    %          feature_value: "all': empty
    %                         'pcs': int (ex: 3)
    %                         'percent_var': int/float (ex 30 for 30% or 0.3)"
    %          make_pca_plots: Boolean: Controls if plots with pca weights is created for each filter
    %          sub_rows: Int: Number of rows used for subplot (used in all plot functions)
    %          sub_columns: Int: Number of columns used for subplot (used in all plot functions)
    %          ymax_scale: Float: Scalar that scales maximum on plots
    %          convert_mnts_psth: Boolean: Controls if PCA output is converted to PSTH format to create time course plots
    %          bin_size: Float: Size of bin
    %          window_start: Float: left window edge
    %          window_shift_time: Float: Transition between pre and post window
    %          window_end: Float: right window edge
    %          baseline_start: Float: left baseline edge
    %          baseline_end: Float: right baseline edge
    %          response_start: Float: left response edge
    %          response_end: Float: right response edge
    %          make_psth_graphs: Boolean: Controls if time course PCA PSTH plots are made
    %          make_tfr_pca_psth: Boolean: Controls if subplot with TFRS, PCA weights, and time courses is made
    %          plot_avg_pow: Boolean: Controls if TFR avg is plotted on separate y axis with time course
    %          st_type: String: Controls if std or ste is used for shading in time course
    %                   'std': standard deviation
    %                   'ste': standard error"
    %          transparency: Float: Controls how transparent st is around time course
    %          min_components: Int: Min num of components required in file to plot
    %          do_lds: Boolean: Controls if preliminary lds code is used to create state space
    %          latent_variables: Int: How many desired latent variables should be found
    %          em_cycles: Int: Max cycles allowed when look for convergence of paramters for lds
    %          tolerance: Float: tolerance of change (ex: if it bottoms out in a local min)
    %          make_brain_plots: boolean: 1: create 3D brain mesh, 0: skip plotting
    %          is_pial: boolean: 1: use .pial files to get mesh, 0: use .mat from fieldtrip to create mesh
    %          save_png: boolean: 1: save png of brain mesh subplot (very slow) 0: only save subplot as fig
    %          make_corr_plots: Boolean: 1: create pca correlation plots and heatmap of r^2 from line of best fit
    %          subplot_shrinking: FLoat: controls how much the subplots are shrunk to prevent overlap of labels (rec.: 0.02)
    %          corr_components: Int: controls how many components to make the correlation plots for
    %          legend_loc: String: Matlab location specification for legend. See Matlab's documentation for possible legend locations
    %          num_pools: Int: Ideal number of pools to run parallel process

    %% Get data directory
    project_path = get_project_path(varargin);
    start_time = tic;

    %% Import psth config and removes ignored animals
    config = import_config(project_path, 'ieeg');
    config(config.include_dir == 0, :) = [];

    delete(gcp('nocreate'));
    parpool(config.num_pools(1));

    [pre_processed_path, pre_processed_failed_path] = create_dir(project_path, 'pre_processed');
    dir_list = config.dir_name;
    for dir_i = 1:length(dir_list)
        curr_dir = dir_list{dir_i};
        dir_config = config(dir_i, :);
        dir_config = convert_table_cells(dir_config);

        if dir_config.make_labels
            %% Set up labels
            labels_path = [project_path, '/', curr_dir, '_labels.csv'];
            if exist(labels_path)
                label_table = load_labels(project_path, [curr_dir, '_labels.csv']);
            else
                headers = {'channel', 'selected_channels', ...
                    'user_channels', 'chan_group', 'chan_group_id', ...
                    'recording_session', 'recording_notes'};
                var_types = {'cell', 'double', 'cell', 'cell', 'double', ...
                    'double', 'cell'};
                label_table = table('Size', [0, length(headers)], 'VariableTypes', ...
                    var_types, 'VariableNames', headers);
            end

            %% Check for pre_processed path for current directory
            e_msg_1 = 'No pre_processed directory to make labels';
            e_msg_2 = ['No ', curr_dir, ' directory to create labels'];
            pre_processed_dir_path = enforce_dir_layout(pre_processed_path, curr_dir, ...
                pre_processed_failed_path, e_msg_1, e_msg_2);
            %% Call batch labeller to make labels
            batch_create_labels(pre_processed_dir_path, pre_processed_failed_path, labels_path, ...
                label_table, dir_config);
        end

        %% Load labels file to start analysis
        label_table = load_labels(project_path, [curr_dir, '_labels.csv']);

        if dir_config.create_mnts
            try
                [mnts_path, mnts_failed_path] = create_dir(project_path, 'mnts');
                [data_path, ~] = create_dir(mnts_path, 'mnts_data');
                %% Check to make sure paths exist for analysis and create save path
                e_msg_1 = 'No pre_processed directory to make mnts';
                e_msg_2 = ['No ', curr_dir, ' directory to create mnts'];
                pre_processed_dir_path = enforce_dir_layout(pre_processed_path, curr_dir, ...
                    pre_processed_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(data_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%        Format MNTS         %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_reshape_to_mnts(dir_save_path, dir_failed_path, ...
                    pre_processed_dir_path, curr_dir, dir_config, label_table);

                %TODO fix baseline and response windows
                if dir_config.downsample_pow
                    dir_config.bin_size = dir_config.downsample_bin;
                    dir_config.window_start = dir_config.down_start;
                    dir_config.window_end = dir_config.down_end;
                end
                if dir_config.slice_time
                    dir_config.window_start = dir_config.slice_start;
                    dir_config.window_end = dir_config.slice_end;
                    dir_config.window_shift_time = dir_config.down_shift;
                end
            catch ME
                handle_ME(ME, mnts_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        else
            [mnts_path, mnts_failed_path] = create_dir(project_path, 'mnts');
            [data_path, ~] = create_dir(mnts_path, 'mnts_data');
            if dir_config.downsample_pow
                dir_config.bin_size = dir_config.downsample_bin;
            end
            if dir_config.slice_time
                dir_config.window_start = dir_config.slice_start;
                dir_config.window_end = dir_config.slice_end;
                dir_config.window_shift_time = 0;
            end
        end

        if dir_config.do_pca %TODO change to pc_analysis
            try
                [pca_path, pca_failed_path] = create_dir(mnts_path, 'pca');
                %% Check to make sure paths exist for analysis and create save path
                e_msg_1 = 'No data directory to find MNTSs';
                e_msg_2 = ['No ', curr_dir, ' mnts data for pca'];
                dir_mnts_path = enforce_dir_layout(data_path, curr_dir, mnts_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(pca_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             PCA            %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_pca(dir_save_path, dir_failed_path, dir_mnts_path, ...
                    curr_dir, dir_config)
            catch ME
                handle_ME(ME, mnts_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        e_msg_1 = 'No data directory to find MNTSs';
        if dir_config.convert_mnts_psth
            mnts_path = [project_path, '/mnts'];
            if dir_config.use_mnts
                [psth_path, psth_failed_path] = create_dir(project_path, 'psth');
                export_params(psth_path, 'psth', config);
                file_modifier = 'psth';
                data_path = [mnts_path, '/mnts_data'];
            else
                [psth_path, psth_failed_path] = create_dir(project_path, 'pca_psth');
                export_params(psth_path, 'pca_psth', config);
                file_modifier = 'pca';
                data_path = [mnts_path, '/pca'];
            end
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_2 = ['No ', curr_dir, ' mnts data to convert to mnts'];
                dir_mnts_path = enforce_dir_layout(data_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);
                [psth_data_path, ~] = create_dir(psth_path, 'data');
                [dir_save_path, dir_failed_path] = create_dir(psth_data_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %          PCA PSTH          %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_mnts_to_psth(dir_save_path, dir_failed_path, dir_mnts_path, ...
                    curr_dir, file_modifier, dir_config)
            catch ME
                handle_ME(ME, psth_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        if dir_config.make_tfr_pca_psth
            [graph_path, graph_failed_path] = create_dir(project_path, 'tfr_pca_psth');
            export_params(graph_path, 'tfr_pca_psth', config);
            pca_path = [project_path, '/mnts/pca'];
            psth_path = [project_path, '/pca_psth/data'];
            tfr_path = [project_path, '/tfr_plots'];
            mnts_path = [project_path, '/mnts/mnts_data'];
            try
                %% PCA weight path
                e_msg_1 = 'No data directory to find pre processed mnts';
                e_msg_2 = ['No ', curr_dir, ' pre processed mnts for graphing'];
                dir_mnts_path = enforce_dir_layout(mnts_path, curr_dir, ...
                    graph_failed_path, e_msg_1, e_msg_2);

                %% PCA weight path
                e_msg_1 = 'No data directory to find PCAs';
                e_msg_2 = ['No ', curr_dir, ' pca data for graphing'];
                dir_pca_path = enforce_dir_layout(pca_path, curr_dir, ...
                    graph_failed_path, e_msg_1, e_msg_2);

                %% PCA PSTH path
                e_msg_1 = 'No data directory to find PCA PSTH';
                e_msg_2 = ['No ', curr_dir, ' psth data for graphing'];
                dir_psth_path = enforce_dir_layout(psth_path, curr_dir, ...
                    graph_failed_path, e_msg_1, e_msg_2);

                %% tfr path
                e_msg_1 = 'No TFR plot directory to find TFRs';
                e_msg_2 = ['No ', curr_dir, ' TFR plots'];
                dir_tfr_path = enforce_dir_layout(tfr_path, curr_dir, ...
                    graph_failed_path, e_msg_1, e_msg_2);

                [dir_save_path, dir_failed_path] = create_dir(graph_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%     Graph TFR/PCA/PSTH     %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_plot_tfr_pca_psth(curr_dir, dir_save_path, dir_failed_path, ...
                    dir_tfr_path, dir_mnts_path, dir_pca_path, dir_psth_path, dir_config);
            catch ME
                handle_ME(ME, graph_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        if dir_config.make_brain_plots
            mnts_path = [project_path, '/mnts'];
            [graph_path, graph_failed_path] = create_dir(mnts_path, 'pca_mesh_plots');
            export_params(graph_path, 'brain_pca', config);
            pca_path = [mnts_path, '/pca'];
            mesh_path = [project_path, '/meshes'];
            try
                %% PCA weight path
                e_msg_1 = 'No data directory to find PCAs';
                e_msg_2 = ['No ', curr_dir, ' pca data for graphing'];
                dir_pca_path = enforce_dir_layout(pca_path, curr_dir, ...
                    graph_failed_path, e_msg_1, e_msg_2);

                %% tfr path
                e_msg_1 = 'No recon plot directory to find recons';
                e_msg_2 = ['No ', curr_dir, ' TFR plots'];
                dir_elec_path = enforce_dir_layout(mesh_path, curr_dir, ...
                    graph_failed_path, e_msg_1, e_msg_2);

                [dir_save_path, dir_failed_path] = create_dir(graph_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%      Graph brain mesh      %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %! Figure out how to store .pial files
                batch_brain_weights(curr_dir, dir_save_path, dir_failed_path, ...
                    dir_elec_path, mesh_path, dir_pca_path, dir_config);
            catch ME
                handle_ME(ME, graph_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        if dir_config.make_corr_plots
            mnts_path = [project_path, '/mnts'];
            [graph_path, graph_failed_path] = create_dir(mnts_path, 'corr_plots');
            % export_params(graph_path, 'brain_pca', config);
            pca_path = [project_path, '/mnts/pca'];
            try
                %% PCA weight path
                e_msg_1 = 'No data directory to find PCAs';
                e_msg_2 = ['No ', curr_dir, ' pca data for graphing'];
                dir_pca_path = enforce_dir_layout(pca_path, curr_dir, ...
                    graph_failed_path, e_msg_1, e_msg_2);

                [dir_save_path, dir_failed_path] = create_dir(graph_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%         Graph Corr         %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_plot_corr(project_path, curr_dir, dir_save_path, dir_failed_path, ...
                    dir_pca_path, dir_config);
            catch ME
                handle_ME(ME, graph_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        if dir_config.do_lds
            mnts_path = [project_path, '/mnts'];
            [lds_path, lds_failed_path] = create_dir(mnts_path, 'lds');
            export_params(lds_path, 'lds', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_1 = 'No data directory to find PCA MNTSs';
                e_msg_2 = ['No ', curr_dir, ' pca mnts data to create lds'];
                %TODO option to use pca or pre_processed
                pca_path = [mnts_path, '/pca'];
                dir_pca_path = enforce_dir_layout(pca_path, curr_dir, pca_psth_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(lds_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%            LDS            %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_run_lds(dir_save_path, dir_failed_path, dir_pca_path, ...
                    curr_dir, dir_config)
            catch ME
                handle_ME(ME, pca_psth_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end
    end
    toc(start_time);
end