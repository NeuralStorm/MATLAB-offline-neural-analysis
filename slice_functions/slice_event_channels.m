function [event_struct] = slice_event_channels(event_struct, chan_s, chan_e)
    unique_events = fieldnames(event_struct);
    for event_i = 1:numel(unique_events)
        event = unique_events{event_i};
        event_struct.(event).relative_response = event_struct.(event).relative_response(:, chan_s:chan_e);
        event_struct.(event).psth = event_struct.(event).psth(chan_s:chan_e);
    end
end