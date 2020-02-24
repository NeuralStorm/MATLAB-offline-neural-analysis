function [filtered_data] = butterworth(n_order, cutoff_freq, filter_type, raw_data)
    [z, p, k] = butter(n_order, cutoff_freq, filter_type);
    [sos, g] = zp2sos(z, p, k);
    filtered_data = filtfilt(sos, g, raw_data);
end