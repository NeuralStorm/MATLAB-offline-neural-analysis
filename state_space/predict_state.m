function [validation_prediction] = predict_state(state, obs, validation_set, ...
    tot_bins, A, W, H, Q, plot_states, plot_trials)

    state_names = state.Properties.VariableNames;
    meta_info = {'trial_number', 'event_label', 'event_ts'};
    state_headers = setdiff(state_names, meta_info);
    assert(all(ismember(meta_info, state_names)));

    %% Get sizes for preallocation and reshaping
    [~, tot_obs] = size(obs.observations);
    tot_units = tot_obs / tot_bins;
    tot_states = length(setdiff(state_names, meta_info));
    % all_trials = unique(state.trial_number);
    % training_set = setdiff(all_trials, validation_set);

    %% Go through validation set
    tot_mse = zeros([tot_states, 1]);
    avg_mse = zeros([tot_states, length(validation_set)]);
    validation_prediction = state(ismember(state.trial_number, validation_set), :);
    for trial_i = 1:length(validation_set)
        trial_num = validation_set(trial_i);
        %% Format firing rates for current trial (N X B)
        trial_obs = table2array(obs(obs.trial_number == trial_num, 4)); % 1 X (N*B)
        pop_obs = reshape(trial_obs, [tot_units, tot_bins]); % N X B
        %% Find trial observations
        state_table = state(state.trial_number == trial_num,:);
        trial_state = table2array(state_table(:, 4:end))';
        x = zeros(tot_states, tot_bins); % rows = measurement, cols = bins
        x(:, 1) = trial_state(:, 1);
        prev_P = W; % init prev P to be initial W matrix
        for bin_i = 2:tot_bins
            z = pop_obs(:, bin_i); % firing rates for given trial
            %% Time update (a priori)
            x_prior = A * trial_state(:, bin_i - 1);
            P_priori = A * prev_P * A' + W;
            %% Calculate kalman gain
            K = P_priori * H' * (H * P_priori * H' + Q)^-1;
            %% Measurement Update (a posterior)
            x_post = x_prior + K * (z - H * x_prior);
            prev_P = (eye(tot_states) - K * H) * P_priori;
            x(:, bin_i) = x_post;
        end
        validation_prediction(validation_prediction.trial_number == trial_num,4:end) = array2table(x');
        for row_i = 1:tot_states
            curr_mse = immse(x(row_i, :), trial_state(row_i, :));
            tot_mse(row_i) = tot_mse(row_i) + curr_mse;
            avg_mse(row_i, trial_i) = curr_mse;
        end
    end
    if plot_states
        plot_event_states(state, plot_trials)
    end
    avg_mse = mean(avg_mse, 2);
    for row_i = 1:tot_states
        fprintf('State: %s Total MSE: %d Avg MSE: %d\n', state_headers{row_i}, ...
            tot_mse(row_i), avg_mse(row_i));
    end
end