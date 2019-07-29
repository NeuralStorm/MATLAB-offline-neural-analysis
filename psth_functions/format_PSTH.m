function [event_struct, event_ts, event_strings] = format_PSTH(...
        event_ts, labeled_neurons, bin_size, pre_time, post_time, wanted_events, trial_range, trial_lower_bound)
    if abs(pre_time) > 0
        pre_time_bins = (length(-abs(pre_time): bin_size: 0)) - 1;
    else
        pre_time_bins = 0;
    end
    post_time_bins = (length(0:bin_size:post_time)) - 1;

    event_struct = struct;

    %% Organize and group timestamps
    [event_strings, all_events, event_ts] = organize_events(event_ts, ...
        trial_lower_bound, trial_range, wanted_events);
    event_struct.all_events = all_events;

    %% Creates the PSTH
    unique_regions = fieldnames(labeled_neurons);
    for region = 1:length(unique_regions)
        region_name = unique_regions{region};
        region_neurons = [labeled_neurons.(region_name)(:,1), labeled_neurons.(region_name)(:,4)];
        region_response = create_relative_response(region_neurons, event_struct.all_events, ...
            bin_size, pre_time, post_time);

        for event = 1:length(event_strings)
            current_event = event_strings{event};
            current_psth = region_response.(current_event).psth;
            [pre_time_activity, post_time_activity] = split_psth(current_psth, pre_time, pre_time_bins, post_time_bins);
            region_response.(current_event).norm_pre_time_activity = pre_time_activity;
            region_response.(current_event).norm_post_time_activity = post_time_activity;
        end
        event_struct.(region_name) = region_response;
    end
end