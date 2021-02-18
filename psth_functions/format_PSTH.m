function [psth_struct, event_info, label_log] = format_PSTH(event_info, ...
        selected_data, bin_size, window_start, window_end, wanted_events, ...
        trial_range)
    %TODO add documentation on inputs and outputs

    psth_struct = struct;

    %% Filter events
    event_info = filter_events(event_info, wanted_events, trial_range);

    %% Creates the PSTH
    unique_regions = fieldnames(selected_data);
    label_log = struct;
    [bin_edges, ~] = get_bins(window_start, window_end, bin_size);
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        region_neurons = [selected_data.(region).sig_channels, selected_data.(region).channel_data];
        rr = create_relative_response(region_neurons, event_info.event_ts, bin_edges);
        psth_struct.(region).relative_response = rr;
        %TODO add other fields needed for psth_struct

        %% Create label log
        region_table = selected_data.(region);
        region_log = region_table(:, ~strcmpi(region_table.Properties.VariableNames, 'channel_data'));
        label_log.(region) = region_log;
    end
end