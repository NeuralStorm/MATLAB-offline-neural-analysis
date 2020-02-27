function [filter_path] = batch_filter(animal_path, parsed_path, config)

    [filter_path, failed_path] = create_dir(parsed_path, 'filtered');
    file_list = get_file_list(parsed_path, '.mat', config.ignore_sessions);
    export_params(filter_path, 'filter', failed_path, config);

    %% load label table
    channel_table = load_labels(animal_path, 'selected_data.csv', config.ignore_sessions);

    for file_index = 1:length(file_list)
        try
            %% Load file contents
            file = [parsed_path, '/', file_list(file_index).name];
            load(file, 'labeled_data', 'sample_rate', 'filename_meta', 'event_samples')

            %% Select channels
            selected_data = select_data(labeled_data, channel_table, ...
                filename_meta.session_num);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Filter           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~config.use_raw
                filtered_map = filter_continuous(selected_data, sample_rate, config.notch_filt, ...
                    config.notch_freq, config.notch_bandwidth, config.notch_bandstop, ...
                    config.sep_filt_type, config.sep_filt_freq, config.sep_filt_order);
            else
                error('Contradictory config settings. Cannot save filtered data when use raw is true');
            end

            config_log = config;
            matfile = fullfile(filter_path, ['filtered_', filename_meta.filename]);
            save(matfile, '-v7.3', 'filtered_map', 'sample_rate', ...
                'event_samples', 'filename_meta', 'config_log');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
end