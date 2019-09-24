function [kalman_coeffs] = init_kalman(event_ts, state, obs, pre_time, post_time, bin_size, training_size)
    meta_info = {'trial_number', 'event_label', 'event_ts'};
    event_window = -(abs(pre_time)):bin_size:(abs(post_time));
    tot_bins = length(event_window) - 1;
    [tot_trials, ~] = size(event_ts);
    trial_range = 1:1:tot_trials;
    tot_training_trials = tot_trials * training_size;
    training_set = randperm(tot_trials, tot_training_trials);
    validation_set = setdiff(trial_range, training_set);

    %% Validate expected parameter types
    assert(isstruct(obs));

    %% Iterate through regions and find parameters
    unique_regions = fieldnames(obs);
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        region_names = obs.(region).Properties.VariableNames;
        assert(all(ismember(meta_info, region_names)));
        [A, W, H, Q] = calc_closed_coeff(state, obs.(region), training_set, tot_bins);
        %TODO calc mean square error
        predict_state(state, obs.(region), validation_set, tot_bins, A, W, H, Q);
        %% Store kalman coeffs
        kalman_coeffs.(region).A = A; kalman_coeffs.(region).W = W;
        kalman_coeffs.(region).H = H; kalman_coeffs.(region).Q = Q;
    end

end