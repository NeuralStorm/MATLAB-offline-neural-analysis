function [] = init_kalman(event_ts, measurements, state, pre_time, post_time, bin_size, training_size)
    event_window = -(abs(pre_time)):bin_size:(abs(post_time));
    tot_bins = length(event_window) - 1;
    %TODO verify if we want to randomly take trials for training
    %TODO Wu et al. takes trials in order but there is no implicit order for trials?
    [tot_trials, ~] = size(event_ts);
    trial_range = 1:1:tot_trials;
    tot_training_trials = tot_trials * training_size;
    training_set = randperm(tot_trials, tot_training_trials);
    validation_set = setdiff(trial_range, training_set);

    %% Validate expected parameter types
    assert(isstruct(state));

    %% Check measurement table
    measurement_names = measurements.Properties.VariableNames;
    meta_info = {'trial_number', 'event_label', 'event_ts'};
    tot_measurements = length(setdiff(measurement_names, meta_info));
    assert(all(ismember(meta_info, measurement_names)));

    %% Iterate through regions and find parameters
    unique_regions = fieldnames(state);
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        region_names = state.(region).Properties.VariableNames;
        assert(all(ismember(meta_info, region_names)));
        [~, response_bins] = size(state.(region).state);
        tot_region_units = response_bins / tot_bins;
        [A, W, H, Q] = calc_kalman(tot_measurements, tot_region_units, measurements, state.(region), training_set, tot_bins, tot_training_trials);
        %TODO calc mean square error
    end

end

function [A, W, H, Q] = calc_kalman(tot_measurements, tot_region_units, measurements, state, training_set, tot_bins, tot_training_trials)
    uv = zeros(tot_measurements);
    vv = zeros(tot_measurements);
    uu = zeros(tot_measurements);
    vu = zeros(tot_measurements);
    sl = zeros(tot_region_units, tot_measurements);
    ll = zeros(tot_measurements);
    ss_state = zeros(tot_region_units);
    ls_state = zeros(tot_measurements, tot_region_units);

    for trial_num = training_set
        % trial_num = training_set(trial_i);
        %% Format firing rates for current trial (N X B)
        trial_rates = table2array(state(trial_num, 4:end)); % 1 X (N*B)
        %% Find trial measurements
        measurement_table = measurements(measurements.trial_number == trial_num,:);
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
    trial_measures = table2array(measurement_table(:, 4:end))'
    s = reshape(trial_rates, [tot_region_units, tot_bins])
end