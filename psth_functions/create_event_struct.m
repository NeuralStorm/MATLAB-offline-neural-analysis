function [event_struct] = create_event_struct(psth_struct, event_info, ...
        bin_size, window_start, window_end, new_start, new_end)

    unique_events = unique(event_info.event_labels);
    event_struct = struct;
    for event_i = 1:numel(unique_events)
        event = unique_events{event_i};
        event_indices = event_info.event_indices(...
            strcmpi(event_info.event_labels, event));

        label_order = psth_struct.label_order;
        rr = psth_struct.relative_response(event_indices, :);
        event_response = slice_rr(rr, bin_size, window_start, ...
            window_end, new_start, new_end);
        event_struct.(event).label_order = label_order;
        event_struct.(event).relative_response = event_response;
        event_struct.(event).psth = calc_psth(event_response);
    end
end