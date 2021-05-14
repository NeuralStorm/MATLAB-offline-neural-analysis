function [] = batch_filter(save_path, failed_path, data_path, dir_name, ...
        dir_config, label_table)
    %% Find files to filter
    filter_start = tic;
    config_log = dir_config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, dir_config.include_sessions);

    %% Remove unselected channels
    label_table(label_table.selected_channels == 0, :) = [];

    fprintf('Filtering analog data for %s \n', dir_name);
    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% Load file contents
            file = [data_path, '/', file_list(file_index).name];
            load(file, 'channel_map', 'sample_rate', 'filename_meta', 'event_samples');

            %% Select channels and label data
            selected_chans = label_data(channel_map, label_table, filename_meta.session_num);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Filter           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~dir_config.use_raw
                [filtered_map] = filter_continuous(selected_chans, ...
                    sample_rate, dir_config.notch_filt, dir_config.notch_freq, ...
                    dir_config.notch_bandwidth, dir_config.filt_type, ...
                    dir_config.filt_freq, dir_config.filt_order);
                    chan_group_log = selected_chans;
                    chan_group_log = removevars(chan_group_log, 'channel_data');
            else
                error('Cannot filter and use raw data for analysis');
            end

            matfile = fullfile(save_path, ['filtered_', filename_meta.filename]);
            save(matfile, '-v7.3', 'filtered_map', 'sample_rate', ...
                'event_samples', 'filename_meta', 'config_log', 'chan_group_log');
            clear('filtered_map', 'sample_rate', 'event_samples', 'filename_meta', 'chan_group_log');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished filtering for %s. It took %s \n', ...
        dir_name, num2str(toc(filter_start)));
end