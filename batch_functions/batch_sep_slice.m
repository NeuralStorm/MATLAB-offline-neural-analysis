function [sep_path] = batch_sep_slice(animal_path, parsed_path, config)

    [sep_path, failed_path] = create_dir(parsed_path, 'sep');
    file_list = get_file_list(parsed_path, '.mat', config.ignore_sessions);
    export_params(sep_path, 'sep', failed_path, config);
    filter_vars = {'notch_filt', 'notch_freq', 'notch_bandwidth', 'notch_bandstop', ...
        'sep_filt_type', 'sep_filt_freq', 'sep_filt_order'};
    sep_vars = {'ignore_sessions', 'trial_range', 'filter_raw', 'load_filtered', 'use_raw', ...
        'saved_filtered', 'window_start', 'window_end'};
    filter_log = make_struct_log(config, filter_vars);
    sep_log = make_struct_log(config, [filter_vars, sep_vars]);

    %% load label table
    channel_table = load_labels(animal_path, 'selected_data.csv', config.ignore_sessions);

    error_list = [];
    for file_index = 1:length(file_list)
      %% Load file contents
        % try
            file = [parsed_path, '/', file_list(file_index).name];

            load(file, 'labeled_data', 'board_dig_in_data', 'sample_rate', 'filename_meta')

            %% Select channels
            selected_data = select_channels(labeled_data, channel_table, ...
                filename_meta.session_num);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Filter           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.filter_raw
                %TODO remove filter_raw from config
                data_map = filter_continuous(selected_data, sample_rate, config.notch_filt, ...
                    config.notch_freq, config.notch_bandwidth, config.notch_bandstop, ...
                    config.sep_filt_type, config.sep_filt_freq, config.sep_filt_order);
            else
                error('Must load data before creating SEPs');
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%          Slicing           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            sep_window = [-abs(config.window_start), config.window_end];
            %TODO fix slicing
            [sliced_signal, stim_ts] = slice_signal(data_map, board_dig_in_data, sample_rate, sep_window);
            matfile = fullfile(sep_path, ['sliced_', filename_meta.filename, '.mat']);
            save(matfile, '-v7.3', 'sliced_signal', 'sep_window', 'sep_log', 'filter_log', 'filename_meta', 'stim_ts');

        % catch
        %     error_list = [error_list; filename];
        %     continue;
        % end
    end
end