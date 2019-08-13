function [psth_struct] = split_relative_response(relative_response, col_labels, ...
        all_events, tot_bins)

    %% Create window and edges for PSTH
    psth_struct = struct;

    % Relative response: T X (N * B)
    tot_labels = length(col_labels);
    [tot_events, ~] = size(all_events);
    [~, tot_cols] = size(relative_response);
    assert((tot_labels * tot_bins) == tot_cols);

    event_start = 1;
    event_end = length(all_events{1, 2});
    for event_index = 1:tot_events
        % Event info
        event = all_events{event_index, 1};
        tot_event_trials = length(all_events{event_index, 2});
        %% Relative response has format of T X (N * B) and assumes that the trials
        % are grouped by event and organized alphabetically (ie: 1, 3, 4, etc)
        event_relative_response = relative_response(event_start:event_end, :);
        current_psth = sum(event_relative_response, 1) / tot_event_trials;

        %% Store relative response in event struct
        psth_struct.(event).relative_response = event_relative_response;
        psth_struct.(event).psth = current_psth;
        event_start = event_end + 1;
        if event_index + 1 < tot_events
            % Check to make sure event index is not pass total events
            event_end = event_end + length(all_events{event_index + 1, 2});
        end
        %% Split columns in relative response
        bin_start = 1;
        bin_end = tot_bins;
        for label_i = 1:tot_labels
            label = col_labels{label_i};
            label_response = event_relative_response(:, bin_start:bin_end);
            psth_struct.(event).(label).relative_response = label_response;
            psth_struct.(event).(label).psth = sum(label_response, 1) / tot_event_trials;
            bin_start = bin_end + 1;
            bin_end = bin_end + tot_bins;
        end
    end
end