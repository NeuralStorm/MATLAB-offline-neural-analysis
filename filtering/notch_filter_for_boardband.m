function notch_filtered_map = notch_filter_for_boardband(board_band_map, notch_filter_frequency, ...
    notch_filter_bandwidth, sample_rate, use_notch_bandstop)   
      notch_filtered_map = [];
    [~, tot_channel] = size(board_band_map);
    if use_notch_bandstop
        stopband = [notch_filter_frequency - notch_filter_bandwidth/2 ...
            notch_filter_frequency + notch_filter_bandwidth/2];
        parfor channel_index = 1:tot_channel    
            notch_filtered_data_map{channel_index} = bandstop(board_band_map(channel_index).data, stopband, sample_rate);
        end
        for channel_index = 1:tot_channel    
            notch_filtered_map = [notch_filtered_map; {board_band_map(channel_index).sig_channels}, ...
                {notch_filtered_data_map{channel_index}}];
        end
        
    else
        for channel_index = 1:tot_channel    
            notch_filtered_data = notch_filter(board_band_map(channel_index).data, sample_rate, ...
                notch_filter_frequency, notch_filter_bandwidth);
%             notch_filtered_map = [notch_filtered_map; {board_band_map(channel_index).data}, ...
%                 {notch_filtered_data}];
            
            board_band_map(channel_index).data = notch_filtered_data; 
            board_band_map(channel_index).notch = 1; 
        end
        notch_filtered_map = board_band_map; 
    end
end