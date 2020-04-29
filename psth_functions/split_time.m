function [pre_response, post_response] = split_time(relative_response, pre_event_bins, post_event_bins)
    if isempty(relative_response)
        error('Relative response cannot be empty.');
    end
    pre_response = [];
    post_response = [];
    [~, tot_cols] = size(relative_response);
    %% Breaks down the PSTH into pre psth
    if pre_event_bins == 0
        pre_response = NaN;
        post_response = relative_response;
    elseif post_event_bins == 0
        pre_response = relative_response;
        post_response = NaN;
    else
        %% Creates pre time PSTH
        pre = pre_event_bins;
        while pre < tot_cols
            pre_response = [pre_response, relative_response(:, (pre - pre_event_bins + 1 ): pre)];
            % Update counter
            pre = pre + post_event_bins + pre_event_bins;
        end
        %% Creates post time PSTH
        post = pre_event_bins + post_event_bins; 
        while post <= tot_cols
            post_response = [post_response, relative_response(:, (post - post_event_bins + 1): post)];
            post = post + pre_event_bins + post_event_bins;
        end
    end
end