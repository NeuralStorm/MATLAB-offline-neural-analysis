function [] = batch_mnts_to_psth(save_path, failed_path, data_path, ...
        dir_name, filename_substring_one, dir_config)

    config_log = dir_config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, dir_config.include_sessions);

    for file_index = 1:length(file_list)
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_index).name);

            %% Load needed variables from psth and does the receptive field analysis
            load(file, 'component_results', 'event_ts', 'selected_data', ...
                'filename_meta', 'label_log');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, component_results, event_ts);
            if empty_vars
                continue
            end

            [psth_struct, baseline_window, response_window] = reformat_mnts(label_log, ...
                component_results, dir_config.bin_size, dir_config.window_start, dir_config.window_end, dir_config.baseline_start, ...
                dir_config.baseline_end, dir_config.response_start, dir_config.response_end);

            matfile = fullfile(save_path, [filename_substring_one, ...
                '_format_' filename_meta.filename, '.mat']);
            save(matfile, 'psth_struct', 'baseline_window', ...
                'response_window', 'event_ts', 'filename_meta', 'config_log', ...
                'label_log', 'selected_data');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
end