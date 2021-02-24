function [res] = slice_rr(rr, tot_features, step_size, curr_start, ...
        curr_end, new_start, new_end)

    assert(curr_start <= new_start, ...
        'new start time must be within established window');
    assert(curr_end >= new_end, ...
        'new end time must be within established window');

    bin_start = round((new_start - curr_start) / step_size) + 1;
    bin_end = round((new_end - new_start) / step_size) + bin_start - 1;
    slice_ind = bin_start:bin_end;
    [~, tot_steps] = get_bins(curr_start, curr_end, step_size);

    % [step_edges, tot_steps] = get_bins(curr_start, curr_end, step_size);
    % % edges are inclusive on left and exlusive on right, hence - step size
    % [new_edges, ~] = get_bins(new_start, (new_end - step_size), step_size);
    % slice_ind = find(ismembertol(step_edges, new_edges));

    res = [];
    [~, tot_obs] = size(rr);
    a = slice_ind;
    assert(tot_obs == (tot_steps * tot_features));
    for feat_i = 1:tot_features
        slice_rr = rr(:, a);
        res = [res, slice_rr];
        a = a + tot_steps;
    end
end