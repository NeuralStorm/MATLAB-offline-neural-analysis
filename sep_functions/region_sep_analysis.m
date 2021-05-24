function [sep_analysis_results] = region_sep_analysis(sep_analysis_results)
    %! why are we normalizing across both channel groups AND events???
    unique_ch_groups = unique([sep_analysis_results.chan_group]);
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        region_indices = find([sep_analysis_results.chan_group] == ch_group);
        % Normalized neg and pos peaks to the largest peak within region /
        %% Negative peak norm
        if ~isempty([sep_analysis_results(region_indices).neg_peak1])
            min_peak = min(cell2mat({sep_analysis_results(region_indices).neg_peak1}));
            norm_neg_peak1 = num2cell([sep_analysis_results(region_indices).neg_peak1] / min_peak * 100);
            [sep_analysis_results(region_indices).norm_neg_peak1] = norm_neg_peak1{1,:};
        end
        if ~isempty([sep_analysis_results(region_indices).neg_peak2])
            min_peak = min(cell2mat({sep_analysis_results(region_indices).neg_peak2}));
            norm_neg_peak2 = num2cell([sep_analysis_results(region_indices).neg_peak2] / min_peak * 100);
            [sep_analysis_results(region_indices).norm_neg_peak2] = norm_neg_peak2{1,:};
        end
        if ~isempty([sep_analysis_results(region_indices).neg_peak3])
            min_peak = min(cell2mat({sep_analysis_results(region_indices).neg_peak3}));
            norm_neg_peak3 = num2cell([sep_analysis_results(region_indices).neg_peak3] / min_peak * 100);
            [sep_analysis_results(region_indices).norm_neg_peak3] = norm_neg_peak3{1,:};
        end
        %% Positive peak norm
        if ~isempty([sep_analysis_results(region_indices).pos_peak1])
            max_peak = max(cell2mat({sep_analysis_results(region_indices).pos_peak1}));
            norm_pos_peak1 = num2cell([sep_analysis_results(region_indices).pos_peak1] / max_peak * 100);
            [sep_analysis_results(region_indices).norm_pos_peak1] = norm_pos_peak1{1,:};
        end
        if ~isempty([sep_analysis_results(region_indices).pos_peak2])
            max_peak = max(cell2mat({sep_analysis_results(region_indices).pos_peak2}));
            norm_pos_peak2 = num2cell([sep_analysis_results.pos_peak2] / max_peak * 100);
            [sep_analysis_results(region_indices).norm_pos_peak2] = norm_pos_peak2{1,:};
        end
        if ~isempty([sep_analysis_results(region_indices).pos_peak3])
            max_peak = max(cell2mat({sep_analysis_results(region_indices).pos_peak3}));
            norm_pos_peak3 = num2cell([sep_analysis_results(region_indices).pos_peak3] / max_peak * 100);
            [sep_analysis_results(region_indices).norm_pos_peak3] = norm_pos_peak3{1,:};
        end
    end
end

