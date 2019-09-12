function [sep_path] = batch_sep_slice(animal_name, parsed_path, config)
    [sep_path, failed_path] = create_dir(parsed_path, 'sep');
    [file_list] = get_file_list(parsed_path, '.mat', config.ignore_sessions);
    export_params(parsed_path, 'filtering', failed_path, config);
    filter_vars = {'notch_filt', 'notch_freq', 'notch_bandwidth', 'notch_bandstop', ...
        'sep_type_filt', 'sep_filt_freq', 'sep_filt_order'};

    for file_index = 1:length(file_list)
        %% Load file contents
        file = [parsed_path, '/', file_list(file_index).name];
        [~, filename, ~] = fileparts(file);
        load(file, 'board_band_map', 'board_dig_in_data', 'sample_rate');
        empty_vars = check_variables(file, board_band_map, board_dig_in_data, sample_rate);
        if empty_vars
            continue
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%           Filter           %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if config.filter_raw
            data_map = do_filter(board_band_map, sample_rate, config.notch_filt, ...
                config.notch_freq, config.notch_bandwidth, config.notch_bandstop, ...
                config.sep_type_filt, config.sep_filt_freq, config.sep_filt_order);

            if config.save_filtered
                filter_params = struct;
                filter_params.sample_rate = sample_rate;
                for struct_name = fieldnames(config)'
                    if contains(struct_name, filter_vars)
                        filter_params.(struct_name{1}) = config.(struct_name{1});
                    end
                end
                [filter_path, failed_path] = create_dir(parsed_path, 'filtered');
                matfile = fullfile(filter_path, ['filtered_data_', filename, '.mat']);
                save(matfile, '-v7.3', 'data_map', 'filter_params');
                export_params(filter_path, 'filtering', failed_path, config);
            end
        elseif config.load_filtered
            filter_path = [parsed_path, '/filtered'];
            if exist(filter_path, 'dir') ~= 7
                error('Filtered data does not exist on the exected path:\n%s\n', filter_path);
            else
                filtered_file = [filter_path, '/filtered_data_', file_list(file_index).name];
                load(filtered_file, 'data_map');
            end
        elseif config.use_raw
            data_map = board_band_map;
        else
            error('Must load data before creating SEPs');
        end

        %% slice
        sep_window = [-abs(config.start_window), config.end_window];
        [sep_l2h_map, sep_struct, analysis_sep_struct] = make_sep_map(data_map, board_dig_in_data, ...
            sample_rate, sep_window, config.trial_range);

        matfile = fullfile(sep_path, ['sliced_', filename, '.mat']);
        save(matfile, '-v7.3', 'sep_l2h_map', 'sep_window', 'sep_struct', 'analysis_sep_struct');

    end

end