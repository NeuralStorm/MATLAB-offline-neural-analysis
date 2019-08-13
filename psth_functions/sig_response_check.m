function [sig_response] = sig_response_check(pre_psth,post_psth,smoothed_threshold,span,sig_bins,sig_check)             

    smoothed_response = smooth(post_psth, span);
    %% Determine if given neuron has a significant response 
    sig_response = false;
    reject_null = false;
    smooth_above_threshold_indeces = find(smoothed_response > smoothed_threshold);
    %% Determines if there was a significant response
    %! Check to see if consecutive bin check is with smoothed or non smoothed post time
    [consecutive, ~] = is_consecutive(smooth_above_threshold_indeces, sig_bins);
    if consecutive
        if sig_check == 1
            % Unpaired ttest on pre and post windows
            reject_null = ttest2(pre_psth, post_psth);
        elseif sig_check == 2
            % ks test on pre and post windows
            reject_null = kstest2(pre_psth, post_psth);
        elseif sig_check ~= 0
            error('Invalid sig check. sig_check can be 0, 1 or 2, please see main documentation for more details');
        end
        % If the null hypothesis is rejected, then there is a significant response
        if isnan(reject_null)
            reject_null = false;
        end
        if reject_null || sig_check == 0
            sig_response = true;
        end
    end


end