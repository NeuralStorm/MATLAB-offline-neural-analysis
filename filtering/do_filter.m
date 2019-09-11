function [filtered_map] = do_filter(data_map, sample_rate, notch_filt, ...
        notch_freq, notch_bandwidth, notch_bandstop, filt_type, filt_freq, filt_order)

    if notch_filt
        data_map = notch_filter_for_boardband(data_map, ...
            notch_freq, notch_bandwidth, sample_rate, notch_bandstop);
    end

    switch filt_type
        case {'low', 'high'}
            filtered_map = low_high_filt(data_map, sample_rate, filt_type, ...
                filt_freq, filt_order);
        case 'band'
            assert(length(filt_freq) == 2)
            filtered_map = bandpass_filter_for_boardband(data_map, ...
                filt_order, filt_freq(1), filt_freq(2), sample_rate);
        case 'notch'
            filtered_map = data_map;
            return
        otherwise
            error('Unsupported type: %s, try low, high, or band instead', type_filt);
    end
end