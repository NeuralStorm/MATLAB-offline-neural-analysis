function [psth_path] = format_PSTH(parsed_path, animal_name, total_bins, bin_size, pre_time, post_time, ...
        wanted_events, trial_range, total_trials)
    tic;
    % Grabs all .mat files in the parsed plx directory
    parsed_mat_path = strcat(parsed_path, '/*.mat');
    parsed_files = dir(parsed_mat_path);
    wanted_events = sort(wanted_events);
    
    % Checks and creates a psth directory if it does not exists
    psth_path = strcat(parsed_path, '/psth');
    if ~exist(psth_path, 'dir')
       mkdir(parsed_path, 'psth');
    end

    % Deletes the failed directory if it already exists
    failed_path = [parsed_path, '/failed'];
    if exist(failed_path, 'dir') == 7
       delete([failed_path, '/*']);
       rmdir(failed_path);
    end

    % Creates a cell array of strings with the names of all the desired events
    event_strings = {};
    for i = 1: length(wanted_events)
        event_strings{end+1} = ['event_', num2str(wanted_events(i))];
    end
    
    pre_time_bins = (length([-abs(pre_time): bin_size: 0])) - 1;
    post_time_bins = (length([0:bin_size:post_time])) - 1;

    for h = 1: length(parsed_files)
        failed_calculating = {};
        file = [parsed_path, '/', parsed_files(h).name];
        [file_path, file_name, file_extension] = fileparts(file);
        seperated_file_name = strsplit(file_name, '.');
        current_day = seperated_file_name{4};
        fprintf('Calculating PSTH for %s on %s\n', animal_name, current_day);
        load(file);

        try
            event_struct = struct;

            % Truncates events to desired trial range from total_trials * total_events
            try
                events = events(trial_range(1):trial_range(2), :);
            catch ME
                warning('Error: %s\n', ME.message);
                warning('Animal does not have enough trials for the decided trial range. Truncating to the length of events it has.');
                events = events(trial_range(1):length(events), :);
            end
            
            event_struct.all_events = {};
            for i = 1: length(wanted_events)
                %% Slices out the desired trials from the events matrix (Inclusive range)
                event_struct.all_events = [event_struct.all_events; event_strings{i}, {events(events == wanted_events(i), 2)}];
                event_struct.([event_strings{i}, '_normalized_raster']) = [];
                event_struct.([event_strings{i}, '_norm_pre_time_activity']) = [];
                event_struct.([event_strings{i}, '_norm_post_time_activity']) = [];
            end

            %% Creates the PSTH 
            event_struct.relative_response = event_spike_times(neuron_map(:,2), event_struct.all_events(:,2), ...
                total_trials, total_bins, bin_size, pre_time, post_time);
            event_struct.event_count = tabulate(events(:,1));

            for region = 1:length(unique_regions)
                region_name = unique_regions{region};
                labeled_map = labeled_neurons.(region_name)(:,4);
                event_struct.(region_name).relative_response = event_spike_times(labeled_map, event_struct.all_events(:,2), ...
                    total_trials, total_bins, bin_size, pre_time, post_time);
            end

            try
                events_array = event_struct.all_events(:,2);
                event_count = 0;
                for event = 1: length(events_array)
                    % Normalize rasters by the number of events
                    event_struct.([event_strings{event}, '_normalized_raster']) = ...
                        sum(event_struct.relative_response((event_count + 1):1:(event_count + length(events_array{event})),:),1) ...
                        / length(events_array{event});

                    %% get normalized raster for regions
                    for region = 1:length(unique_regions)
                        region_name = unique_regions{region};
                        total_region_neurons = length(labeled_neurons.(region_name)(:,1));
                        event_response = event_struct.(region_name).relative_response((event_count + 1):1:(event_count + length(events_array{event})),:);
                        % Reshape event response matrix to get all neurons
                        event_psth = [];
                        for row = 1:length(event_response(:,1))
                            reshape(event_response(row,:), total_region_neurons, (pre_time_bins + post_time_bins));
                            event_psth = [event_psth; reshape(event_response(row,:), total_region_neurons, (pre_time_bins + post_time_bins))];
                        end
                        current_norm_raster = sum(event_struct.(region_name).relative_response((event_count + 1):1:(event_count + length(events_array{event})),:),1) ...
                            / length(events_array{event});
                        % normalized raster is the normalized psth
                        event_struct.(region_name).([event_strings{event}, '_normalized_raster']) = current_norm_raster;
                        % >> test_event = event_struct.Left.event_1_normalized_raster;
                        % >> test_reshape = reshape(test_event, left_length, (pre_time_bins + post_time_bins));
                        event_struct.(region_name).([event_strings{event}, '_event_response']) = event_response;
                        event_struct.(region_name).([event_strings{event}, '_event_psth']) = sum(event_response);
                        avg_psth = reshape(current_norm_raster, total_region_neurons, (pre_time_bins + post_time_bins));
                        avg_psth = mean(avg_psth);
                        event_struct.(region_name).([event_strings{event}, '_avg_psth']) = avg_psth;
                        event_struct.(region_name).([event_strings{event}, '_event_psth']) = event_response;
                    end
                    % Updates event_count to scale sum properly for next row
                    event_count = event_count + length(events_array{event});
                    %% Breaks down the PSTH into pre and post windows for receptive field analysis
                    if pre_time ~= 0
                        normalized_raster = getfield(event_struct, [event_strings{event}, '_normalized_raster']);
                        pre = pre_time_bins;
                        post = pre_time_bins + post_time_bins;  
                        while pre < length(normalized_raster)
                            event_struct.([event_strings{event}, '_norm_pre_time_activity']) = ... 
                                [event_struct.([event_strings{event}, '_norm_pre_time_activity']); normalized_raster((pre - pre_time_bins + 1 ): pre)];
                            event_struct.([event_strings{event}, '_norm_post_time_activity']) = ...
                                [event_struct.([event_strings{event}, '_norm_post_time_activity']); normalized_raster((post - post_time_bins + 1): post)];
                            % Update pre and post counters
                            pre = pre + post_time_bins + pre_time_bins;
                            post = post + pre_time_bins + pre_time_bins;
                        end
                    end
                end
            catch ME
                if ~exist(failed_path, 'dir')
                    mkdir(parsed_path, 'failed');
                end
                failed_calculating{end + 1} = file_name;
                failed_calculating{end, 2} = ME;
                filename = ['FAILED.', file_name, '.mat'];
                warning('%s failed to calculate\n', file_name);
                warning('Error: %s\n', ME.message);
                matfile = fullfile(failed_path, filename);
                save(matfile, 'failed_calculating');
            end
            
            fprintf('Finished PSTH for %s\n', current_day);
            %% Saving the file
            filename = ['PSTH.format.', file_name, '.mat'];
            matfile = fullfile(psth_path, filename);
            save(matfile, 'event_struct', 'total_neurons', 'neuron_map', 'events', 'event_strings', 'labeled_neurons', 'unique_regions', 'region_channels');
        catch ME
            if ~exist(failed_path, 'dir')
                mkdir(parsed_path, 'failed');
            end
            failed_calculating{end + 1} = file_name;
            failed_calculating{end, 2} = ME;
            filename = ['FAILED.', file_name, '.mat'];
            warning('%s failed to calculate\n', file_name);
            warning('Error: %s\n', ME.message);
            matfile = fullfile(failed_path, filename);
            save(matfile, 'failed_calculating');
        end
    end
    toc;
end