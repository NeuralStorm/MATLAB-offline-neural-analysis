function [] = continuous_psth_main()
    %% Get data directory
    project_path = uigetdir(pwd);
    start_time = tic;

    %% Import psth config and removes ignored animals
    config = import_config(project_path, 'continuous_psth');
    config(config.include_dir == 0, :) = [];
    
     %% Creating paths to do analog analysis
    [continuous_psth_path, continuous_failed_path] = create_dir(project_path, 'continuous_psth');
    export_params(continuous_psth_path, 'continuous_psth', config);
    parsed_path = [project_path, '/parsed_continuous'];
    if ~exist(parsed_path, 'dir')
        error('Must have parsed continuous data for analysis');
    end

    dir_list = config.dir_name;
    for dir_i = 1:length(dir_list)
        curr_dir = dir_list{dir_i};
        dir_config = config(dir_i, :);
        dir_config = convert_table_cells(dir_config);
        label_table = load_labels(project_path, [curr_dir, '_labels.csv']);

        if dir_config.filter_data
            [filter_data_path, filter_failed_path] = create_dir(continuous_psth_path, 'filtered_data');
            export_params(filter_data_path, 'filter', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_1 = 'No parsed directory to filter';
                e_msg_2 = ['No ', curr_dir, ' directory to filter'];
                parsed_dir_path = enforce_dir_layout(parsed_path, curr_dir, ...
                    continuous_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(filter_data_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%        Filter data         %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_filter(dir_save_path, dir_failed_path, parsed_dir_path, curr_dir, dir_config, label_table);
            catch ME
                handle_ME(ME, filter_failed_path, [curr_dir, '_failed.mat']);
            end
        end
        
        
        if dir_config.extract_spikes
           [spikes_data_path, spikes_failed_path] = create_dir(continuous_psth_path, 'spikes');
            export_params(spikes_data_path, 'spikes', config);
            
                if dir_config.use_raw
                    parsed_path = [project_path, '/parsed_continuous'];
%                     sep_input_path = enforce_dir_layout(parsed_path, curr_dir, ...
%                         continuous_failed_path, e_msg_1, e_msg_2);
                else
                    filter_path = [continuous_psth_path, '/filtered_data'];
%                     sep_input_path = enforce_dir_layout(filter_path, curr_dir, ...
%                         continuous_failed_path, e_msg_1, e_msg_2);
                end
            
            batch_continuous_extract_format_spikes(spikes_data_path, spikes_failed_path, ...
                filter_path, curr_dir, dir_config, label_table); 
        end
    
        
        if strcmpi(dir_config.psth_type, 'psth')
            %% Creating paths to do psth formatting
            csv_modifier = 'psth';
            [psth_path, psth_failed_path] = create_dir(project_path, 'psth');
            [data_path, ~] = create_dir(psth_path, 'data');
            export_params(data_path, csv_modifier, config);
            if dir_config.create_psth
                try
                    %% Check to make sure paths exist for analysis and create save path
                    parsed_path = [project_path, '/parsed_spike'];
                    e_msg_1 = 'No parsed directory to create PSTHs';
                    e_msg_2 = ['No ', curr_dir, ' directory to create PSTHs'];
                    parsed_dir_path = enforce_dir_layout(parsed_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);
                    [dir_save_path, dir_failed_path] = create_dir(data_path, curr_dir);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%        Format PSTH         %%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    batch_format_psth(dir_save_path, dir_failed_path, parsed_dir_path, curr_dir, dir_config, label_table);
                catch ME
                    handle_ME(ME, psth_failed_path, [curr_dir, '_missing_dir.mat']);
                end
            else
                if ~exist(psth_path, 'dir') || ~exist(data_path, 'dir')
                    error('Must have PSTHs to run PSTH analysis on %s', curr_dir);
                end
            end
        elseif strcmpi(dir_config.psth_type, 'pca')
            csv_modifier = 'pca';
            psth_path = [project_path, '/pca_psth'];
            data_path = [psth_path, '/data'];
            if ~exist(psth_path, 'dir') || ~exist(data_path, 'dir')
                error('Must have PSTHs to run PSTH analysis on %s', curr_dir);
            end
        elseif strcmpi(dir_config.psth_type, 'ica')
            csv_modifier = 'ica';
            psth_path = [project_path, '/ica_psth'];
            data_path = [psth_path, '/data'];
            if ~exist(psth_path, 'dir') || ~exist(data_path, 'dir')
                error('Must have PSTHs to run PSTH analysis on %s', curr_dir);
            end
        else
            error('Invalid psth type %s, must be psth, pca, or ica', dir_config.psth_type);
        end

        e_msg_1 = 'No data directory to find PSTHs';
        if config.rf_analysis
            [recfield_path, recfield_failed_path] = create_dir(psth_path, 'recfield');
            export_params(recfield_path, 'rec_field', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_2 = ['No ', curr_dir, ' psth data for receptive field analysis'];
                dir_psth_path = enforce_dir_layout(data_path, curr_dir, recfield_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(recfield_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%  Receptive Field Analysis  %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_recfield(project_path, dir_save_path, dir_failed_path, ...
                    dir_psth_path, curr_dir, csv_modifier, dir_config);
            catch ME
                handle_ME(ME, recfield_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        if config.make_psth_graphs
            [graph_path, graph_failed_path] = create_dir(psth_path, 'psth_graphs');
            export_params(graph_path, 'psth_graph', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_2 = ['No ', curr_dir, ' psth data for graphing'];
                dir_psth_path = enforce_dir_layout(data_path, curr_dir, graph_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(graph_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%         Graph PSTH         %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                rf_path = [psth_path, '/recfield/', curr_dir];
                batch_graph_psth(dir_save_path, dir_failed_path, dir_psth_path, curr_dir, dir_config, rf_path)
            catch ME
                handle_ME(ME, graph_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        if config.psth_classify
            [classifier_path, classifier_failed_path] = create_dir(psth_path, 'classifier');
            export_params(classifier_path, 'classifier', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_2 = ['No ', curr_dir, ' psth data for classifier analysis'];
                dir_psth_path = enforce_dir_layout(data_path, curr_dir, classifier_failed_path, e_msg_1, e_msg_2);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%     PSTH Classification    %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [dir_save_path, dir_failed_path] = create_dir(classifier_path, curr_dir);
                batch_classify(project_path, dir_save_path, dir_failed_path, ...
                    dir_psth_path, curr_dir, csv_modifier, dir_config)
            catch ME
                handle_ME(ME, classifier_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        if config.nv_analysis
            [nv_path, nv_failed_path] = create_dir(psth_path, 'norm_var');
            export_params(nv_path, 'nv_analysis', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_2 = ['No ', curr_dir, ' to perform normalized variance analysis'];
                dir_psth_path = enforce_dir_layout(data_path, curr_dir, nv_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(nv_path, curr_dir);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%     Normalized Variance    %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_nv(project_path, dir_save_path, dir_failed_path, ...
                    dir_psth_path, curr_dir, csv_modifier, dir_config);
            catch ME
                handle_ME(ME, nv_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        if config.info_analysis
            [info_path, info_failed_path] = create_dir(psth_path, 'mutual_info');
            export_params(info_path, 'mutual_info', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_2 = ['No ', curr_dir, ' to perform info analysis'];
                dir_psth_path = enforce_dir_layout(data_path, curr_dir, info_failed_path, e_msg_1, e_msg_2);

                [dir_save_path, dir_failed_path] = create_dir(info_path, curr_dir);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%   Information Analysis    %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_info(dir_save_path, dir_failed_path, dir_psth_path, curr_dir, dir_config)
            catch ME
                handle_ME(ME, info_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end
    end
    toc(start_time);
end