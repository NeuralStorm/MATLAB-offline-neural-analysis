function [pl, peak, corrected_peak, rm, corrected_rm] = calc_response_rf(...
        bfr, sig_psth, duration, bin_edges)
    %% Abbreviations: pl = peak latency rm = response magnitude
    [peak, peak_i] = max(sig_psth);
    pl = bin_edges(peak_i(1));
    corrected_peak = peak - bfr;
    rm = sum(sig_psth);
    corrected_rm = rm - (bfr * duration);
end