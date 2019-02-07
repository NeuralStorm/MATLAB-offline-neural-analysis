function [psth_path] = format_PSTH(parsed_path, animal_name, total_bins, bin_size, pre_time, post_time, ...
        wanted_events, trial_range)
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

    if pre_time > 0
        pre_time_bins = (length([-abs(pre_time): bin_size: 0])) - 1;
    else
        pre_time_bins = 0;
    end
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
            % Creates a cell array of strings with the names of all the desired events
            event_strings = {};
            if isempty(wanted_events)
                wanted_events = unique(events(:,1));
            end
            for i = 1: length(wanted_events)
                event_strings{end+1} = ['event_', num2str(wanted_events(i))];
            end
            event_struct = struct;

            % Truncates events to desired trial range from total_trials * total_events
            if ~isempty(trial_range)
                try
                    events = events(trial_range(1):trial_range(2), :);
                catch ME
                    warning('Error: %s\n', ME.message);
                    warning('Animal does not have enough trials for the decided trial range. Truncating to the length of events it has.');
                    events = events(trial_range(1):length(events), :);
                end
            end
            
            event_struct.all_events = {};
            for i = 1: length(wanted_events)
                %% Slices out the desired trials from the events matrix (Inclusive range)
                event_struct.all_events = [event_struct.all_events; event_strings{i}, {events(events == wanted_events(i), 2)}];
            end

            %% Creates the PSTH
            for region = 1:length(unique_regions)
                region_name = unique_regions{region};
                labeled_map = labeled_neurons.(region_name)(:,4);
                event_struct.(region_name).relative_response = event_spike_times(labeled_map, event_struct.all_events(:,2), ...
                    total_bins, bin_size, pre_time, post_time);
            end

            try
                events_array = event_struct.all_events(:,2);
                event_count = 0;
                for event = 1:length(events_array)
                    %% get normalized raster for regions
                    for region = 1:length(unique_regions(:,1))
                        region_name = unique_regions{region};
                        total_region_neurons = length(labeled_neurons.(region_name)(:,1));
                        current_norm_raster = sum(event_struct.(region_name).relative_response((event_count + 1):1:(event_count + length(events_array{event})),:),1) ...
                            / length(events_array{event});
                        % normalized raster is the normalized psth
                        event_struct.(region_name).([event_strings{event}, '_normalized_raster']) = current_norm_raster;
                        [pre_time_activity, post_time_activity] = split_psth(current_norm_raster, pre_time, pre_time_bins, post_time_bins);
                        event_struct.(region_name).([event_strings{event}, '_norm_pre_time_activity']) = pre_time_activity;
                        event_struct.(region_name).([event_strings{event}, '_norm_post_time_activity']) = post_time_activity;
                    end
                    % Updates event_count to scale sum properly for next row
                    event_count = event_count + length(events_array{event});
                end
            catch ME
                if ~exist(failed_path, 'dir')
                    mkdir(parsed_path, 'failed');
                end
                if ~exist(failed_path, 'dir')
                    mkdir(parsed_path, 'failed');
                end

                filename = ['FAILED.', file_name, '.mat'];
                error_message = getReport( ME, 'extended', 'hyperlinks', 'on');
                warning(error_message);
                matfile = fullfile(failed_path, filename);
                save(matfile, 'ME');
            end
            
            fprintf('Finished PSTH for %s\n', current_day);
            %% Saving the file
            filename = ['PSTH.format.', file_name, '.mat'];
            matfile = fullfile(psth_path, filename);
            save(matfile, 'event_struct', 'total_neurons', 'neuron_map', 'events', 'event_strings', ...
                'labeled_neurons', 'unique_regions', 'region_channels', 'original_neuron_map', 'wanted_events');
        catch ME
            if ~exist(failed_path, 'dir')
                mkdir(parsed_path, 'failed');
            end

            filename = ['FAILED.', file_name, '.mat'];
            error_message = getReport( ME, 'extended', 'hyperlinks', 'on');
            warning(error_message);
            matfile = fullfile(failed_path, filename);
            save(matfile, 'ME');
        end
    end
    toc;
end

function [pre_time_activity, post_time_activity] = split_psth(normalized_raster, pre_time, pre_time_bins, post_time_bins)
    pre_time_activity = [];
    post_time_activity = [];
    %% Breaks down the PSTH into pre psth
    if pre_time ~= 0
        %% Creates pre time PSTH
        pre = pre_time_bins;
        while pre < length(normalized_raster)
            pre_time_activity = [pre_time_activity; normalized_raster((pre - pre_time_bins + 1 ): pre)];
            % Update counter
            pre = pre + post_time_bins + pre_time_bins;
        end
        %% Creates post time PSTH
        post = pre_time_bins + post_time_bins; 
        while post <= length(normalized_raster)
            post_time_activity = [post_time_activity; normalized_raster((post - post_time_bins + 1): post)];
            post = post + pre_time_bins + post_time_bins;
        end
    else
        warning('Since the pre time is set to 0, there will not be a psth generated with only the pre time activity.\n');
        pre_time_activity = NaN;
        post_time_activity = normalized_raster;
    end
end