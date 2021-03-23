function [psth_struct, event_info] = format_PSTH(event_info, ...
        selected_channels, bin_size, window_start, window_end)
    %%Inputs
    % event_info: table with columns event_labels, event_indices, and event_ts
    % selected_data: struct with fields regions
    %                region fields: table with information of channels selected for psth
    % window_start: start time of window
    % window_end: end time of window
    % bin_size: size of bin
    %% Output
    % psth_struct: struct with fields regions
    %              region fields: relative_response, label_order
    %              relative_response dimension: Trials (rows) x Neurons * Bins (columns)
    %              label_order: list of channels in relative response
    % event_info: event_info table above, but filtered according to include_events and trial_range

    psth_struct = struct;

    %% Creates the PSTH
    unique_regions = unique(selected_channels.label);
    [bin_edges, ~] = get_bins(window_start, window_end, bin_size);
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        region_neurons = selected_channels.channel_data(strcmpi(selected_channels.label, region));
        %% create relative response for region neurons
        rr = create_relative_response(region_neurons, event_info.event_ts, bin_edges);
        %% store relative response and labels in region struct
        psth_struct.(region).relative_response = rr;
        psth_struct.(region).label_order = selected_channels.sig_channels(strcmpi(selected_channels.label, region));
    end
end