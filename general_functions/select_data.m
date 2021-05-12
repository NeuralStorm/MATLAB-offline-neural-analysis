function [selected_channels] = select_data(chan_data, chan_table, session_num)
    %% reformat chan_data to channel_map
    channel_map = [];
    unique_ch_group = fieldnames(chan_data);
    for ch_group_i = 1:length(unique_ch_group)
        ch_group = unique_ch_group{ch_group_i};
        channel_map = [channel_map; chan_data.(ch_group).channel, ...
            chan_data.(ch_group).channel_data];
    end

    %% Call labeling function to take intersection of channels
    selected_channels = label_data(channel_map, chan_table, session_num);
end