function [filtered_map] = filter_continuous(selected_chans, sample_rate, notch_filt, ...
    notch_freq, notch_bandwidth, filt_type, filt_freq, filt_order)
    %TODO change notch_filt variable name --> too close to notch_filter function

    %% Unwrap config values that might be in a cell
    if iscell(filt_freq)
        filt_freq = cell2mat(filt_freq);
    end
    if iscell(filt_type)
        filt_type = filt_type{:};
    end

    unique_ch_groups = unique(selected_chans.chan_group);
    filtered_map = [];
    filt_freq = filt_freq ./ (sample_rate/2);
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        chan_list = selected_chans(strcmpi(selected_chans.chan_group, ch_group), :);
        tot_chans = height(chan_list);
        filtered_chans = cell(tot_chans, 5);
        for chan_i = 1:tot_chans
            channel_data = chan_list.channel_data(chan_i, :);
            %% notch filter
            if notch_filt
                filtered_data = notch_filter(channel_data, sample_rate, ...
                    notch_freq, notch_bandwidth);
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
            filtered_chans(chan_i, :) = [chan_list.channel(chan_i), ...
                chan_list.user_channels(chan_i), chan_list.chan_group(chan_i), ...
                chan_list.chan_group_id(chan_i), {filtered_data}];
        end
        filtered_map = [filtered_map; filtered_chans];
    end
    filtered_map = cell2table(filtered_map, 'VariableNames', ["channel", ...
        "user_channels", "chan_group", "chan_group_id", "channel_data"]);
end