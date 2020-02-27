function sep_analysis_path = do_sep_analysis(animal_name, slice_path, config)
    sep_analysis_start = tic;
    fprintf('SEP analysis for %s \n', animal_name);
    [sep_analysis_path, failed_path] = create_dir(slice_path, 'sep_analysis');
    file_list = get_file_list(slice_path, '.mat', config.ignore_sessions);
    export_params(sep_analysis_path, 'sep_analysis', failed_path, config);
    for file_index = 1:length(file_list)
        try
            %% Load file contents
            file = [slice_path, '/', file_list(file_index).name];
            [~, filename, ~] = fileparts(file);
            load(file, 'sliced_signal', 'sep_window', 'filename_meta');
            %extract the file name
            %% Check sliced variables to make sure they are not empty
            empty_vars = check_variables(file, sliced_signal);
            if empty_vars
                continue
            end
            %% Average sliced data into SEP
            sep_data = average_sliced_data(sliced_signal, config.trial_range);
            %% Apply sep analysis
            sep_analysis_results = cal_sep_analysis(filename_meta, sep_data,...
                sep_window, config);

            %% Apply sep region analysis
            % (These analyses are updated if changes are made in the GUI)
            sep_analysis_results = region_sep_analysis(sep_analysis_results);

            %% Saving outputs
            matfile = fullfile(sep_analysis_path, ['analysis_', filename, '.mat']);
            %% Check output to make sure there are no issues with the output
            empty_vars = check_variables(matfile, sep_analysis_results);
            if empty_vars
                continue
            end
            %% Save file if all variables are not empty
            config_log = config;
            save(matfile, '-v7.3', 'sep_analysis_results', 'config_log');
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end
    fprintf('Finished SEP analysis for %s. It took %s s\n', ...
        animal_name, num2str(toc(sep_analysis_start)));
end