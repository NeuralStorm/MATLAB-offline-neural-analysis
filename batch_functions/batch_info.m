function [] = batch_info(save_path, failed_path, data_path, dir_name, config)
    %TODO add csv output
    info_start = tic;
    config_log = config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

    fprintf('Mutual Info for %s \n', dir_name);
    %% Goes through all the files and calculates mutual info according to the parameters set in config
    for file_index = 1:length(file_list)
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'response_window', 'selected_data', 'filename_meta');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, response_window, selected_data);
            if empty_vars
                warning('Animal: %s Does not have all the variables required for this analysis. Skipping...', dir_name);
                continue
            end

            %% Mutual information
            [prob_struct, mi_results] = mutual_info(response_window, selected_data);

            %% Saving the file
            matfile = fullfile(save_path, ['mutual_info_', filename_meta.filename, '.mat']);
            check_variables(matfile, prob_struct, mi_results);
            save(matfile, 'selected_data', 'prob_struct', 'mi_results', 'config_log');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished information analysis for %s. It took %s \n', ...
        dir_name, num2str(toc(info_start)));
end