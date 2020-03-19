function [] = psth_main()
    %% Get data directory
    project_path = uigetdir(pwd);
    start_time = tic;

    %% Import psth config and removes ignored animals
    config = import_config(project_path, 'psth');
    config(config.include_dir == 0, :) = [];

    %% Creating paths to do psth formatting
    [psth_path, psth_failed_path] = create_dir(project_path, 'psth');
    [data_path, ~] = create_dir(psth_path, 'data');
    export_params(data_path, 'psth', config);

    dir_list = config.dir_name;
    for dir_i = 1:length(dir_list)
        curr_dir = dir_list{dir_i};
        dir_config = config(dir_i, :);
        label_table = load_labels(project_path, [curr_dir, '_labels.csv']);

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

        e_msg_1 = 'No data directory to find PSTHs';
        if config.rf_analysis
            [recfield_path, recfield_failed_path] = create_dir(psth_path, 'recfield');
            export_params(recfield_path, 'rec_field', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_2 = ['No ', curr_dir, ' psth data for receptive field analysis'];
                dir_psth_path = enforce_dir_layout(data_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(recfield_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%  Receptive Field Analysis  %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_recfield(project_path, dir_save_path, dir_failed_path, ...
                    dir_psth_path, curr_dir, 'psth', dir_config);
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
                dir_psth_path = enforce_dir_layout(data_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(graph_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%         Graph PSTH         %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                rf_path = [psth_path, '/recfield/', curr_dir];
                batch_graph(dir_save_path, dir_failed_path, dir_psth_path, curr_dir, dir_config, rf_path)
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
                dir_psth_path = enforce_dir_layout(data_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%     PSTH Classification    %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [dir_save_path, dir_failed_path] = create_dir(classifier_path, curr_dir);
                batch_classify(project_path, dir_save_path, dir_failed_path, ...
                    dir_psth_path, curr_dir, 'psth', dir_config)
            catch ME
                handle_ME(ME, classifier_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        if config.nv_analysis
            [nv_path, nv_failed_path] = create_dir(psth_path, 'normalized_variance');
            export_params(nv_path, 'nv_analysis', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_2 = ['No ', curr_dir, ' to perform normalized variance analysis'];
                dir_psth_path = enforce_dir_layout(data_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(nv_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%     Normalized Variance    %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_nv(project_path, dir_save_path, dir_failed_path, ...
                    dir_psth_path, curr_dir, 'psth', dir_config);
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
                dir_psth_path = enforce_dir_layout(data_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);

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