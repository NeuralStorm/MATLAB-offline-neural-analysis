function [event_struct] = create_event_response(psth_struct, event_info)

    unique_features = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    event_struct = struct;
    for feature_i = 1:numel(unique_features)
        feature = unique_features{feature_i};
        for event_i = 1:numel(unique_events)
            event = unique_events{event_i};
            event_indices = event_info.event_indices(...
                strcmpi(event_info.event_labels, event));
            event_response = psth_struct.(feature).relative_response(event_indices, :);
            event_struct.(feature).(event).label_order = psth_struct.(feature).label_order;
            event_struct.(feature).(event).relative_response = event_response;
            event_struct.(feature).(event).psth = calc_psth(event_response, numel(event_indices));
        end
    end
end