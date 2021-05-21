function [sep_res] = sep_analysis(sep_data, event_info, window_s, window_e, base_s, ...
        base_e, early_res_s, early_res_e, late_res_s, late_res_e, threshold_scalar)
    %% Create sep table
    headers = [["chan_group", "string"]; ["channel", "string"]; ...
                   ["event", "string"]; ["sep_sliced_data", "double"]; ...
                   ["posthresh", "double"]; ["negthresh", "double"]; ...
                   ["neg_peak1", "double"]; ["neg_peak_latency1", "double"]; ...
                   ["pos_peak1", "double"]; ["pos_peak_latency1", "double"]; ...
                   ["sig_early", "double"]; ["neg_peak2", "double"]; ...
                   ["neg_peak_latency2", "double"]; ["pos_peak2", "double"]; ...
                   ["pos_peak_latency2", "double"]; ["sig_late", "double"]; ...
                   ["neg_peak3", "double"]; ["pos_peak3", "double"]; ...
                   ["neg_peak_latency3", "double"]; ["pos_peak_latency3", "cell"]; ...
                   ["sig_response", "double"]; ["background", "double"]; ...
                   ["background_sd", "cell"]];
    sep_res = prealloc_table(headers, [0, size(headers, 1)]);

    %% Get unique chan groups and calculate total bins
    unique_ch_groups = fieldnames(sep_data);
    [~, tot_cols] = size(sep_data.(unique_ch_groups{1}).sep);
    tot_chans = numel(sep_data.(unique_ch_groups{1}).chan_order);
    tot_bins = tot_cols / tot_chans;
    bin_size = 1/tot_bins;

    %% Create time vector for sliced window
    time_vec = linspace((window_s*1000), (window_e*1000), tot_bins);
    eary_res_t = time_vec((time_vec >= (early_res_s * 1000)) & (time_vec <= (early_res_e * 1000)));
    late_res_t = time_vec((time_vec >= (late_res_s * 1000)) & (time_vec <= (late_res_e * 1000)));

    unique_events = unique(event_info.event_labels);
    tot_events = numel(unique_events);
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        tot_chans = numel(sep_data.(ch_group).chan_order);

        chan_s = 1;
        chan_e = tot_bins;
        for chan_i = 1:tot_chans
            chan = sep_data.(ch_group).chan_order{chan_i};

            for event_i = 1:tot_events
                event = unique_events{event_i};
                event_indices = event_info.event_indices(strcmpi(event_info.event_labels, event), :);
                chan_rr = sep_data.(ch_group).sep(event_indices, chan_s:chan_e);
                sep = calc_psth(chan_rr);

                %% Baseline SEP
                baseline_sep = slice_rr(sep, bin_size, window_s, window_e, base_s, base_e);
                [avg_bfr, bfr_std, pos_thresh, neg_thresh] = ...
                    get_threshold(baseline_sep, threshold_scalar);

                %% early response
                early_sep = slice_rr(sep, bin_size, window_s, window_e, early_res_s, early_res_e);
                [early_pos_peak, early_neg_peak, early_pos_pl, early_neg_pl, sig_early] = ...
                    select_peak(early_sep, pos_thresh, neg_thresh, eary_res_t);

                %% late window
                late_sep = slice_rr(sep, bin_size, window_s, window_e, late_res_s, late_res_e);
                [late_pos_peak, late_neg_peak, late_pos_pl, late_neg_pl, sig_late] = ...
                    select_peak(late_sep, pos_thresh, neg_thresh, late_res_t);

                sig_response = sig_early | sig_late;


                %TODO store results in table
                a = [{ch_group}, {chan}, {event}, {sep}, pos_thresh, neg_thresh, ...
                    early_neg_peak, early_neg_pl, early_pos_peak, early_pos_pl, ...
                    sig_early, late_neg_peak, late_neg_pl, late_pos_peak, late_pos_pl, ...
                    sig_late, NaN, NaN, NaN, NaN, sig_response, avg_bfr, bfr_std];
                sep_res = vertcat_cell(sep_res, a, headers(:, 1), "after");
            end
            %% Update channel counter
            chan_s = chan_s + tot_bins;
            chan_e = chan_e + tot_bins;
        end
    end
end

function [avg_bfr, bfr_std, pos_thresh, neg_thresh] = get_threshold(baseline_psth, threshold_scalar)
    avg_bfr = mean(baseline_psth);
    bfr_std = std(baseline_psth);
    pos_thresh = avg_bfr + (threshold_scalar * bfr_std);
    neg_thresh = avg_bfr - (threshold_scalar * bfr_std);
end