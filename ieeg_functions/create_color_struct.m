function [color_struct, chan_list] = create_color_struct(color_map, chan_group_log)
    [tot_colors, ~] = size(color_map);
    %% Find powers and chan_group in feature
    chan_list = unique(chan_group_log.chan_group);

    %% Set color map pairing for each unique chan_group that appears
    color_struct = struct;
    color_i = 1;
    for ch_group_i = 1:numel(chan_list)
        ch_group = chan_list{ch_group_i};
        %% Set indices in coefficients
        color_struct.(ch_group).indices = find(ismember(chan_group_log.chan_group, ch_group));
        %% set chan_group color
        color_struct.(ch_group).color = color_map(color_i, :);
        if color_i == tot_colors
            color_i = 1;
        else
            color_i = color_i + 1;
        end
    end
end