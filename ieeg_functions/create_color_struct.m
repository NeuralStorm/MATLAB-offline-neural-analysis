function [color_struct, region_list] = create_color_struct(color_map, feature, label_log)
    [tot_colors, ~] = size(color_map);
    %% Find powers and regions in feature
    sub_features = strsplit(feature, '_');
    region_list = sub_features(ismember(sub_features, label_log.label));

    %% Set color map pairing for each unique region that appears
    color_struct = struct;
    color_i = 1;
    coeff_i = 1;
    for region_i = 1:numel(region_list)
        region = region_list{region_i};
        if isfield(color_struct, region)
            tot_region_chans = color_struct.(region).tot_region_chans;
            color_struct.(region).indices = [color_struct.(region).indices, coeff_i:(coeff_i + tot_region_chans - 1)];
            coeff_i = coeff_i + tot_region_chans;
        else
            %% Set indices in coefficients
            tot_region_chans = numel(label_log.sig_channels(strcmpi(label_log.label, region)));
            color_struct.(region).tot_region_chans = tot_region_chans;
            color_struct.(region).indices = coeff_i:(coeff_i + tot_region_chans - 1);
            coeff_i = coeff_i + tot_region_chans;
            %% set region color
            color_struct.(region).color = color_map(color_i, :);
            if color_i == tot_colors
                color_i = 1;
            else
                color_i = color_i + 1;
            end
        end
    end
end