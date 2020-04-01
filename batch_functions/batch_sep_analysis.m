function [] = batch_sep_analysis(save_path, failed_path, data_path, dir_name, ...
        dir_config)
    %% SEP Analysis
    sep_analysis_start = tic;
    fprintf('SEP analysis for %s \n', dir_name);
    config_log = dir_config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, ...
        dir_config.include_sessions);

    for file_index = 1:length(file_list)
        try
            %% Load file contents
            file = [data_path, '/', file_list(file_index).name];
            load(file, 'sliced_signal', 'sep_window', 'filename_meta');
            %% Check sliced variables to make sure they are not empty
            empty_vars = check_variables(file, sliced_signal);
            if empty_vars
                continue
            end
            %% Find average SEP and apply analysis to average
            sep_data = average_sliced_data(sliced_signal, dir_config.trial_range);
            sep_analysis_results = cal_sep_analysis(filename_meta, sep_data,...
                sep_window, dir_config);

            %% Apply sep region analysis
            % (These analyses are updated if changes are made in the GUI)
            sep_analysis_results = region_sep_analysis(sep_analysis_results);

            %% Saving outputs
            matfile = fullfile(save_path, ['analysis_', filename_meta.filename, '.mat']);
            empty_vars = check_variables(matfile, sep_analysis_results);
            if empty_vars
                continue
            end
            %% Save file if all variables are not empty
            save(matfile, '-v7.3', 'sep_analysis_results', 'config_log', 'filename_meta');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished SEP analysis for %s. It took %s s\n', ...
        dir_name, num2str(toc(sep_analysis_start)));
end