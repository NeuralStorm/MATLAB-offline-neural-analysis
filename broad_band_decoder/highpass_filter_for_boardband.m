function highpass_filtered_map = highpass_filter_for_boardband(board_band_map, highpass_filter_order, highpass_filter_fc, sample_rate)
    highpass_filtered_map = [];
    [tot_channel, ~] = size(board_band_map);
    for channel_index = 1:tot_channel                                 
        [highpass_filtered_data] = butterworth(highpass_filter_order, highpass_filter_fc/(sample_rate/2), ...
            'high', board_band_map{channel_index, 2});
        highpass_filtered_map = [highpass_filtered_map; {board_band_map{channel_index, 1}}, ...
            {highpass_filtered_data}];
    end
end