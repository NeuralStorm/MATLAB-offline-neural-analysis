function bandpass_filtered_map = bandpass_filter_for_boardband(board_band_map, bandpass_filter_order, bandpass_filter_low_fc, bandpass_filter_high_fc, sample_rate)
    bandpass_filtered_map = [];
    [~, tot_channel] = size(board_band_map);
    parfor channel_index = 1:tot_channel
%         [highpass_filtered_data] = butterworth(bandpass_filter_order, ...
%             [bandpass_filter_low_fc/(sample_rate/2) bandpass_filter_high_fc/(sample_rate/2)], ...
%             'bandpass', double(board_band_map{channel_index, 2}));
        [z, p, k] = butter(bandpass_filter_order ,...
            [bandpass_filter_low_fc/(sample_rate/2) bandpass_filter_high_fc/(sample_rate/2)], 'bandpass');
        [sos, g] = zp2sos(z, p, k);
        bandpass_filtered_data = filtfilt(sos, g, board_band_map(channel_index).data);
%         bandpass_filtered_map = [bandpass_filtered_map; {board_band_map{channel_index, 1}}, ...
%             {bandpass_filtered_data}];
        board_band_map(channel_index).data = bandpass_filtered_data; 
        board_band_map(channel_index).filter = [bandpass_filter_low_fc, bandpass_filter_high_fc]; 
    end
    bandpass_filtered_map = board_band_map; 
end