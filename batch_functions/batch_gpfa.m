function [] = batch_gpfa(psth_path, config)
    [gpfa_path, ~] = create_dir(psth_path, 'gpfa');
    file_list = get_file_list(psth_path, '.mat', config.ignore_sessions);

    for file_index = 1:length(file_list)
        psth_file = [psth_path, '/', file_list(file_index).name];
        [~, psth_filename, ~] = fileparts(psth_file);
        load(psth_file, 'labeled_data', 'psth_struct');
        [~, ~, ~, session_num, ~, ~] = get_filename_info(psth_filename);
        [gpfa_format, gpfa_results] = do_gpfa(session_num, ...
             labeled_data, psth_struct, config.bin_size, config.pre_time, config.post_time);

        %% Saving the file
        matfile = fullfile(gpfa_path, ['gpfa_results_', psth_filename, '.mat']);
        save(matfile, 'gpfa_format', 'gpfa_results');

    end
    % psth_path, bin_size, total_trials, pre_time, post_time, ...
    % optimize_state_dimension, state_dimension, prediction_error_dimensions, ...
    % plot_trials, dimsToPlot
end