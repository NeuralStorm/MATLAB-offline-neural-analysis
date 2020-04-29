function [] = mnts_main()

    %% Get data directory
    project_path = uigetdir(pwd);
    start_time = tic;

    %% Import psth config and removes ignored animals
    config = import_config(project_path, 'mnts');
    config(config.include_dir == 0, :) = [];

    %% Creating paths to do psth formatting
    [mnts_path, mnts_failed_path] = create_dir(project_path, 'mnts');
    [data_path, ~] = create_dir(mnts_path, 'data');
    export_params(data_path, 'mnts', config);

    dir_list = config.dir_name;
    for dir_i = 1:length(dir_list)
        curr_dir = dir_list{dir_i};
        dir_config = config(dir_i, :);
        dir_config = convert_table_cells(dir_config);
        label_table = load_labels(project_path, [curr_dir, '_labels.csv']);

        if dir_config.create_mnts
            try
                %% Check to make sure paths exist for analysis and create save path
                parsed_path = [project_path, '/parsed_spike'];
                e_msg_1 = 'No parsed_spike directory to create MNTSs';
                e_msg_2 = ['No ', curr_dir, ' directory to create MNTSs'];
                parsed_dir_path = enforce_dir_layout(parsed_path, curr_dir, ...
                    mnts_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(data_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%        Format MNTS         %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_format_mnts(dir_save_path, dir_failed_path, ...
                    parsed_dir_path, curr_dir, dir_config, label_table);
            catch ME
                handle_ME(ME, mnts_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        else
            if ~exist(mnts_path, 'dir') || ~exist(data_path, 'dir')
                error('Must have MNTSs to run MNTS analysis on %s', curr_dir);
            end
        end

        e_msg_1 = 'No data directory to find MNTSs';
        if dir_config.pc_analysis
            [pca_path, pca_failed_path] = create_dir(mnts_path, 'pca');
            export_params(pca_path, 'pca', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_2 = ['No ', curr_dir, ' mnts data for pca'];
                dir_mnts_path = enforce_dir_layout(data_path, curr_dir, mnts_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(pca_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             PCA            %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_pca(dir_save_path, dir_failed_path, dir_mnts_path, ...
                    curr_dir, dir_config)
            catch ME
                handle_ME(ME, pca_failed_path, [curr_dir, '_missing_dir.mat']);
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
                batch_mnts_to_psth(dir_save_path, dir_failed_path, dir_pca_path, ...
                    curr_dir, 'pca', dir_config)
            catch ME
                handle_ME(ME, pca_psth_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        e_msg_1 = 'No data directory to find MNTSs';
        if dir_config.ic_analysis
            [ica_path, ica_failed_path] = create_dir(mnts_path, 'ica');
            export_params(ica_path, 'ica', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_2 = ['No ', curr_dir, ' mnts data for ica'];
                dir_mnts_path = enforce_dir_layout(data_path, curr_dir, mnts_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(ica_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             ICA            %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_ica(dir_save_path, dir_failed_path, dir_mnts_path, ...
                    curr_dir, dir_config)
            catch ME
                handle_ME(ME, ica_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

        e_msg_1 = 'No data directory to find ICA MNTSs';
        if dir_config.convert_mnts_psth
            [ica_psth_path, ica_psth_failed_path] = create_dir(project_path, 'ica_psth');
            export_params(ica_psth_path, 'ica_psth', config);
            try
                %% Check to make sure paths exist for analysis and create save path
                e_msg_2 = ['No ', curr_dir, ' ica mnts data to convert to mnts'];
                ica_path = [mnts_path, '/ica'];
                dir_ica_path = enforce_dir_layout(ica_path, curr_dir, ica_psth_failed_path, e_msg_1, e_msg_2);
                [ica_data_path, ~] = create_dir(ica_psth_path, 'data');
                [dir_save_path, dir_failed_path] = create_dir(ica_data_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %          ICA PSTH          %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_mnts_to_psth(dir_save_path, dir_failed_path, dir_ica_path, ...
                    curr_dir, 'ica', dir_config)
            catch ME
                handle_ME(ME, ica_psth_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        end

    end
    toc(start_time);
end