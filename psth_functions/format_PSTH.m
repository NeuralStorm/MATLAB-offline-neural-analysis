function [psth_struct, event_ts] = format_PSTH(...
        event_ts, labeled_data, bin_size, pre_time, post_time, wanted_events, trial_range, trial_lower_bound)

    psth_struct = struct;

    %% Organize and group timestamps
    [~, all_events, event_ts] = organize_events(event_ts, ...
        trial_lower_bound, trial_range, wanted_events);
    psth_struct.all_events = all_events;

    %% Creates the PSTH
    unique_regions = fieldnames(labeled_data);
    for region = 1:length(unique_regions)
        region_name = unique_regions{region};
        % region_neurons = [labeled_data.(region_name)(:,1), labeled_data.(region_name)(:,4)];
        region_neurons = [labeled_data.(region_name).sig_channels, labeled_data.(region_name).channel_data];
        region_response = create_relative_response(region_neurons, psth_struct.all_events, ...
            bin_size, pre_time, post_time);
        psth_struct.(region_name) = region_response;
    end
end