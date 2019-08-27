function [] = check_time(pre_time, pre_start, pre_end, post_time, post_start, post_end, bin_size)

    if pre_time > 0
        error('Pre time must occur before event onset')
    end

    if post_time < 0
        error('Post time must occur after event onset')
    end

    if (isnan(pre_time) && ~isnan(pre_start) && ~isnan(pre_end)) || ...
            (isnan(pre_start) && ~isnan(pre_time) && ~isnan(pre_end)) || ...
            (isnan(pre_end) && ~isnan(pre_time) && ~isnan(pre_start))
        error('All pre times must be nan or not nan');
    end

    if (isnan(post_time) && ~isnan(post_start) && ~isnan(post_end)) || ...
            (isnan(post_start) && ~isnan(post_time) && ~isnan(post_end)) || ...
            (isnan(post_end) && ~isnan(post_time) && ~isnan(post_start))
        error('All post times must be nan or not nan');
    end

    if pre_time > pre_start
        error('Pre time must occur before pre start');
    end

    if pre_start > pre_end
        error('Pre start must occur before pre end');
    end

    if post_time < post_end
        error('Post time must occur after pre end');
    end

    if post_start > post_end
        error('Post start must occur before post end');
    end

    if mod(pre_time, bin_size) ~= 0
        error('Pre time must be cleanly divisible by bin size');
    end

    if mod(post_time, bin_size) ~= 0
        error('Post time must be cleanly divisible by bin size');
    end

    pre_difference = pre_end - pre_start;
    if mod(pre_difference, bin_size) ~= 0
        error('Baseline window must be cleanly divisible by bin size');
    end


    post_difference = post_end - post_start;
    if mod(post_difference, bin_size) ~= 0
        error('Response window must be cleanly divisible by bin size');
    end
end