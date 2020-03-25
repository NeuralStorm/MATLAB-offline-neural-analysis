function [response_struct] = OAT_create_relative_response(neurons, all_events, tot_bins, event_ts)
    %% Input parameters
    % neurons - column 1: unit label column 2: spike time cell array for unit label on same row
    % all_events - Same as neurons, but with events
    % tot_bins - number of bins in the histogram
    % event_ts - event timestamp matrix: 
        % Column 1: Event ID
        % Column 2: pre_time
        % Column 3: post_time

    %% Output
    % response_struct - layered struct that stores unit's response and psth for each event
    % and region response

    %event_window = -(abs(pre_time)):bin_size:(abs(post_time));
    %tot_bins = length(event_window) - 1;
    event_ts_master = event_ts;
    event_labels = all_events(:,1)';
    
    [tot_neurons, ~] = size(neurons);
    response_struct = struct;
    all_responses = [];
    for event = 1:length(event_labels)
        current_event = event_labels{event};
        event_split=strsplit(current_event,'_');
        event_num=str2num(event_split{2});
        event_ts = event_ts_master(event_ts_master(:,1)==event_num,:);
        tot_trials = length(event_ts(:,1));
        event_response = ones(tot_trials, (tot_neurons * tot_bins)) * -9;
        unit_start = 1;
        unit_end = tot_bins;
        for unit = 1:tot_neurons
            current_unit = neurons{unit, 1};
            neuron_ts = neurons{unit, 2};
            unit_response = ones(tot_trials, tot_bins);
            for trial = 1:tot_trials
                pre_time=0;
                post_time=event_ts(trial,3)-event_ts(trial,2);
                bin_size= (post_time - pre_time)/tot_bins;
                event_window = -(abs(pre_time)):bin_size:(abs(post_time));
                %% Offsets current trial by event time and bins response within event window
                offset_ts = neuron_ts - event_ts(trial,2)*ones(size(neuron_ts));
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