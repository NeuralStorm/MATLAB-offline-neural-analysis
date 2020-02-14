function [selected_channels] = select_channels(labeled_data, channel_table, session_num)
    %% reformat labeled_data to channel_map
    channel_map = [];
    unique_regions = fieldnames(labeled_data);
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        channel_map = [channel_map; labeled_data.(region).sig_channels, ...
            labeled_data.(region).channel_data];
    end

    %% Call labeling function to take intersection of channels
    selected_channels = label_neurons(channel_map, channel_table, session_num);
end