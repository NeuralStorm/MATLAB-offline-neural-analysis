function [population_response] = event_spike_times(neurons, all_events, total_trials, total_bins, bin_size, pre_time, post_time)
    %   spikes - rows are units(neurons) x columns are timestamps
    %   Converts the spikes into binned spike times in which each set of 100 columns
    %   is 1 neuron, and each row is a trial.

    event_window = -(abs(pre_time)) : bin_size : (abs(post_time));
    population_response = [];
    for unit = 1: length(neurons)
        unit_response = [];
        for event = 1: length(all_events)
            % TODO change total_trials to scale with length of actual events created
            % TODO after truncating events to trial range -> Potentially change the creation of all_events to fix
            % TODO and take the length of each cell of all events instead
            for trial = 1: length(all_events{event})
                offset = neurons{unit} - all_events{event}(trial)*ones(size(neurons{unit}));
                offset_response = histc(offset, event_window);
                offset_response(end) = [];
                unit_response(end + 1, :) = offset_response';
            end
        end
        population_response = [population_response, unit_response];
    end
end