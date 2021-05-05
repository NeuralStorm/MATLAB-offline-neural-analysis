function [color_struct, region_list] = create_color_struct(color_map, chan_group_log)
    [tot_colors, ~] = size(color_map);
    %% Find powers and regions in feature
    region_list = unique(chan_group_log.chan_group);

    %% Set color map pairing for each unique region that appears
    color_struct = struct;
    color_i = 1;
    for region_i = 1:numel(region_list)
        region = region_list{region_i};
        %% Set indices in coefficients
        tot_region_chans = numel(unique(chan_group_log.channel(strcmpi(chan_group_log.chan_group, region))));
        color_struct.(region).tot_region_chans = tot_region_chans;
        color_struct.(region).indices = find(ismember(chan_group_log.chan_group, region));
        %% set region color
        color_struct.(region).color = color_map(color_i, :);
        if color_i == tot_colors
            color_i = 1;
        else
            color_i = color_i + 1;
        end
    end
end