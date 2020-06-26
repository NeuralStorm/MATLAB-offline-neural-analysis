function [] = batch_power_mnts_to_psth(save_path, failed_path, data_path, ...
    dir_name, filename_substring_one, dir_config)

    %% Purpose: Go through file list and convert mnts to psth
    %% Input:
    % save_path: path to save files at
    % failed_path: path to save errors at
    % data_path: path to load files from before analysis is ran
    % dir_name: Name of dir that data came from (usually subject #)
    % filename_substring_one: String to append onto front of saved files (pca in this case)
    % dir_config: config settings for that subject
    %% Output:
    %  No output, conversion saved in mat files at saved location

    config_log = dir_config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, dir_config.include_sessions);

    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_index).name);

            %% Load needed variables from psth and does the receptive field analysis
            load(file, 'component_results', ...
                'filename_meta', 'label_log', 'pc_log');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, component_results);
            if empty_vars
                continue
            end

            %% Convert features into psth and add in gamble and safebet events 
            [psth_struct, baseline_struct, response_struct] = power_reformat_mnts(...
                pc_log, component_results, dir_config.bin_size, dir_config.window_start, ...
                dir_config.window_end, dir_config.baseline_start, dir_config.baseline_end, ...
                dir_config.response_start, dir_config.response_end, dir_config.window_shift_time);

            matfile = fullfile(save_path, [filename_substring_one, ...
                '_format_' filename_meta.filename, '.mat']);
            save(matfile, 'psth_struct', 'baseline_struct', 'response_struct', ...
                 'filename_meta', 'config_log', 'label_log', 'pc_log');
            clear('psth_struct', 'baseline_struct', 'response_struct', ...
                'filename_meta', 'label_log', 'pc_log');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
end