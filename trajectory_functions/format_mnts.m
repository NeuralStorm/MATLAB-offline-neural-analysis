function [mnts_struct, event_info, selected_channels] = format_mnts(...
    event_info, selected_channels, bin_size, window_start, window_end)

    mnts_struct = struct;
    [bin_edges, tot_bins] = get_bins(window_start, window_end, bin_size);

    tot_trials = height(event_info);

    unique_ch_groups = unique(selected_channels.chan_group);
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        chan_list = selected_channels(strcmpi(selected_channels.chan_group, ch_group), :);
        tot_chans = height(chan_list);
        mnts = nan((tot_bins * tot_trials), tot_chans);

        for chan_i = 1:tot_chans
            spike_ts = chan_list.channel_data{chan_i};
            trial_s = 1;
            trial_e = tot_bins;
            for trial_i = 1:tot_trials
                trial_ts = event_info.event_ts(trial_i);
                %% Offsets spike times and then bin spikes within window
                offset_ts = spike_ts -trial_ts;
                [binned_response, ~] = histcounts(offset_ts, bin_edges);
                mnts(trial_s:trial_e, chan_i) = binned_response';
                %% Update index counters
                trial_s = trial_s + tot_bins;
                trial_e = trial_e + tot_bins;
            end
        end

        %% Find channels with no spikes
        [~, mnts_cols] = size(mnts);
        remove_chans = [];
        channel_list = [];
        for col = 1:mnts_cols
            unique_response = unique(mnts(:, col));
            if length(unique_response) == 1
                channel_list = [channel_list, chan_list.channel(col)];
                remove_chans = [remove_chans; col];
            end
        end
        if ~isempty(remove_chans)
            %% Remove empty channels
            selected_channels = selected_channels(~ismember(selected_channels.channel, channel_list), :);
            chan_list = chan_list(~ismember(chan_list.channel, channel_list), :);
            mnts(:, remove_chans) = [];
        end
        %% Store mnts
        mnts_struct.(ch_group).mnts = mnts;
        mnts_struct.(ch_group).orig_chan_order = chan_list.channel;
    end
end