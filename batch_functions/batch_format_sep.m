function [] = batch_format_sep(save_path, failed_path, data_path, dir_name, dir_config, label_table)
    sep_start = tic;
    fprintf('Creating SEP for %s \n', dir_name);
    config_log = dir_config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, dir_config.include_sessions);
    %% Remove unselected channels
    label_table(label_table.selected_channels == 0, :) = [];

    if dir_config.use_raw
        for file_index = 1:length(file_list)
            [~, filename, ~] = fileparts(file_list(file_index).name);
            filename_meta.filename = filename;
            try
                %% pull info from filename and set up file path for analysis
                file = fullfile(data_path, file_list(file_index).name);
                load(file, 'channel_map', 'filename_meta', 'event_samples', 'sample_rate');
                %% Select channels and label data
                selected_chans = label_data(channel_map, label_table, filename_meta.session_num);
                chan_group_log = selected_chans;
                chan_group_log = removevars(chan_group_log, 'channel_data');

                %% unfiltered data is called filtered for convience of calling slicing function
                raw_map = table2struct(selected_chans);
    
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%          Slicing           %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                sep_window = [-abs(dir_config.window_start), dir_config.window_end];
                sliced_signal = format_sep(raw_map, event_samples, ...
                    sample_rate, sep_window, dir_config.square_pulse, ...
                    dir_config.include_events);

                %% Save sep
                matfile = fullfile(save_path, ['sliced_', filename_meta.filename, '.mat']);
                save(matfile, '-v7.3', 'sliced_signal', 'sep_window', ...
                    'config_log', 'filename_meta', 'event_samples', 'chan_group_log');
                clear('sliced_signal', 'sep_window', 'filename_meta', 'event_samples', 'chan_group_log');
            catch ME
                handle_ME(ME, failed_path, filename_meta.filename);
            end
        end
    else
        for file_index = 1:length(file_list)
            [~, filename, ~] = fileparts(file_list(file_index).name);
            filename_meta.filename = filename;
            try
                %% pull info from filename and set up file path for analysis
                file = fullfile(data_path, file_list(file_index).name);
    
                %% Load needed variables from psth and does the receptive field analysis
                load(file, 'filtered_map', 'event_samples', 'sample_rate', 'filename_meta', 'chan_group_log');
    
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%          Slicing           %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %! change handling of time windows
                sliced_signal = format_sep(filtered_map, event_samples, ...
                    sample_rate, dir_config.window_start, dir_config.window_end, ...
                    dir_config.square_pulse, dir_config.include_events);

                %% Save sep
                matfile = fullfile(save_path, ['sliced_', filename_meta.filename, '.mat']);
                save(matfile, '-v7.3', 'sliced_signal', ...
                    'config_log', 'filename_meta', 'event_samples', 'chan_group_log');
                clear('sliced_signal', 'filename_meta', 'event_samples', 'chan_group_log');
            catch ME
                handle_ME(ME, failed_path, filename_meta.filename);
            end
        end
    end

    fprintf('Finished SEP formatting for %s. It took %s \n', ...
        dir_name, num2str(toc(sep_start)));
end