function [] = batch_info(animal_name, data_path, dir_name, ...
    search_ext, ignore_sessions)
    info_start = tic;

    [info_path, failed_path] = create_dir(data_path, dir_name);
    [files] = get_file_list(data_path, search_ext, ignore_sessions);

    fprintf('Mutual Info for %s \n', animal_name);
    %% Goes through all the files and calculates mutual info according to the parameters set in config
    for file_index = 1:length(files)
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, files(file_index).name);
            load(file, 'response_window', 'labeled_data', 'filename_meta');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, response_window, labeled_data);
            if empty_vars
                warning('Animal: %s Does not have all the variables required for this analysis. Skipping...', animal_name);
                continue
            end

            %% Mutual information
            [prob_struct, mi_results] = mutual_info(response_window, labeled_data);

            %% Saving the file
            matfile = fullfile(info_path, ['mutual_info_', filename_meta.filename, '.mat']);
            check_variables(matfile, prob_struct, mi_results);
            save(matfile, 'labeled_data', 'prob_struct', 'mi_results');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished information analysis for %s. It took %s \n', ...
        animal_name, num2str(toc(info_start)));
end