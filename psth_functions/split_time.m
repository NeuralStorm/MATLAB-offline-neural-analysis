function [pre_response, post_response] = split_time(relative_response, pre_time_bins, post_time_bins)
    pre_response = [];
    post_response = [];
    [~, tot_cols] = size(relative_response);
    %% Breaks down the PSTH into pre psth
    if pre_time_bins ~= 0
        %% Creates pre time PSTH
        pre = pre_time_bins;
        while pre < tot_cols
            pre_response = [pre_response, relative_response(:, (pre - pre_time_bins + 1 ): pre)];
            % Update counter
            pre = pre + post_time_bins + pre_time_bins;
        end
        %% Creates post time PSTH
        post = pre_time_bins + post_time_bins; 
        while post <= tot_cols
            post_response = [post_response, relative_response(:, (post - post_time_bins + 1): post)];
            post = post + pre_time_bins + post_time_bins;
        end
    else
        pre_response = NaN;
        post_response = relative_response;
    end
end