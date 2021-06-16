function [] = spike_extraction_main(varargin)
    project_path = get_project_path(varargin);
    start_time = tic;

    %% Import psth config and removes ignored animals
    config = import_config(project_path, 'spike_extract');
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
        label_table = load_labels(project_path, ['labels_', curr_dir, '.csv']);

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
                %%    Filter data for SEPs    %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_filter(dir_save_path, dir_failed_path, parsed_dir_path, curr_dir, dir_config, label_table);
            catch ME
                handle_ME(ME, filter_failed_path, [curr_dir, '_failed.mat']);
            end
        end

        [spikes_data_path, spikes_failed_path] = create_dir(project_path, 'parsed_spike');
        export_params(spikes_data_path, 'parsed_spike', config);
        try
            if dir_config.use_raw
                parsed_path = [project_path, '/parsed_continuous'];
                e_msg_1 = 'No parsed directory to extract spikes from';
                e_msg_2 = ['No parsed directory for ', curr_dir, ' to extract spikes'];
                parsed_dir_path = enforce_dir_layout(parsed_path, curr_dir, ...
                    continuous_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(spikes_data_path, curr_dir);

                batch_continuous_extract_format_spikes(dir_save_path, dir_failed_path, ...
                    parsed_dir_path, curr_dir, dir_config, label_table); 
            else
                filter_path = [continuous_path, '/filtered_data'];
                e_msg_1 = 'No filter directory to extract spikes from';
                e_msg_2 = ['No filter directory for ', curr_dir, ' to extract spikes'];
                filter_dir_path = enforce_dir_layout(filter_path, curr_dir, ...
                    continuous_failed_path, e_msg_1, e_msg_2);
                [dir_save_path, dir_failed_path] = create_dir(spikes_data_path, curr_dir);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%        Extract Spikes      %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                batch_continuous_extract_format_spikes(dir_save_path, dir_failed_path, ...
                    filter_dir_path, curr_dir, dir_config);
            end
        catch ME
            handle_ME(ME, spikes_failed_path, [curr_dir, '_failed.mat']);
        end
     end
    toc(start_time);
end