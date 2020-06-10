function [] = check_time(window_start, baseline_start, baseline_end, window_end, response_start, response_end, bin_size)

    if window_start > 0
        error('Pre time must occur before event onset')
    end

    if window_end < 0
        error('Post time must occur after event onset')
    end

    if (isnan(window_start) && ~isnan(baseline_start) && ~isnan(baseline_end)) || ...
            (isnan(baseline_start) && ~isnan(window_start) && ~isnan(baseline_end)) || ...
            (isnan(baseline_end) && ~isnan(window_start) && ~isnan(baseline_start))
        error('All pre times must be nan or not nan');
    end

    if (isnan(window_end) && ~isnan(response_start) && ~isnan(response_end)) || ...
            (isnan(response_start) && ~isnan(window_end) && ~isnan(response_end)) || ...
            (isnan(response_end) && ~isnan(window_end) && ~isnan(response_start))
        error('All post times must be nan or not nan');
    end

    if window_start > baseline_start
        error('Pre time must occur before pre start');
    end

    if baseline_start > baseline_end
        error('Pre start must occur before pre end');
    end

    if window_end < response_end
        error('Post time must occur after pre end');
    end

    if response_start > response_end
        error('Post start must occur before post end');
    end

    pre_difference = baseline_end - baseline_start;
    if mod(pre_difference, bin_size) ~= 0
        error('Baseline window must be cleanly divisible by bin size');
    end

    post_difference = response_end - response_start;
    if mod(post_difference, bin_size) ~= 0
        error('Response window must be cleanly divisible by bin size');
    end
end