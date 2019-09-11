function sep_analysis_path = sep_analysis(animal_name, parsed_path, slice_path, ...
            baseline_start_window, baseline_end_window, standard_deviation_coefficient, ...
            early_start, early_end, late_start, late_end, ignore_sessions)
    sep_analysis_start = tic;
    fprintf('Applying sep analysis for %s \n', animal_name);
    [sep_analysis_path, failed_path] = create_dir(slice_path, 'sep_analysis');
    file_list = get_file_list(slice_path, '.mat', ignore_sessions);
    for file_index = 1:length(file_list)
        try
            %% Load file contents
            file = [slice_path, '/', file_list(file_index).name];
            [~, filename, ~] = fileparts(file);
            load(file, 'sep_l2h_map', 'sep_window');
            %extract the file name
            %% Check sliced variables to make sure they are not empty
            empty_vars = check_variables(file, sep_l2h_map);
            if empty_vars
                continue
            end
            %% Apply sep analysis

            sep_analysis_results = cal_sep_analysis(animal_name, sep_l2h_map, sep_window,...
                baseline_start_window, baseline_end_window, standard_deviation_coefficient, ...
                early_start, early_end, late_start, late_end);

            %% Saving outputs
            matfile = fullfile(sep_analysis_path, ['analysis_', filename, '.mat']);
            %% Check output to make sure there are no issues with the output
            empty_vars = check_variables(matfile, sep_analysis_results);
            if empty_vars
                continue
            end
            %% Save file if all variables are not empty
                    save(matfile, '-v7.3', 'sep_analysis_results');
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end         
    fprintf('Finished sep analysis for %s. It took %s s\n', ...
        animal_name, num2str(toc(sep_analysis_start)));

end