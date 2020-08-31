function batch_continuous_extract_format_spikes(save_path, failed_path, data_path,...
    dir_name, dir_config, label_table)
    %% Continuous data spike extraction...
    extract_spikes_start = tic;
    fprintf('Extracting spikes for %s \n', dir_name);
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
            load(file, 'event_samples', 'filename_meta', 'filtered_map', 'label_log', 'sample_rate');
            %% Check variables to make sure they are not empty
%             empty_vars = check_variables(file, sliced_signal);
%             if empty_vars
%                 continue
%             end
                      
            %% Format events for spike extraction and psth formatting
            unique_events = fieldnames(orderfields(event_samples));
            
            event_ts = [];
            sample_ts = event_samples.event_1(1,:);
            for event_i = 1:length(unique_events)
               
                event = unique_events{event_i};
                
                temp_sample_ts = event_samples.(event)(1,:);
                
                temp_ts(:,2) = event_samples.(event)(1,:) / sample_rate; 
                temp_ts(:,1) = event_i;
                
                event_ts = [event_ts; temp_ts];                 
            end
            event_ts = sortrows(event_ts, 2); 
            
            %% Extract spikes from filtered data
            channel_map = {};
            for chan = 1:length(filtered_map)
               
                channel_map{chan, 1} = filtered_map(chan).sig_channels;
                [spikes, threshold] = continuous_extract_spikes(filtered_map(chan).data, dir_config.spike_thresh,...
                    sample_ts, sample_rate, dir_config.baseline_start, dir_config.baseline_end);
                channel_map{chan, 2} = spikes';
%                 channel_map{chan, 3} = threshold; 
                
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
            save(matfile, '-v7.3', 'channel_map', 'event_ts', 'filename_meta', 'labeled_data');
            clear('channel_map', 'event_ts', 'filename_meta', 'labeled_data');
            
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
        
        
    end
end

