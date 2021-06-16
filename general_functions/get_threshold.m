function [vec_avg, vec_std, upper_thresh, lower_thresh] = get_threshold(vec, std_scalar)
    %% Purpose: Calculate average across all indices
    % then calc threshold scaled by std
    %% Input:
    % vec: 1d array of data
    % std_scalar: standard deviation scalar
    %% Output:
    % vec_avg: average of vec
    % vec_std: stanard deviation of vec
    % upper_thresh/lower_thresh: threshold: vec_std +/- std_scalar * vec_std
    %TODO add flag to do std vs ste?
    vec_avg = mean(vec);
    vec_std = std(vec);
    upper_thresh = vec_avg + (std_scalar * vec_std);
    lower_thresh = vec_avg - (std_scalar * vec_std);
end