function [] = batch_sep_analysis(save_path, failed_path, data_path, dir_name, ...
        dir_config)
    %% SEP Analysis
    sep_analysis_start = tic;
    fprintf('SEP analysis for %s \n', dir_name);
    config_log = dir_config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, ...
        dir_config.include_sessions);

    meta_headers = {'filename', 'animal_id', 'exp_group', 'exp_condition', ...
        'optional_info', 'date', 'record_session', 'sep_window', 'early_window', ...
        'late_window', 'notch', 'filter'};

    window_s = dir_config.window_start; window_e = dir_config.window_end;
    base_s = dir_config.baseline_start; base_e = dir_config.baseline_end;
    early_res_s = dir_config.early_response_start; early_res_e = dir_config.early_response_end;
    late_res_s = dir_config.late_response_start; late_res_e = dir_config.late_response_end;
    sep_window = [window_s, window_e]; base_window = [base_s, base_e];
    early_window = [early_res_s, early_res_e]; late_window = [late_res_s, late_res_e];

    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% Load file contents
            file = [data_path, '/', file_list(file_index).name];
            load(file, 'sliced_signal', 'filename_meta', 'chan_group_log', 'event_info');
            %% Check sliced variables to make sure they are not empty
            empty_vars = check_variables(file, sliced_signal);
            if empty_vars
                continue
            end
            %% Find average SEP and apply analysis to average
            sep_analysis_results = sep_analysis(sliced_signal, event_info, ...
                window_s, window_e, base_s, base_e, early_res_s, early_res_e, ...
                late_res_s, late_res_e, dir_config.threshold_scalar);

            %% Capture data to save to csv from current day
            meta_data = [
                {filename_meta.filename}, {filename_meta.animal_id}, ...
                {filename_meta.experimental_group}, ...
                {filename_meta.experimental_condition}, ...
                {filename_meta.optional_info}, filename_meta.session_date, ...
                filename_meta.session_num, sep_window, early_window, late_window, ...
                dir_config.notch_filt, dir_config.filt_freq];

            %% Append to table
            tot_rows = height(sep_analysis_results);
            sep_analysis_results = horzcat_cell(sep_analysis_results, ...
                repmat(meta_data, [tot_rows, 1]), meta_headers, 'before');
            sep_analysis_results = join_label_meta(chan_group_log, sep_analysis_results);
            sep_analysis_results = table2struct(sep_analysis_results);


            %% Apply sep region analysis
            % (These analyses are updated if changes are made in the GUI)
            sep_analysis_results = norm_sep_peaks(sep_analysis_results);

            %% Saving outputs
            matfile = fullfile(save_path, ['analysis_', filename_meta.filename, '.mat']);
            empty_vars = check_variables(matfile, sep_analysis_results);
            if empty_vars
                continue
            end
            %% Save file if all variables are not empty
            save(matfile, '-v7.3', 'sep_analysis_results', 'config_log', ...
                'filename_meta', 'chan_group_log', 'event_info');
            clear('sep_analysis_results', 'filename_meta', 'chan_group_log');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished SEP analysis for %s. It took %s s\n', ...
        dir_name, num2str(toc(sep_analysis_start)));
end