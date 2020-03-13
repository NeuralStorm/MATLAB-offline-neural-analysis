function [] = psth_main()
    %TODO add log to all files
    %% Get data directory
    project_path = uigetdir(pwd);
    start_time = tic;

    %% Import psth config and removes ignored animals
    config = import_config(project_path, 'psth');
    config(config.include_animal == 0, :) = [];

    %% Creating paths to do psth formatting
    [psth_path, psth_failed_path] = create_dir(project_path, 'psth');
    [data_path, ~] = create_dir(psth_path, 'data');

    dir_list = config.dir_name;
    for dir_i = 1:length(dir_list)
        curr_dir = dir_list{dir_i};
        dir_config = config(dir_i, :);
        %% load label table
        label_table = load_labels(project_path, [curr_dir, '_labels.csv']);

        if dir_config.create_psth
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%        Format PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Checking folders
            try
                parsed_path = [project_path, '/parsed'];
                e_msg_1 = 'No parsed directory to create PSTHs';
                e_msg_2 = ['No ', curr_dir, ' directory to create PSTHs'];
                dir_psth_path = enforce_dir_layout(parsed_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);

                [dir_save_path, dir_failed_path] = create_dir(data_path, curr_dir);
                %% Create psth
                batch_format_psth(dir_save_path, dir_failed_path, dir_psth_path, curr_dir, dir_config, label_table);
            catch ME
                handle_ME(ME, psth_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        else
            if ~exist(psth_path, 'dir')
                error('Mut have PSTHs to run PSTH analysis on %s', curr_dir);
            end
            if ~exist(data_path, 'dir')
                error('Mut have PSTHs to run PSTH analysis on %s', curr_dir);
            end
        end

        if config.rf_analysis
            e_msg_1 = 'No data directory to find PSTHs';
            e_msg_2 = ['No ', curr_dir, ' psth data for receptive field analysis'];
            dir_psth_path = enforce_dir_layout(data_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);

            [recfield_path, recfield_failed_path] = create_dir(psth_path, 'recfield');
            [dir_save_path, dir_failed_path] = create_dir(recfield_path, curr_dir);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            batch_recfield(project_path, dir_save_path, dir_failed_path, ...
                dir_psth_path, curr_dir, 'psth', dir_config);
        end


        if config.make_psth_graphs
            e_msg_1 = 'No data directory to find PSTHs';
            e_msg_2 = ['No ', curr_dir, ' psth data for graphing'];
            dir_psth_path = enforce_dir_layout(data_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);
            [graph_path, graph_failed_path] = create_dir(psth_path, 'psth_graphs');
            [dir_save_path, dir_failed_path] = create_dir(graph_path, curr_dir);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            rf_path = [psth_path, '/recfield/', curr_dir];
            batch_graph(dir_save_path, dir_failed_path, dir_psth_path, curr_dir, dir_config, rf_path)
        end

        if config.psth_classify
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            e_msg_1 = 'No data directory to find PSTHs';
            e_msg_2 = ['No ', curr_dir, ' psth data for classifier analysis'];
            dir_psth_path = enforce_dir_layout(data_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);

            [classifier_path, classifier_failed_path] = create_dir(psth_path, 'classifier');
            [dir_save_path, dir_failed_path] = create_dir(classifier_path, curr_dir);
            batch_classify(project_path, dir_save_path, dir_failed_path, ...
                dir_psth_path, curr_dir, 'classifier', dir_config)
        end

        if config.nv_analysis
            e_msg_1 = 'No data directory to find PSTHs';
            e_msg_2 = ['No ', curr_dir, ' to perform normalized variance analysis'];
            dir_psth_path = enforce_dir_layout(data_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);

            [nv_path, nv_failed_path] = create_dir(psth_path, 'normalized_variance');
            [dir_save_path, dir_failed_path] = create_dir(nv_path, curr_dir);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     Normalized Variance    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            batch_nv(project_path, dir_save_path, dir_failed_path, ...
                dir_psth_path, curr_dir, 'norm_var_analysis', dir_config);
        end


        if config.info_analysis
            e_msg_1 = 'No data directory to find PSTHs';
            e_msg_2 = ['No ', curr_dir, ' to perform info analysis'];
            dir_psth_path = enforce_dir_layout(data_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);

            [info_path, info_failed_path] = create_dir(psth_path, 'mutual_info');
            [dir_save_path, dir_failed_path] = create_dir(info_path, curr_dir);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            batch_info(dir_save_path, dir_failed_path, dir_psth_path, curr_dir, dir_config)
        end

    end
    toc(start_time);
end