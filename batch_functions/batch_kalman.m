function [] = batch_kalman(kalman_path, psth_path, config)
    [closed_path, ~] = create_dir(kalman_path, 'closed_form');
    [file_list] = get_file_list(psth_path, '.mat', config.ignore_sessions);
    [kalman_list] = get_file_list(kalman_path, '.mat', config.ignore_sessions);
    % TODO grab another prac003 day and try with coefficents found in best day
    % TODO add error handling
    for file_index = 1:length(file_list)
        %% Load PSTH file to create observations used to get kalman coeffs
        psth_file = [psth_path, '/', file_list(file_index).name];
        [~, psth_filename, ~] = fileparts(psth_file);
        load(psth_file, 'labeled_data', 'psth_struct', 'event_ts');
        region_obs = init_neural_obs(psth_struct, event_ts, config.trial_range);

        %% Load measurements file
        %! TODO FIX
        measurements_filename = erase(psth_filename, 'PSTH_format_');
        [~, ~, ~, session_num, session_date, ~] = get_filename_info(measurements_filename);
        measurement_file = {kalman_list(contains({kalman_list.name}, num2str(session_num)) & ...
            contains({kalman_list.name}, num2str(session_date))).name};
        measurement_file = fullfile(kalman_path, measurement_file{1});
        load(measurement_file, 'measurements');
        plot_state_obs(kalman_path, num2str(session_num), measurements, psth_struct)


        %% Closed form kalman filter
        fprintf('----Recording Session: %d----\n', session_num);
        % [kalman_coeffs, validation_prediction] = init_kalman(event_ts, measurements, region_obs, config.pre_time, ...
        %     config.post_time, config.bin_size, config.training_size, config.plot_states, config.plot_trials);
        % calc_kalman_coeff(measurements, region_obs, event_ts, labeled_data, config.training_size, config.pre_time, config.post_time, config.bin_size)


        %% Saving the file
        % matfile = fullfile(closed_path, [psth_filename, '.mat']);
        % save(matfile, 'region_obs', 'labeled_data', 'kalman_coeffs', 'validation_prediction');
    end
end