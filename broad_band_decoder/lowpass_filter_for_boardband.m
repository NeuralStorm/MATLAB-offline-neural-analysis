function lowpass_filtered_map = lowpass_filter_for_boardband(board_band_map, lowpass_filter_order, lowpass_filter_fc, sample_rate)
    lowpass_filtered_map = [];
    [tot_channel, ~] = size(board_band_map);
    for channel_index = 1:1     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%channel_index = 1:tot_channel                            
        [lowpass_filtered_data] = butterworth(lowpass_filter_order, lowpass_filter_fc/(sample_rate/2), ...
            'low', board_band_map{channel_index, 2});
        lowpass_filtered_map = [lowpass_filtered_map; {board_band_map{channel_index, 1}}, ...
            {lowpass_filtered_data}];
    end
end