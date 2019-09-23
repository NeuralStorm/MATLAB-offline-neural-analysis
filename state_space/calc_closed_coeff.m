function [A, W, H, Q] = calc_closed_coeff(state, obs, training_set, tot_bins)

    %% Purpose
    % Calculate closed form coefficents for Kalman Filter (Wu et al. 2004 and Wu et al. 2008)
    %% Inputs
    % state: external state (ie: hand kinematics, gram reaction forces, etc)
    % state: Type: table Column headers: trial_number, event_label, event_ts, S names, S = unique states
    % state: Dimension: (CH + S) x (T * B), CH = col. headers, S = unique states, T = tot trials B = tot bins
    % obs: neaural observations
    % obs: Type: Table Column headers: trial_number, event_label, event_ts (neural observations do not have label)
    % obs: Dimension: T X (CH + (N * B)), CH = col. headers, T = tot trials, N = tot units, B = tot bins
    %% Outputs
    % A: linear coeff. matrix: relates state from previous step (t - 1) to next step (t)
    % A: Type: numerical array Dimension: S x S, S = unique state factors (ie: x, y, z coordinates)
    % W: noise matrix for A
    % W: Type: numerical array, Dimension: S X S
    % H: linear coeff. matrix: relates state (hand kinematics) to observations (neural activity)
    % H: Type: numerical array Dimension: N X S, N = tot units, S = unique state factors
    % Q: noise matrix for H
    % Q: Type: numerical array Dimension: N X N

    state_names = state.Properties.VariableNames;
    meta_info = {'trial_number', 'event_label', 'event_ts'};
    assert(all(ismember(meta_info, state_names)));

    %% Get sizes for preallocation and reshaping
    [~, tot_obs] = size(obs.observations);
    tot_states = length(setdiff(state_names, meta_info));
    tot_units = tot_obs / tot_bins;
    tot_training_trials = length(training_set);
    %% Preallocate matrices used in sums to get Kalman coeffs
    uv = zeros(tot_states);
    vv = zeros(tot_states);
    uu = zeros(tot_states);
    vu = zeros(tot_states);
    sl = zeros(tot_units, tot_states);
    ll = zeros(tot_states);
    ss_state = zeros(tot_units);
    ls_state = zeros(tot_states, tot_units);

    %% Closed form summation
    for trial_num = training_set
        %% Format firing rates for current trial (N X B)
        trial_obs = table2array(obs(obs.trial_number == trial_num, 4)); % 1 X (N*B)
        %% Find trial observations
        state_table = state(state.trial_number == trial_num,:);
        trial_state = table2array(state_table(:, 4:end))';
        %% observations
        u = trial_state(:, 2:end);
        v = trial_state(:, 1:end-1);
        curr_uv = u * v';
        curr_vv = v * v';
        curr_uu = u * u';
        curr_vu = v * u';
        uv = uv + curr_uv;
        vv = vv + curr_vv;
        uu = uu + curr_uu;
        vu = vu + curr_vu;
        %% State measures
        s = reshape(trial_obs, [tot_units, tot_bins]); % N X B
        l = trial_state;
        curr_sl = s * l';
        curr_ll = l * l';
        curr_ss = s * s';
        curr_ls = l * s';
        sl = sl + curr_sl;
        ll = ll + curr_ll;
        ss_state = ss_state + curr_ss;
        ls_state = ls_state + curr_ls;
    end
    %% Calc final kalman coefficients
    A = uv * vv^-1;
    W = (1/((tot_bins - 1) * tot_training_trials)) * (uu - (A * vu));
    H = sl * ll^-1;
    Q = (1/(tot_bins * tot_training_trials)) * (ss_state - (H * ls_state));

end