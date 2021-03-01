function [psth] = calc_psth(response_matrix)
    psth = mean(response_matrix, 1);
end