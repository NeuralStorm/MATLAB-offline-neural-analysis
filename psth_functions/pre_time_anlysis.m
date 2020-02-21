function [smoothed_threshold,background_rate,background_std] = pre_time_anlysis(pre_psth,span,threshold_scale)             
    %% Deal with pre window first
    smoothed_pre_window = smooth(pre_psth, span);
    smoothed_avg_background = mean(smoothed_pre_window);
    smoothed_std_background = std(smoothed_pre_window);
    smoothed_threshold = smoothed_avg_background + (threshold_scale * smoothed_std_background);
    background_rate = mean(pre_psth);
    background_std = std(pre_psth);
end