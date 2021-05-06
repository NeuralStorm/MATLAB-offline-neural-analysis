function [psth_struct, event_info] = format_PSTH(event_info, ...
        selected_channels, bin_size, window_start, window_end)
    %%Inputs
    % event_info: table with columns event_labels, event_indices, and event_ts
    % selected_data: struct with fields chan_group
    %                chan_group fields: table with information of channels selected for psth
    % window_start: start time of window
    % window_end: end time of window
    % bin_size: size of bin
    %% Output
    % psth_struct: struct with fields chan_group
    %              chan_group fields: relative_response, label_order
    %              relative_response dimension: Trials (rows) x Neurons * Bins (columns)
    %              label_order: list of channels in relative response
    % event_info: event_info table above, but filtered according to include_events and trial_range

    psth_struct = struct;

    %% Creates the PSTH
    unique_ch_groups = unique(selected_channels.chan_group);
    [bin_edges, ~] = get_bins(window_start, window_end, bin_size);
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        group_chans = selected_channels.channel_data(strcmpi(selected_channels.chan_group, ch_group));
        %% create relative response for chan_group neurons
        rr = create_relative_response(group_chans, event_info.event_ts, bin_edges);
        %% store relative response and labels in chan_group struct
        psth_struct.(ch_group).relative_response = rr;
        psth_struct.(ch_group).chan_order = selected_channels.channel(strcmpi(selected_channels.chan_group, ch_group));
    end
end