function [event_struct] = split_relative_response(relative_response, col_labels, ...
        all_events, bin_size, pre_time, post_time)
    event_struct = struct;
    event_window = -(abs(pre_time)):bin_size:(abs(post_time));
    tot_bins = length(event_window) - 1;
    if abs(pre_time) > 0
        pre_time_bins = (length(-abs(pre_time): bin_size: 0)) - 1;
    else
        pre_time_bins = 0;
    end
    post_time_bins = (length(0:bin_size:post_time)) - 1;

    % Relative response: T X (N * B)
    tot_labels = length(col_labels);
    [tot_events, ~] = size(all_events);
    [~, tot_cols] = size(relative_response);
    assert((tot_labels * tot_bins) == tot_cols);

    event_start = 1;
    event_end = length(all_events{1, 2});
    for event_index = 1:tot_events
        event = all_events{event_index, 1};
        tot_event_trials = length(all_events{event_index, 2});
        event_relative_response = relative_response(event_start:event_end, :);
        current_psth = sum(event_relative_response, 1) / tot_event_trials;
        [pre_time_activity, post_time_activity] = split_psth(current_psth, pre_time, pre_time_bins, post_time_bins);
        event_struct.(event).norm_pre_time_activity = pre_time_activity;
        event_struct.(event).norm_post_time_activity = post_time_activity;
        event_struct.(event).relative_response = event_relative_response;
        event_struct.(event).psth = current_psth;
        event_start = event_end + 1;
        if event_index + 1 < tot_events
            event_end = event_end + length(all_events{event_index + 1, 2});
        end
        %% Split columns in relative response
        bin_start = 1;
        bin_end = tot_bins;
        for label_i = 1:tot_labels
            label = col_labels{label_i};
            label_response = event_relative_response(:, bin_start:bin_end);
            event_struct.(event).(label).relative_response = label_response;
            event_struct.(event).(label).psth = sum(label_response, 1) / tot_event_trials;
            bin_start = bin_end + 1;
            bin_end = bin_end + tot_bins;
        end
    end
end