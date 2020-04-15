function [psth_struct, event_ts, label_log] = format_PSTH(...
        event_ts, selected_data, bin_size, window_start, window_end, wanted_events, trial_range, trial_lower_bound)

    psth_struct = struct;

    %% Organize and group timestamps
    [~, all_events, event_ts] = organize_events(event_ts, ...
        trial_lower_bound, trial_range, wanted_events);
    psth_struct.all_events = all_events;

    %% Creates the PSTH
    unique_regions = fieldnames(selected_data);
    label_log = struct;
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        region_neurons = [selected_data.(region).sig_channels, selected_data.(region).channel_data];
        region_response = create_relative_response(region_neurons, psth_struct.all_events, ...
            bin_size, window_start, window_end);
        psth_struct.(region) = region_response;

        %% Create label log
        region_table = selected_data.(region);
        region_log = region_table(:, ~strcmpi(region_table.Properties.VariableNames, 'channel_data'));
        label_log.(region) = region_log;
    end
end