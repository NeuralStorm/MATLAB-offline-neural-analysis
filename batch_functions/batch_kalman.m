function [] = batch_kalman(kalman_path, psth_path, config)
    psth_list = get_file_list(psth_path, '.mat', config.ignore_sessions);
    kalman_list = get_file_list(kalman_path, '.mat', config.ignore_sessions);
    % TODO add error handling
    for file_i = 1:length(kalman_list)
        %% Load measurements file
        filename = kalman_list(file_i).name;
        measurement_file = fullfile(kalman_path, filename);
        [~, ~, ~, session_num, session_date, ~] = get_filename_info(erase(filename, '.mat'));
        load(measurement_file, 'measurements', 'state_struct');

        %% Load PSTH file to create observations used to get kalman coeffs
        psth_file_struct = psth_list(contains({psth_list.name}, num2str(session_num)) & ...
            contains({psth_list.name}, num2str(session_date)));
        psth_file = fullfile(psth_file_struct.folder, psth_file_struct.name);
        load(psth_file, 'labeled_data', 'psth_struct', 'event_ts');
        region_obs = init_neural_obs(psth_struct, event_ts, state_struct, config.trial_range);


        % plot_state_obs(kalman_path, num2str(session_num), measurements, psth_struct)


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