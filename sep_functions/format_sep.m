function sep_data = format_sep(chan_table, event_info, ...
        sample_rate, window_s, window_e)

    sep_data = struct;
    %% Calc sample edges
    window_s = window_s * sample_rate;
    window_e = window_e * sample_rate;
    [bin_edges, ~] = get_bins(window_s, window_e, 1);
    %% Creates the PSTH
    unique_ch_groups = unique(chan_table.chan_group);
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        chan_list = chan_table.channel_data(strcmpi(chan_table.chan_group, ch_group), :);
        %% create relative response for chan_group chans
        sep = calc_sep(chan_list, event_info.event_ts, bin_edges);
        %% store relative response and labels in chan_group struct
        sep_data.(ch_group).sep = sep;
        sep_data.(ch_group).chan_order = chan_table.channel(strcmpi(chan_table.chan_group, ch_group));
    end
end

function [sep] = calc_sep(chan_list, trial_list, edges)
    tot_bins = numel(edges);
    tot_trials = numel(trial_list);
    [tot_chans, ~] = size(chan_list);
    sep = nan(tot_trials, (tot_chans * tot_bins));
    for trial_i = 1:tot_trials
        chan_s = 1;
        chan_e = tot_bins;
        trial_bins = trial_list(trial_i) + edges;
        for chan_i = 1:tot_chans
            sep(trial_i, chan_s:chan_e) = chan_list(chan_i, trial_bins);
            %% Update index counters
            chan_s = chan_s + tot_bins;
            chan_e = chan_e + tot_bins;
        end
    end
end