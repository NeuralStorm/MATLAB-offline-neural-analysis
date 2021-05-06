function [event_struct] = create_event_struct(rr_data, event_info, ...
        bin_size, window_start, window_end, new_start, new_end)

    unique_events = unique(event_info.event_labels);
    event_struct = struct;
    for event_i = 1:numel(unique_events)
        event = unique_events{event_i};
        event_indices = event_info.event_indices(...
            strcmpi(event_info.event_labels, event));

        chan_order = rr_data.chan_order;
        rr = rr_data.relative_response(event_indices, :);
        event_response = slice_rr(rr, bin_size, window_start, ...
            window_end, new_start, new_end);
        event_struct.(event).chan_order = chan_order;
        event_struct.(event).relative_response = event_response;
        event_struct.(event).psth = calc_psth(event_response);
    end
end