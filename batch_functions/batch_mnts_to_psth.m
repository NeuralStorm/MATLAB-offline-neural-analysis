function [] = batch_mnts_to_psth(save_path, failed_path, data_path, ...
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

    tot_bins = get_tot_bins(dir_config.window_start, dir_config.window_end, ...
        dir_config.bin_size);

    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_index).name);

            %% Load mnts data
            if dir_config.use_mnts
                load(file, 'mnts_struct', 'event_info', 'chan_group_log', 'filename_meta');
                mnts_data = mnts_struct; clear('mnts_struct');
            else
                load(file, 'component_results', 'event_info', 'chan_group_log', ...
                    'filename_meta');
                mnts_data = component_results; clear('component_results');
            end
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, mnts_data);
            if empty_vars
                continue
            end

            rr_data = reformat_mnts(chan_group_log, mnts_data, tot_bins);

            matfile = fullfile(save_path, [filename_substring_one, ...
                '_format_' filename_meta.filename, '.mat']);
            save(matfile, 'rr_data', 'event_info', 'filename_meta', 'config_log', ...
                'chan_group_log');
            clear('rr_data', 'event_info', 'filename_meta', 'chan_group_log', 'mnts_data');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
end