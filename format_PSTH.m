function [psth_path] = format_PSTH(parsed_path, animal_name, total_bins, bin_size, pre_time, post_time, ...
                            wanted_neurons, wanted_events, trial_range, total_trials)
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

    % Creates a cell array of strings with the naes of all the desired events
    event_strings = {};
    for i = 1: length(wanted_events)
        event_strings{end+1} = ['event_', num2str(wanted_events(i))];
    end
    
    
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
            % Updates neuron_map and total neurons
            neurons = [];
            if ~isempty(wanted_neurons)
                for neuron = length(wanted_neurons)
                    neurons = [neurons; neuron_map(wanted_neurons(neuron), :)];
                end
                neuron_map = neurons;
            end
            [total_neurons, ~] = size(neuron_map);

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
            end

            % Creates the PSTH 
            event_struct.relative_response = event_spike_times(neuron_map(:,2), event_struct.all_events(:,2), ...
                total_trials, total_bins, bin_size, pre_time, post_time);
            event_struct.event_count = tabulate(events(:,1));
            try
                events_array = event_struct.all_events(:,2);
                event_count = 0;
                for event = 1: length(events_array)
                    event_struct.([event_strings{event}, '_raster']) = ...
                    sum(event_struct.relative_response((event_count + 1):1:(event_count + length(events_array{event})),:),1);
                    % Updates event_count to scale sum properly for next row
                    event_count = event_count + length(events_array{event});
                end
            catch ME
                warning('Error: %s\n', ME.message);
            end

            fprintf('Finished PSTH for %s\n', current_day);
            %% Saving the file
            filename = ['PSTH.format.', file_name, '.mat'];
            matfile = fullfile(psth_path, filename);
            save(matfile, 'event_struct', 'total_neurons', 'neuron_map', 'events', 'event_strings');
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