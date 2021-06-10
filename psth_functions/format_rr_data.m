function rr_data = format_rr_data(event_info, selected_channels, bin_size, ...
        window_start, window_end)
    %%Inputs
    % event_info: table with columns event_labels, event_indices, and event_ts
    % selected_data: struct with fields chan_group
    %                chan_group fields: table with information of channels selected for psth
    % window_start: start time of window
    % window_end: end time of window
    % bin_size: size of bin
    %% Output
    % rr_data: struct with fields chan_group
    %              chan_group fields: relative_response, chan_order
    %              relative_response dimension: Trials (rows) x chans * Bins (columns)
    %              chan_order: list of channels in relative response
    % event_info: event_info table above, but filtered according to include_events and trial_range

    rr_data = struct;

    %% Creates the PSTH
    unique_ch_groups = unique(selected_channels.chan_group);
    [bin_edges, ~] = get_bins(window_start, window_end, bin_size);
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        chan_list = selected_channels.channel_data(strcmpi(selected_channels.chan_group, ch_group));
        %% create relative response for chan_group chans
        rr = calc_rr(chan_list, event_info.event_ts, bin_edges);
        %% store relative response and labels in chan_group struct
        rr_data.(ch_group).relative_response = rr;
        rr_data.(ch_group).chan_order = selected_channels.channel(strcmpi(selected_channels.chan_group, ch_group));
    end
end

function [rr] = calc_rr(chan_ts, event_ts, bin_edges)
    %% Input parameters
    % chan_ts - column 1: spike times for all channels
    % event_ts - list of trial timestamps
    % bin_edges: defined by window_start and window_end, stepped by bin_size
    %% Output
    % rr: relative response matrix
    %     dimension: Trials (rows) x chans * Bins (columns)

    tot_bins = numel(bin_edges) - 1;
    tot_trials = numel(event_ts);
    [tot_chans, ~] = size(chan_ts);
    rr = nan(tot_trials, (tot_chans * tot_bins));
    for trial_i = 1:length(event_ts)
        %% Iterate through trial timestamps
        chan_s = 1;
        chan_e = tot_bins;
        trial_ts = event_ts(trial_i);
        for chan_i = 1:tot_chans
            %% Iterate through chans
            spike_ts = chan_ts{chan_i};
            %% Offsets spike times and then bin spikes within window
            offset_ts = spike_ts - trial_ts;
            [binned_response, ~] = histcounts(offset_ts, bin_edges);
            % Transpose taken to make binned_response row major instead of column major
            rr(trial_i, chan_s:chan_e) = binned_response';
            %% Update index counters
            chan_s = chan_s + tot_bins;
            chan_e = chan_e + tot_bins;
        end
    end
end