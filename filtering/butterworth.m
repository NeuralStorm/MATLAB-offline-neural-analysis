function [filtered_data] = butterworth(n_order, cutoff_freq, filter_type, raw_data)
    [b,a] = butter(n_order, cutoff_freq, filter_type);
    filtered_data = filtfilt(b, a, raw_data);
end