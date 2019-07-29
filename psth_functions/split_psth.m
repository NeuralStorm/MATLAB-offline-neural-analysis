function [pre_time_activity, post_time_activity] = split_psth(psth, ...
        pre_time, pre_time_bins, post_time_bins)
    pre_time_activity = [];
    post_time_activity = [];
    %% Breaks down the PSTH into pre psth
    if pre_time ~= 0
        %% Creates pre time PSTH
        pre = pre_time_bins;
        while pre < length(psth)
            pre_time_activity = [pre_time_activity; psth((pre - pre_time_bins + 1 ): pre)];
            % Update counter
            pre = pre + post_time_bins + pre_time_bins;
        end
        %% Creates post time PSTH
        post = pre_time_bins + post_time_bins; 
        while post <= length(psth)
            post_time_activity = [post_time_activity; psth((post - post_time_bins + 1): post)];
            post = post + pre_time_bins + post_time_bins;
        end
    else
        pre_time_activity = NaN;
        post_time_activity = psth;
    end
end