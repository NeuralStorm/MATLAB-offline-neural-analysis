function [event_struct] = create_event_struct(psth_struct, event_info, ...
        bin_size, window_start, window_end, new_start, new_end)

    unique_features = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    event_struct = struct;
    for feature_i = 1:numel(unique_features)
        feature = unique_features{feature_i};
        for event_i = 1:numel(unique_events)
            event = unique_events{event_i};
            event_indices = event_info.event_indices(...
                strcmpi(event_info.event_labels, event));

            label_order = psth_struct.(feature).label_order;
            tot_labels = numel(label_order);
            rr = psth_struct.(feature).relative_response(event_indices, :);
            event_response = slice_rr(rr, tot_labels, bin_size, window_start, ...
                window_end, new_start, new_end);
            event_struct.(feature).(event).label_order = label_order;
            event_struct.(feature).(event).relative_response = event_response;
            event_struct.(feature).(event).psth = calc_psth(event_response, numel(event_indices));
        end
    end
end