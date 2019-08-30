function  filtered_path = sep_filter(is_notch_filter, is_lowpass_filter, ...
                is_highpass_filter, is_bandpass_filter, animal_name, parsed_path, notch_filter_frequency, ...
                notch_filter_bandwidth, use_notch_bandstop, lowpass_filter_order,...
                lowpass_filter_fc, highpass_filter_order, highpass_filter_fc, bandpass_filter_order,...
                bandpass_filter_low_fc, bandpass_filter_high_fc)
        if is_notch_filter
            %% Notch filter
            filtered_path = do_notch_filter(animal_name, ...
                parsed_path, notch_filter_frequency, notch_filter_bandwidth, use_notch_bandstop);
        else
            filtered_path = '';
        end  
        
        % If is_notch_filter is ture, pass the filtered data into lowpass
        % ,highpass or bandpass filter. If is_notch_filter is false, pass the raw
        % data into lowpass or highpass filter. 
            %% Lowpass filter 
        if is_lowpass_filter                           
            filtered_path = do_lowpass_filter(animal_name, parsed_path, filtered_path, is_notch_filter, ...
                lowpass_filter_order, lowpass_filter_fc);               
        end            
            %% Highpass filter        
        if is_highpass_filter
            filtered_path = do_highpass_filter(animal_name, parsed_path, filtered_path, is_notch_filter, ...
                is_lowpass_filter, highpass_filter_order, highpass_filter_fc);
        end
            %% Bandpass filter        
        if is_bandpass_filter
            filtered_path = do_bandpass_filter(animal_name, parsed_path, filtered_path, is_notch_filter, ...
                is_lowpass_filter, is_highpass_filter, bandpass_filter_order, ...
                bandpass_filter_low_fc, bandpass_filter_high_fc);
        end
        
end