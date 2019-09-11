function filtered_map = low_high_filt(data_map, sample_rate, filt_type, ...
        filt_freq, filt_order)
    filtered_map = [];
    [tot_channel, ~] = size(data_map);
    for channel_index = 1:tot_channel
        [filtered_channel] = butterworth(filt_order, filt_freq/(sample_rate/2), ...
            filt_type, data_map{channel_index, 2});
        filtered_map = [filtered_map; {data_map{channel_index, 1}}, ...
            {filtered_channel}];
    end
end