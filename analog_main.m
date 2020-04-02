function [] = analog_main()
    project_path = uigetdir(pwd);
    start_time = tic;

    %% Import psth config and removes ignored animals
    config = import_config(project_path, 'analog');
    config(config.include_dir == 0, :) = [];

    %% Creating paths to do analog analysis
    [continuous_path, continuous_failed_path] = create_dir(project_path, 'continuous');
    export_params(continuous_path, 'continuous', config);
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
            [filter_data_path, filter_failed_path] = create_dir(continuous_path, 'filtered_data');
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

        if dir_config.sep_slicing
            [sep_path, ~] = create_dir(continuous_path, 'sep');
            [sep_data_path, sep_failed_path] = create_dir(sep_path, 'sep_formatted_data');
            export_params(sep_data_path, 'format_sep', config);
            try
                e_msg_1 = 'No data directory to find analog data';
                e_msg_2 = ['No ', curr_dir, ' analog data to create SEPs'];
                if dir_config.use_raw
                    parsed_path = [project_path, '/parsed_continuous'];
                    sep_input_path = enforce_dir_layout(parsed_path, curr_dir, ...
                        continuous_failed_path, e_msg_1, e_msg_2);
                else
                    filter_path = [continuous_path, '/filtered_data'];
                    sep_input_path = enforce_dir_layout(filter_path, curr_dir, ...
                        continuous_failed_path, e_msg_1, e_msg_2);
                end
                [dir_save_path, dir_failed_path] = create_dir(sep_data_path, curr_dir);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%            Format SEP            %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_format_sep(dir_save_path, dir_failed_path, sep_input_path, curr_dir, dir_config, label_table)
            catch ME
                handle_ME(ME, sep_failed_path, [curr_dir, '_failed.mat']);
            end
        end

        if dir_config.sep_analysis
            [sep_analysis_path, analysis_failed_path] = create_dir(sep_path, 'sep_output_data');
            export_params(sep_analysis_path, 'sep_analysis', config);
            try
                e_msg_1 = 'No data directory to find SEPs';
                e_msg_2 = ['No ', curr_dir, ' for SEP analysis'];
                sep_path = [continuous_path, '/sep'];
                sep_data_path = [sep_path, '/sep_formatted_data'];
                dir_sep_path = enforce_dir_layout(sep_data_path, curr_dir, ...
                    continuous_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(sep_analysis_path, curr_dir);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%           Sep Analysis           %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_sep_analysis(dir_save_path, dir_failed_path, dir_sep_path, curr_dir, dir_config);
            catch ME
                handle_ME(ME, analysis_failed_path, [curr_dir, '_failed.mat']);
            end
        end

        if dir_config.make_sep_graphs
            [sep_figure_path, graph_failed_path] = create_dir(sep_path, 'sep_figures');
            export_params(sep_figure_path, 'sep_analysis', config);
            try
                e_msg_1 = 'No data directory to find SEPs';
                e_msg_2 = ['No ', curr_dir, ' for plotting'];
                sep_path = [continuous_path, '/sep'];
                sep_data_path = [sep_path, '/sep_output_data'];
                dir_sep_path = enforce_dir_layout(sep_data_path, curr_dir, ...
                    continuous_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(sep_figure_path, curr_dir);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%           Sep Graphing           %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_graph_sep(dir_save_path, dir_failed_path, dir_sep_path, curr_dir, dir_config)
            catch ME
                handle_ME(ME, graph_failed_path, [curr_dir, '_failed.mat']);
            end
        end
    end
    toc(start_time);
end