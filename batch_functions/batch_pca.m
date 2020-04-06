function [pca_path] = batch_pca(mnts_path, animal_name, config)
    pca_start = tic;
    [pca_path, failed_path] = create_dir(mnts_path, 'pca');
    [mnts_files] = get_file_list(mnts_path, '.mat', config.ignore_sessions);

    fprintf('PCA for %s \n', animal_name);
    %% Goes through all the files and performs pca according to the parameters set in config
    for file_index = 1:length(mnts_files)
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(mnts_path, mnts_files(file_index).name);
            [~, filename, ~] = fileparts(file);
            filename = erase(filename, 'mnts_format_');
            filename = erase(filename, 'mnts.format.');
            load(file, 'event_ts', 'labeled_data', 'mnts_struct');
            %% Check variables to make sure they are not empty
            empty_vars = check_variables(file, event_ts, labeled_data, mnts_struct);
            if empty_vars
                continue
            end

            %% PCA
            [component_results, labeled_data] = calc_pca(labeled_data, ...
                mnts_struct, config.feature_filter, config.feature_value);

            %% Saving the file
            matfile = fullfile(pca_path, ['pc_analysis_', filename, '.mat']);
            check_variables(matfile, component_results, labeled_data);
            save(matfile, 'labeled_data', 'event_ts', 'component_results');
            clear('labeled_data', 'event_ts', 'component_results');
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end
    fprintf('Finished PCA for %s. It took %s \n', ...
        animal_name, num2str(toc(pca_start)));
end