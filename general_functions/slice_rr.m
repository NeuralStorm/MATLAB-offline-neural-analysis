function [res] = slice_rr(rr, step_size, curr_start, ...
        curr_end, new_start, new_end)
    %TODO remove tot_chans, calculate tot_bins and tot_chans and assert clean division of tot_chans and rr

    assert(curr_start <= new_start, ...
        'new start time must be within established window');
    assert(curr_end >= new_end, ...
        'new end time must be within established window');

    [~, tot_bins] = get_bins(curr_start, curr_end, step_size);
    [~, tot_cols] = size(rr);
    assert(mod(tot_cols, tot_bins) == 0, ...
        'Total bins must cleanly fit into relative response');
    tot_chans = tot_cols / tot_bins;

    bin_start = round((new_start - curr_start) / step_size) + 1;
    bin_end = round((new_end - new_start) / step_size) + bin_start - 1;
    slice_ind = bin_start:bin_end;
    [~, tot_steps] = get_bins(curr_start, curr_end, step_size);

    res = [];
    [~, tot_obs] = size(rr);
    a = slice_ind;
    assert(tot_obs == (tot_steps * tot_chans));
    for chan_i = 1:tot_chans
        slice_rr = rr(:, a);
        res = [res, slice_rr];
        a = a + tot_steps;
    end
end