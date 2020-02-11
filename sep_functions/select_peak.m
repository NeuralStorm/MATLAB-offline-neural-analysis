function [pos_peak, neg_peak, pos_peak_latency, neg_peak_latency, ...
    sig_response] = select_peak(response, posthreshbackground, negthreshbackground, time_vec, window)
    [pos_peak, pos_peak_latency]  = max(response);
    [neg_peak, neg_peak_latency] = min(response);%%%what if response is entirely positive?
    pos_peak_latency = time_vec(window(1) + pos_peak_latency - 1);
    neg_peak_latency = time_vec(window(1) + neg_peak_latency - 1);

    if (pos_peak > posthreshbackground)
        early_pos_sep_valid = 1;
    else
        early_pos_sep_valid = 0;
        pos_peak = NaN;
        pos_peak_latency = NaN;
    end

    if (neg_peak < negthreshbackground)
        early_neg_sep_valid = 1;
    else
        early_neg_sep_valid = 0;
        neg_peak = NaN;
        neg_peak_latency = NaN;        
    end
    
    if (early_pos_sep_valid == 1 || early_neg_sep_valid == 1)
        sig_response = 1;
    else
        sig_response = 0;
    end


end
