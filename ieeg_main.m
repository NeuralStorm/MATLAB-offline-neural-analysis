function [] = ieeg_main()
    %% Get data directory
    project_path = uigetdir(pwd);
    start_time = tic;

    %% Import psth config and removes ignored animals
    config = import_config(project_path, 'ieeg');
    config(config.include_dir == 0, :) = [];

    [raw_path, raw_failed_path] = create_dir(project_path, 'raw');
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
                headers = {'sig_channels', 'selected_channels', ...
                    'user_channels', 'label', 'label_id', ...
                    'recording_session', 'recording_notes'};
                var_types = {'cell', 'double', 'cell', 'cell', 'double', ...
                    'double', 'cell'};
                label_table = table('Size', [0, length(headers)], 'VariableTypes', ...
                    var_types, 'VariableNames', headers);
            end

            %% Check for raw path for current directory
            e_msg_1 = 'No raw directory to make labels';
            e_msg_2 = ['No ', curr_dir, ' directory to create labels'];
            raw_dir_path = enforce_dir_layout(raw_path, curr_dir, ...
                raw_failed_path, e_msg_1, e_msg_2);
            %% Call batch labeller to make labels
            batch_create_labels(raw_dir_path, raw_failed_path, labels_path, ...
                label_table, dir_config);
        end

        %% Load labels file to start analysis
        label_table = load_labels(project_path, [curr_dir, '_labels.csv']);

        if dir_config.create_mnts
            try
                [mnts_path, mnts_failed_path] = create_dir(project_path, 'mnts');
                [data_path, ~] = create_dir(mnts_path, 'mnts_data');
                %% Check to make sure paths exist for analysis and create save path
                e_msg_1 = 'No raw directory to make mnts';
                e_msg_2 = ['No ', curr_dir, ' directory to create mnts'];
                raw_dir_path = enforce_dir_layout(raw_path, curr_dir, ...
                    raw_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(data_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%        Format MNTS         %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_reshape_to_mnts(dir_save_path, dir_failed_path, ...
                    raw_dir_path, curr_dir, dir_config, label_table);
            catch ME
                handle_ME(ME, mnts_failed_path, [curr_dir, '_missing_dir.mat']);
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
                batch_power_pca(dir_save_path, dir_failed_path, dir_mnts_path, ...
                    curr_dir, dir_config)
            catch ME
                handle_ME(ME, mnts_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        if config.make_pca_plots
            [graph_path, graph_failed_path] = create_dir(mnts_path, 'pca_graphs');
            export_params(graph_path, 'pca_graph', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_1 = 'No data directory to find PCAs';
                e_msg_2 = ['No ', curr_dir, ' pca data for graphing'];
                pca_path = [mnts_path, '/pca'];
                dir_pca_path = enforce_dir_layout(pca_path, curr_dir, graph_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(graph_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%      Graph PCA Weights     %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_plot_pca_weights(dir_save_path, dir_failed_path, dir_pca_path, curr_dir, dir_config)
            catch ME
                handle_ME(ME, graph_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        e_msg_1 = 'No data directory to find PCA MNTSs';
        if dir_config.convert_mnts_psth
            [pca_psth_path, pca_psth_failed_path] = create_dir(project_path, 'pca_psth');
            export_params(pca_psth_path, 'pca_psth', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_2 = ['No ', curr_dir, ' pca mnts data to convert to mnts'];
                pca_path = [mnts_path, '/pca'];
                dir_pca_path = enforce_dir_layout(pca_path, curr_dir, pca_psth_failed_path, e_msg_1, e_msg_2);
                [pca_data_path, ~] = create_dir(pca_psth_path, 'data');
                [dir_save_path, dir_failed_path] = create_dir(pca_data_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %          PCA PSTH          %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_power_mnts_to_psth(dir_save_path, dir_failed_path, dir_pca_path, ...
                    curr_dir, 'pca', dir_config)
            catch ME
                handle_ME(ME, pca_psth_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        if config.make_psth_graphs
            [graph_path, graph_failed_path] = create_dir(pca_psth_path, 'psth_graphs');
            export_params(graph_path, 'psth_graph', config);
            data_path = [pca_psth_path, '/data'];
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_1 = 'No data directory to find PCA PSTH';
                e_msg_2 = ['No ', curr_dir, ' psth data for graphing'];
                dir_psth_path = enforce_dir_layout(data_path, curr_dir, ...
                    graph_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(graph_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%         Graph PSTH         %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_power_graph_psth(dir_save_path, dir_failed_path, ...
                    dir_psth_path, curr_dir, dir_config)
            catch ME
                handle_ME(ME, graph_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        if config.make_tfr_pca_psth
            [graph_path, graph_failed_path] = create_dir(project_path, 'tfr_pca_psth');
            export_params(graph_path, 'tfr_pca_psth', config);
            pca_path = [project_path, '/mnts/pca'];
            psth_path = [project_path, '/pca_psth/data'];
            tfr_path = [project_path, '/tfr_plots'];
            try
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
                %%         Graph PSTH         %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_plot_tfr_pca_psth(dir_save_path, dir_failed_path, ...
                    dir_tfr_path, dir_pca_path, dir_psth_path, dir_config);
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
                %TODO option to use pca or raw
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