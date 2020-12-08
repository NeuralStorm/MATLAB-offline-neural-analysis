function [psth] = calc_psth(response_matrix, tot_trials)
    psth = sum(response_matrix, 1) / tot_trials;
end