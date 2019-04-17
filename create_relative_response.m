function [population_response] = create_relative_response(neurons, all_events, bin_size, pre_time, post_time)
    %   spikes - rows are units(neurons) x columns are timestamps
    %   Converts the spikes into binned spike times in which each set of 100 columns
    %   is 1 neuron, and each row is a trial.

    event_window = -(abs(pre_time)) : bin_size : (abs(post_time));
    population_response = [];
    for unit = 1: length(neurons)
        unit_response = [];
        for event = 1: length(all_events)
            for trial = 1: length(all_events{event})
                offset = neurons{unit} - all_events{event}(trial)*ones(size(neurons{unit}));
                [offset_response, ~] = histcounts(offset, event_window);
                unit_response(end + 1, :) = offset_response';
            end
        end
        population_response = [population_response, unit_response];
    end
end