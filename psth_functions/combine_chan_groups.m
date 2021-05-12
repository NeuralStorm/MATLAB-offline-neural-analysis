function [out_struct] = combine_chan_groups(rr_data)
    unique_features = fieldnames(rr_data);
    overall_feature = 'all_chan_groups';
    out_struct = struct;
    out_struct.(overall_feature).relative_response = [];
    out_struct.(overall_feature).chan_order = [];

    for feature_i = 1:numel(unique_features)
        feature = unique_features{feature_i};
        out_struct.(overall_feature).relative_response = [...
            out_struct.(overall_feature).relative_response, rr_data.(feature).relative_response];
        out_struct.(overall_feature).chan_order = [out_struct.(overall_feature).chan_order; rr_data.(feature).chan_order];
    end
end