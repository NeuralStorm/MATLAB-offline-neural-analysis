function [rel_spikes] = event_spike_times(events, spikes, total_bins, bin_size, pre_time, post_time)
    %   spikes - rows are units(neurons) x columns are timestamps
    %   Converts the spikes into binned spike times in which each set of 100 columns
    %   is 1 neuron, and each row is a trial.

    [spike_rows, spike_cols] = size(spikes);

    % Iterates through all the rows (neurons)
    for row = 1: spike_rows
        % Iterates through all the event times
        for event = 1: length(events)
            event_rel_response = zeros(1, total_bins);
            % Creates the window for the neuron response around the event
            window_start = events(event) - abs(pre_time);
            window_end = events(event) + abs(post_time);
            % neuron_response is used to store the spikes occuring in the
            % relative window to the given event
            neuron_respone = [];
            % Iterates through all the spike times of a given neuron to the given
            % events
            for col = 1: spike_cols
                % Checks if each spike time occurs in window
                if (spikes(row, col) >= window_start) && (spikes(row, col) <= window_end)
                     % Normalize the spikes times between window defined by
                     % pre and post time
                    neuron_respone = [neuron_respone, (spikes(row, col) - events(event))];
                end
            end
            % Creates the window (an array from pre_time to post_time stepping
            % by bin size)
            event_window = -(abs(pre_time)) : bin_size : (abs(post_time));
            % Includes extra 5ms buffer to deal with spikes that occur on an
            % absolute edge
            event_window(1) = -(abs(event_window(1)) + 0.005);
            event_window(end) = (abs(event_window(end)) + 0.005);
            % discretize takes the neuron_response array (filled with the
            % normalized spike times) and puts them into the respective bins
            % that they belong to (based on bin_size)
            spike_indices = discretize(neuron_respone, event_window);
            if ~isempty(spike_indices)
                % Iterates through the zero padded event_rel_response array and changes the
                % indices to a 1 if there was a spike 
                for spike_index = 1:length(spike_indices)
                    event_rel_response(1, spike_indices(spike_index)) = 1;
                end
            end
            rel_response_dimensions = size(event_rel_response);
            % Creates the final relative spikes that is ultimately returned
            rel_spikes(event, ((1:rel_response_dimensions(2)) + ((row - 1) * length(event_rel_response)))) = ...
                [event_rel_response(1, 1:rel_response_dimensions(2))];
        end    
    end
end