function [struct_map] = filter_continuous(selected_data, sample_rate, notch_filt, ...
    notch_freq, notch_bandwidth, notch_bandstop, filt_type, filt_freq, filt_order)
    %TODO change notch_filt variable name --> too close to notch_filter function

    unique_regions = fieldnames(selected_data);
    region_map = [];
    filt_freq = filt_freq ./ (sample_rate/2);
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        channel_list = selected_data.(region);
        tot_channels = height(channel_list);
        filtered_region = cell(tot_channels, 5);
        parfor channel_i = 1:tot_channels
            channel_info = channel_list(channel_i, :);
            channel_data = channel_info.channel_data{1};
            %% notch filter
            if notch_filt
                if notch_bandstop
                    stopband = [(notch_freq - notch_bandwidth / 2) ...
                        (notch_freq + notch_bandwidth / 2)];
                    %% Filter and store
                    filtered_data = bandstop(channel_data, stopband, sample_rate);
                else
                    filtered_data = notch_filter(channel_data, sample_rate, ...
                        notch_freq, notch_bandwidth);
                end
            else
                %% convience of having same name variable before more filtering
                filtered_data = channel_data;
            end

            switch filt_type
                case {'low', 'high'}
                    assert(length(filt_freq) == 1)
                    filtered_data = butterworth(filt_order, filt_freq, ...
                        filt_type, filtered_data);
                case 'bandpass'
                    assert(length(filt_freq) == 2)
                    filtered_data = butterworth(filt_order, filt_freq, ...
                        filt_type, filtered_data);
                case 'notch'
                    if ~notch_filt
                        warning('Inconsistent parameters in config. Notch filt set to false, but filt type was notch. Applying notch filter');
                        filtered_data = notch_filter(channel_data, sample_rate, ...
                            notch_freq, notch_bandwidth);
                    end
                otherwise
                    error('Unsupported type: %s, try low, high, or band instead', filt_type);
            end
            filtered_region(channel_i, :) = [channel_info.sig_channels(1), ...
                channel_info.user_channels(1), channel_info.label(1), ...
                channel_info.label_id(1), {filtered_data}];
        end
        region_map = [region_map; filtered_region];
    end
    struct_map = cell2struct(region_map, {'sig_channels', 'user_channels', ...
        'label', 'label_id', 'data'}, 2);
end