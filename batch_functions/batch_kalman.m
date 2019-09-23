function [] = batch_kalman(kalman_path, psth_path, config)
    [closed_path, failed_path] = create_dir(kalman_path, 'closed_form');
    [file_list] = get_file_list(psth_path, '.mat', config.ignore_sessions);
    % TODO grab another prac003 day and try with coefficents found in best day

    for file_index = 1:length(file_list)
        %% Load PSTH file to create state
        psth_file = [psth_path, '/', file_list(file_index).name];
        [~, psth_filename, ~] = fileparts(psth_file);
        load(psth_file, 'labeled_data', 'psth_struct', 'event_ts');
        region_obs = init_neural_state(psth_struct, event_ts, config.trial_range);

        %% Load measurements file
        %! Fix path stuff
        measurements_filename = erase(psth_filename, ['PSTH', '.', 'format', '.']);
        measurements_filename = erase(measurements_filename, ['PSTH', '_', 'format', '_']);
        measurements_filename = [measurements_filename, '.grf.mat'];
        measurement_file = fullfile(kalman_path, measurements_filename);
        load(measurement_file, 'measurements');


        %% Closed form kalman filter
        init_kalman(event_ts, measurements, region_obs, config.pre_time, config.post_time, config.bin_size, config.training_size);
        calc_kalman_coeff(measurements, region_obs, event_ts, labeled_data, config.training_size, config.pre_time, config.post_time, config.bin_size)


        %% Saving the file
        matfile = fullfile(closed_path, [psth_filename, '.mat']);
        save(matfile, 'region_obs', 'labeled_data', 'psth_struct');
        % empty_vars = check_variables(matfile, event_ts, grf_responses);
        % if empty_vars
        %     continue
        % end
        % save(matfile, 'grf_responses', 'event_ts', 'labeled_data', 'psth_struct');
    end
end