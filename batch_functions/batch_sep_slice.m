function [sep_path] = batch_sep_slice(animal_name, parsed_path, config)
    
    batch_sep_tic = tic;
    [sep_path, failed_path] = create_dir(parsed_path, 'sep');
    [file_list] = get_file_list(parsed_path, '.mat', config.ignore_sessions);
    export_params(sep_path, 'sep', failed_path, config);
    filter_vars = {'notch_filt', 'notch_freq', 'notch_bandwidth', 'notch_bandstop', ...
        'sep_filt_type', 'sep_filt_freq', 'sep_filt_order'};
    sep_vars = {'ignore_sessions', 'trial_range', 'filter_raw', 'load_filtered', 'use_raw', ...
        'saved_filtered', 'window_start', 'window_end'};
    filter_log = make_struct_log(config, filter_vars);
    sep_log = make_struct_log(config, [filter_vars, sep_vars]);

    
    error_list = [];
    parfor file_index = 1:length(file_list)
      %% Load file contents
        file = [parsed_path, '/', file_list(file_index).name];
        [~, filename, ~] = fileparts(file);
        disp(['Loading ', filename, '...']); 
        try
            parsed_file = load(file);
            board_band_map = parsed_file.board_band_map;
            board_dig_in_data = parsed_file.board_dig_in_data;
            sample_rate = parsed_file.sample_rate;
            %             load(file, 'board_band_map', 'board_dig_in_data', 'sample_rate');        
%         empty_vars = check_variables(file, board_band_map, board_dig_in_data, sample_rate);
%         if empty_vars
%             continue
%         end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%           Filter           %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if config.filter_raw
            disp(['Filtering ', filename, '...']);
            filtering_tic = tic;            
            data_map = do_filter(board_band_map, sample_rate, config.notch_filt, ...
                config.notch_freq, config.notch_bandwidth, config.notch_bandstop, ...
                config.sep_filt_type, config.sep_filt_freq, config.sep_filt_order);

%             if config.save_filtered
%                 [filter_path, failed_path] = create_dir(parsed_path, 'filtered');
%                 matfile = fullfile(filter_path, ['filtered_data_', filename, '.mat']);
%                 save(matfile, '-v7.3', 'data_map', 'filter_log');
%                 export_params(filter_path, 'filtering', failed_path, config);
%             end
%             fprintf('Finished filtering for %s. It took %s.\nFilename: %s\n', ...
%                 animal_name, num2str(toc(filtering_tic)), filename);

%         elseif config.load_filtered
%             filter_path = [parsed_path, '/filtered'];
%             if exist(filter_path, 'dir') ~= 7
%                 error('Filtered data does not exist on the exected path:\n%s\n', filter_path);
%             else
%                 filtered_file = [filter_path, '/filtered_data_', file_list(file_index).name];
%                 load(filtered_file, 'data_map');
%             end
%         elseif config.use_raw
%             data_map = board_band_map;
        else
            error('Must load data before creating SEPs');
        end

        %% slice
        disp(['Slicing ', filename, '...']);
        sep_tic = tic;
        sep_window = [-abs(config.window_start), config.window_end];
%         [sep_l2h_map, sep_struct] = make_sep(data_map, board_dig_in_data, ...
%             sample_rate, sep_window, config.trial_range);
        sliced_signal = slice_signal(data_map, board_dig_in_data, sample_rate, sep_window);

        matfile = fullfile(sep_path, ['sliced_', filename, '.mat']);
%         save(matfile, '-v7.3', 'sep_l2h_map', 'sep_window', 'sep_struct', 'sep_log');
        save_file(matfile, '-v7.3', sliced_signal, sep_window, sep_log);
        fprintf('Finished formatting SEP for %s. It took %s.\nFilename: %s\n', ...
            animal_name, num2str(toc(sep_tic)), filename);
        catch
            error_list = [error_list; filename];
            continue;
        end
    end
    fprintf('Finished  SEP formation for %s. It took %s.\n', ...
        animal_name, num2str(toc(batch_sep_tic)));
    
%     save([sep_path, '/errors.mat'], 'error_list');
end