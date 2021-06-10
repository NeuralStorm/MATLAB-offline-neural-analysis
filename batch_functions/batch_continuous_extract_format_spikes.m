function batch_continuous_extract_format_spikes(save_path, failed_path, data_path,...
    dir_name, dir_config, label_table)
    %% Continuous data spike extraction...
    extract_spikes_start = tic;
    fprintf('Extracting spikes for %s \n', dir_name);
    headers = [["channel", "string"]; ["channel_data", "string"]];
    config_log = dir_config;
    curr_dir = [data_path, '/'];
    file_list = get_file_list(curr_dir, '.mat');
    file_list = update_file_list(file_list, failed_path, ...
        dir_config.include_sessions);

    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
       
        try
            %% Load file contents
            file = [curr_dir, '/', file_list(file_index).name];
            load(file, 'event_info', 'filename_meta', 'filtered_map', 'sample_rate');

            %% Extract spikes from filtered data
            channel_map = prealloc_table(headers, [0, size(headers, 1)]);
            for chan_i = 1:height(filtered_map)
                chan = filtered_map.channel{chan_i};
                data = filtered_map.channel_data(:);
                [spikes, threshold] = continuous_extract_spikes(data, dir_config.spike_thresh,...
                    event_info.event_ts, sample_rate, dir_config.baseline_start, dir_config.baseline_end);
                a = [{chan}, {spikes'}];
                channel_map = vertcat_cell(channel_map, a, headers(:, 1), "after");
            end

            %% Label data
            labeled_data = label_data(channel_map, label_table, filename_meta.session_num);
            
            %% Saving outputs
            matfile = fullfile(save_path, ['spikes_', filename_meta.filename, '.mat']);
            empty_vars = check_variables(matfile, channel_map, event_ts, labeled_data);
            if empty_vars
                continue
            end
            
            %% Save spike data
            save(matfile, '-v7.3', 'channel_map', 'event_info', 'filename_meta', 'labeled_data', 'config_log');
            clear('channel_map', 'event_ts', 'filename_meta', 'labeled_data');
            
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
end

