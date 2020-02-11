function [sliced_signals] = slice_signal(data_map, board_dig_in_data, sample_rate, sep_window)

    stim_ts = find_ts(board_dig_in_data, sample_rate);
    stim_ts = stim_ts(1, :);
    
    %Temporary solution to remove paired pulse time stamps   
    if length(stim_ts) > 125
        stim_ts = stim_ts(1, 1:2:end);     
    end
    
    window_start = abs(sep_window(1)) * sample_rate; 
    window_end = abs(sep_window(2)) * sample_rate; 

    sample_window_start = arrayfun(@(x) (x - window_start), stim_ts);
    sample_window_end = arrayfun(@(x) (x + window_start), stim_ts); 
    sample_window = [sample_window_start; sample_window_end]; 
        
    sliced_signals = struct('channel', data_map(:,1), 'sliced_data', []);
    
    for channel = 1:length(data_map)
       
        chan_signals = zeros(length(stim_ts), (sample_window(2,1) - sample_window(1,1) + 1));
        
        for event = 1:length(sample_window)
           
            chan_signals(event,:) = data_map(channel).data(sample_window(1, event):sample_window(2, event));
            
        end
        
%         sliced_signals(channel).sliced_data = chan_signals;
        data_map(channel).data = chan_signals;
        
    end
    
    sliced_signals = data_map;
end

