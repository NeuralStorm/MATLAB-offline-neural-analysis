function [] = analog_main()
    %TODO add error checking
    project_path = uigetdir(pwd);
    start_time = tic;

    %% Import psth config and removes ignored animals
    config = import_config(project_path, 'analog');
    config(config.include_dir == 0, :) = [];

    %% Creating paths to do continuous formatting
    [continuous_path, continuous_failed_path] = create_dir(project_path, 'continuous');
    [data_path, ~] = create_dir(continuous_path, 'data');
    export_params(data_path, 'continuous', config);

    dir_list = config.dir_name;
    for dir_i = 1:length(dir_list)
        curr_dir = dir_list{dir_i};
        dir_config = config(dir_i, :);
        label_table = load_labels(project_path, [curr_dir, '_labels.csv']);
        if dir_config.filter_data
            try
                %% Check to make sure paths exist for analysis and create save path
                parsed_path = [project_path, '/parsed_continuous'];
                e_msg_1 = 'No parsed directory to filter';
                e_msg_2 = ['No ', curr_dir, ' directory to filter'];
                parsed_dir_path = enforce_dir_layout(parsed_path, curr_dir, ...
                    continuous_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(data_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%        Filter data         %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_filter(dir_save_path, dir_failed_path, parsed_dir_path, curr_dir, dir_config, label_table);
            catch ME
                handle_ME(ME, continuous_failed_path, [curr_dir, '_missing_dir.mat']);
            end
        else
            if ~exist(continuous_path, 'dir') || ~exist(data_path, 'dir')
                error('Must have continuous data for %s analysis', curr_dir);
            end
        end

        if config.sep_slicing
            e_msg_1 = 'No data directory to find analog data';
            e_msg_2 = ['No ', curr_dir, ' analog data to create SEPs'];
            dir_continuous_path = enforce_dir_layout(data_path, curr_dir, ...
                continuous_failed_path, e_msg_1, e_msg_2);
            [sep_path, ~] = create_dir(continuous_path, 'sep');
            [sep_data_path, ~] = create_dir(sep_path, 'data');
            [dir_save_path, dir_failed_path] = create_dir(sep_data_path, curr_dir);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%            Format SEP            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            batch_format_sep(dir_save_path, dir_failed_path, dir_continuous_path, curr_dir, dir_config)
        end

        if config.sep_analysis
            %TODO add check for sep stuff like in graph psth
            %TODO use_raw flag here and grab raw continuous path directly
            dir_sep_path = enforce_dir_layout(sep_data_path, curr_dir, ...
                continuous_failed_path, e_msg_1, e_msg_2);
            [sep_analysis_path, ~] = create_dir(sep_path, 'sep_analysis');
            [dir_save_path, dir_failed_path] = create_dir(sep_analysis_path, curr_dir);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Sep Analysis           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            batch_sep_analysis(dir_save_path, dir_failed_path, dir_sep_path, curr_dir, dir_config);
        end
    end
    toc(start_time);
end