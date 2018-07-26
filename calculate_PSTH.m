% TODO change calculate_PSTH name to format_PSTH
function [psth_path] = calculate_PSTH(parsed_path, animal_name, total_bins, bin_size, pre_time, post_time, ...
                            wanted_neurons, wanted_events, trial_range)
    tic;
    % Grabs all .mat files in the parsed plx directory
    parsed_mat_path = strcat(parsed_path, '/*.mat');
    parsed_files = dir(parsed_mat_path);
    
    % Checks and creates a psth directory if it does not exists
    psth_path = strcat(parsed_path, '/psth');
    if ~exist(psth_path, 'dir')
       mkdir(parsed_path, 'psth');
    end

    event_strings = {};
    for i = 1: length(wanted_events)
        event_strings{end+1} = ['event_', num2str(wanted_events(i))];
    end
    
    for h = 1: length(parsed_files)
        file = [parsed_path, '/', parsed_files(h).name];
        seperated_file_name = strsplit(parsed_files(h).name, '.');
        current_day = seperated_file_name{4};
        fprintf('Calculating PSTH for %s on %s\n', animal_name, current_day);
        load(file);
        
        for i = 1: length(wanted_events)
            %% Slices out the desired neurons from all_spike_times and puts them into
            %% the neuron matrix
            neurons = [];
            if isempty(wanted_neurons)
                neurons = all_spike_times;
            else
                for neuron = length(wanted_neurons)
                    neurons = [neurons; all_spike_times(wanted_neurons(neuron), :)];
                end
            end
            %% Slices out the desired trials from the events matrix (Inclusive range)
            events = events(trial_range(1):trial_range(2), :);
            %% Selects the desired events from the events matrix and puts them into an event_struct
            event_struct.(event_strings{i}) = events(find(events == wanted_events(i)), 2);
            event_struct.('total_count') = tabulate(events(:,1));
            %% Creates the psth format and adds them to the event_struct
            event_struct.([event_strings{i}, '_rel_spikes']) = ...
                event_spike_times(event_struct.(event_strings{i}), ...
                neurons, total_bins, bin_size, pre_time, post_time);
            event_struct.([event_strings{i}, '_raster']) = ...
                sum(event_struct.([event_strings{i}, '_rel_spikes']));
        end
        
        %% Concates all relative events together into a combined matrix of all events
        % Total relative spikes is the (# trials)x(bins*neurons) matrix
        % which has each event trial for each neuron with data put in the #
        % of total bins defined by the window given by the pre and post
        % times and stepped by the bin size
        struct_names = fieldnames(event_struct);
        combined_rel_event_spikes = [];
        for i = 1: length(struct_names)
            if contains(struct_names{i}, '_rel_spikes')
                event_struct.combined_rel_event_spikes = ...
                    [combined_rel_event_spikes; getfield(event_struct, struct_names{i})];                            
            end
        end
        fprintf('Finished PSTH for %s\n', current_day);
        %% Saving the file
        [~ ,namestr, ~] = fileparts(file);
        filename = strcat('PSTH.format.', namestr);
        filename = strcat(filename, '.mat');
        matfile = fullfile(psth_path, filename);
        save(matfile, 'event_struct', 'total_neurons');
    end
    toc;
end