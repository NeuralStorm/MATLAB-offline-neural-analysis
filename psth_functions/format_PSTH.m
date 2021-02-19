function [psth_struct, event_info, label_log] = format_PSTH(event_info, ...
        selected_data, bin_size, window_start, window_end, wanted_events, ...
        trial_range)
    %%Inputs
    % event_info: table with columns event_labels, event_indices, and event_ts
    % selected_data: struct with fields regions
    %                region fields: table with information of channels selected for psth
    % include_events: list of events desired to be analyzed.
    %                 Must be of same type as event_labels
    % trial range: numeric range of which trials to be analyzed
    % window_start: start time of window
    % window_end: end time of window
    % bin_size: size of bin
    %% Output
    % psth_struct: struct with fields regions
    %              region fields: relative_response, label_order
    %              relative_response dimension: Trials (rows) x Neurons * Bins (columns)
    %              label_order: list of channels in relative response
    % event_info: event_info table above, but filtered according to wanted_events and trial_range
    % label_log: similiar to selected_data, but saved as a log of channels

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
        %% create relative response for region neurons
        rr = create_relative_response(region_neurons, event_info.event_ts, bin_edges);
        %% store relative response and labels in region struct
        psth_struct.(region).relative_response = rr;
        psth_struct.(region).label_order = selected_data.(region).sig_channels;

        %% Create label log
        region_table = selected_data.(region);
        region_log = region_table(:, ~strcmpi(region_table.Properties.VariableNames, 'channel_data'));
        label_log.(region) = region_log;
    end
end