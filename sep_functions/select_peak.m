function [pos_peak, neg_peak, pos_peak_latency, neg_peak_latency, sig_response] = select_peak(...
        response, pos_thresh, neg_thresh, time_vec)
    [pos_peak, pos_peak_i]  = max(response);
    [neg_peak, neg_peak_i] = min(response);
    %!why were these -1 originally?
    pos_peak_latency = time_vec(pos_peak_i);
    neg_peak_latency = time_vec(neg_peak_i);

    early_pos_sep_valid = 1;
    if ~(pos_peak > pos_thresh)
        early_pos_sep_valid = 0;
        pos_peak = NaN;
        pos_peak_latency = NaN;
    end

    early_neg_sep_valid = 1;
    if ~(neg_peak < neg_thresh)
        early_neg_sep_valid = 0;
        neg_peak = NaN;
        neg_peak_latency = NaN;
    end

    sig_response = early_pos_sep_valid | early_neg_sep_valid;
end