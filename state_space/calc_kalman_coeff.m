function [] = calc_kalman_coeff(grf_responses, observations, event_ts, labeled_data, training_size, pre_time, post_time, bin_size)
    %% Closed form calculations of A, H, W, Q

    event_window = -(abs(pre_time)):bin_size:(abs(post_time));
    tot_bins = length(event_window) - 1;
    %! Automate regions --> only using direct region for timebeing
    region = 'Right';
    [tot_region_units, ~] = size(labeled_data.(region));
    %TODO verify if we want to randomly take trials for training
    %TODO Wu et al. takes trials in order but there is no implicit order for trials?
    [tot_trials, ~] = size(event_ts);
    trial_range = 1:1:tot_trials;
    tot_training_trials = tot_trials * training_size;
    training_set = randperm(tot_trials, tot_training_trials);
    validation_set = setdiff(trial_range, training_set);

    %! Change from hard coded value (3 = unique measures forelimb, left and right hindlimb)
    uv = zeros(3);
    vv = zeros(3);
    uu = zeros(3);
    vu = zeros(3);
    sl = zeros(tot_region_units, 3);
    ll = zeros(3);
    ss_state = zeros(tot_region_units);
    ls_state = zeros(3, tot_region_units);
    for trial_num = training_set
        %% Format firing rates for current trial (N X B)
        trial_rates = table2array(observations.(region)(observations.(region).trial_number == trial_num, 4));
        %% Find trial measurements
        measurement_table = grf_responses(grf_responses.trial_number == trial_num,:);
        trial_measures = table2array(measurement_table(:, 4:end))';
        %% Measurements
        u = trial_measures(:, 2:end);
        v = trial_measures(:, 1:end-1);
        curr_uv = u * v';
        curr_vv = v * v';
        curr_uu = u * u';
        curr_vu = v * u';
        uv = uv + curr_uv;
        vv = vv + curr_vv;
        uu = uu + curr_uu;
        vu = vu + curr_vu;
        %% State measures
        s = reshape(trial_rates, [tot_region_units, tot_bins]); % N X B
        l = trial_measures;
        curr_sl = s * l';
        curr_ll = l * l';
        curr_ss = s * s';
        curr_ls = l * s';
        sl = sl + curr_sl;
        ll = ll + curr_ll;
        ss_state = ss_state + curr_ss;
        ls_state = ls_state + curr_ls;
    end
    A = uv * vv^-1;
    W = (1/((tot_bins - 1) * tot_training_trials)) * (uu - (A * vu));
    H = sl * ll^-1;
    Q = (1/(tot_bins * tot_training_trials)) * (ss_state - (H * ls_state));
    [test_A, test_W, test_H, test_Q] = calc_closed_coeff(grf_responses, observations.(region), training_set, tot_bins);
    assert(isequal(A, test_A))
    assert(isequal(W, test_W))
    assert(isequal(H, test_H))
    assert(isequal(Q, test_Q))
    %% Test parameters
    trial_num = validation_set(1);
    measurement_table = grf_responses(grf_responses.trial_number == trial_num,:);
    trial_measures = table2array(measurement_table(:, 4:end))';
    trial_rates = table2array(observations.(region)(observations.(region).trial_number == trial_num, 4));
    pop_rates = reshape(trial_rates, [tot_region_units, tot_bins]); % N X B
    x = zeros(3, tot_bins); % rows = measurement, cols = bins
    x(:, 1) = trial_measures(:, 1);
    P = W;
    for bin_i = 2:tot_bins
        curr_x = trial_measures(:, bin_i);
        % z = (H * curr_x) + q;
        z = pop_rates(:, bin_i); % firing rates for given trial
        %% Time update (a priori)
        x_prior = A * trial_measures(:, bin_i - 1);
        P_priori = A * P * A' + W;
        %% Calculate kalman gain
        K = P_priori * H' * (H * P_priori * H' + Q)^-1;
        %% Measurement Update (a posterior)
        x_post = x_prior + K * (z - H * x_prior);
        x(:, bin_i) = x_post;
        P = (eye(3) - K * H) * P_priori;
    end

    %% Prelimary check on parameters
    forelimb = figure;
    plot(measurement_table.forelimb);
    hold on
    plot(x(1,:));
    legend
    title('forelimb');
    left = figure;
    plot(measurement_table.left_hindlimb);
    hold on
    plot(x(2, :));
    legend
    title('left');
    right = figure;
    plot(measurement_table.right_hindlimb);
    hold on
    plot(x(3,:));
    legend
    title('right');

    % projected_z = reshape(z, [1, (tot_region_units * tot_bins)]);
    % immse(projected_z, psth_struct.(region).relative_response(trial_num, :))
end