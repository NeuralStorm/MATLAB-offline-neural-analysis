function [mnts_struct, event_info, selected_channels] = format_mnts(...
    event_info, selected_channels, bin_size, window_start, window_end)

    mnts_struct = struct;
    [bin_edges, tot_bins] = get_bins(window_start, window_end, bin_size);

    tot_trials = height(event_info);

    unique_regions = unique(selected_channels.label);
    for reg_i = 1:length(unique_regions)
        region = unique_regions{reg_i};
        region_channels = selected_channels(strcmpi(selected_channels.label, region), :);
        tot_chans = height(region_channels);
        mnts = nan((tot_bins * tot_trials), tot_chans);

        for chan_i = 1:tot_chans
            spike_ts = region_channels.channel_data{chan_i};
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
        remove_units = [];
        channel_list = [];
        for col = 1:mnts_cols
            unique_response = unique(mnts(:, col));
            if length(unique_response) == 1
                channel_list = [channel_list, region_channels.sig_channels(col)];
                remove_units = [remove_units; col];
            end
        end
        if ~isempty(remove_units)
            %% Remove empty channels
            selected_channels = selected_channels(~ismember(selected_channels.sig_channels, channel_list), :);
            region_channels = region_channels(~ismember(region_channels.sig_channels, channel_list), :);
            mnts(:, remove_units) = [];
        end
        %% Store mnts
        mnts_struct.(region).mnts = mnts;
        mnts_struct.(region).chan_order = region_channels.sig_channels;
    end
end