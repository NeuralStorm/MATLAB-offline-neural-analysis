function [spikes_path] = batch_find_spikes(animal_name, parsed_path, config)

    batch_spikes_tic = tic;
    [spikes_path, failed_path] = create_dir(parsed_path, 'sep');
    [file_list] = get_file_list(parsed_path, '.mat', config.ignore_sessions);
    export_params(spikes_path, 'spikes', failed_path, config);
%     filter_vars = {'notch_filt', 'notch_freq', 'notch_bandwidth', 'notch_bandstop', ...
%         'psth_filt_type', 'psth_filt_freq', 'psth_filt_order'};
%     sep_vars = {'ignore_sessions', 'trial_range', 'filter_raw', 'load_filtered', 'use_raw', ...
%         'saved_filtered', 'window_start', 'window_end'};
%     filter_log = make_struct_log(config, filter_vars);
%     sep_log = make_struct_log(config, [filter_vars, sep_vars]);

    for file_index = 1:length(file_list)
       %% Load file contents
        file = [parsed_path, '/', file_list(file_index).name];
        [~, filename, ~] = fileparts(file);
        disp(['Loading ', filename, '...']); 
        try
            parsed_file = load(file);
            board_band_map = parsed_file.board_band_map;
%             board_dig_in_data = parsed_file.board_dig_in_data;
            sample_rate = parsed_file.sample_rate;
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%           Filter           %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if config.filter_raw
            disp(['Filtering ', filename, '...']);
            filtering_tic = tic;            
            data_map = do_filter(board_band_map, sample_rate, config.notch_filt, ...
                config.notch_freq, config.notch_bandwidth, config.notch_bandstop, ...
                config.psth_filt_type, config.psth_filt_freq, config.psth_filt_order);

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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%          Find Spikes       %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        spikes = find_spikes(board_band_map, config.broadband_thresh_sd, t_amplifier);
        matfile = fullfile(psth_path, ['spikes_', filename, '.mat']);
        save_file(matfile, '-v7.3', spikes, sample_rate, board_dig_in_data, t_amplifier);
        catch        
        end
    end


end

