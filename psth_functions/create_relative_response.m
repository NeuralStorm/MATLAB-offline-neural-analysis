function [response_struct] = create_relative_response(neurons, all_events, bin_size, pre_time, post_time)
    %% Input parameters
    % neurons - column 1: unit label column 2: spike time cell array for unit label on same row
    % all_events - Same as neurons, but with events
    % bin_size - size of bin
    % pre_time - pre time window
    % post_time - post time window

    %% Output
    % response_struct - layered struct that stores unit's response and psth for each event
    % and region response

    event_window = -(abs(pre_time)):bin_size:(abs(post_time));
    tot_bins = length(event_window) - 1;
    event_labels = all_events(:,1)';
    [tot_neurons, ~] = size(neurons);
    response_struct = struct;
    all_responses = [];
    for event = 1:length(event_labels)
        current_event = event_labels{event};
        event_ts = all_events{event, 2};
        tot_trials = length(event_ts);
        event_response = zeros(tot_trials, (tot_neurons * tot_bins));
        unit_start = 1;
        unit_end = tot_bins;
        for unit = 1:tot_neurons
            current_unit = neurons{unit, 1};
            neuron_ts = neurons{unit, 2};
            unit_response = zeros(tot_trials, tot_bins);
            for trial = 1:tot_trials
                %% Offsets current trial by event time and bins response within event window
                offset_ts = neuron_ts - event_ts(trial)*ones(size(neuron_ts));
                [offset_response, ~] = histcounts(offset_ts, event_window);
                unit_response(trial, 1:tot_bins) = offset_response';
            end
            %% Create current unit's response in event response
            % dimension: event trials X (Units * bins)
            event_response(:, unit_start:unit_end) = unit_response;
            response_struct.(current_event).(current_unit).relative_response = unit_response;
            response_struct.(current_event).(current_unit).psth = sum(unit_response, 1) / tot_trials;
            unit_start = unit_start + tot_bins;
            unit_end = unit_end + tot_bins;
        end
        %% Store all event responses in a single matrix for entire region response across all events
        all_responses = [all_responses; event_response];
        response_struct.(current_event).relative_response = event_response;
        response_struct.(current_event).psth = sum(event_response, 1) / tot_trials;
    end
    response_struct.relative_response = all_responses;
end