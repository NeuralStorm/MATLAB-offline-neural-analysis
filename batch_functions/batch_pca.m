function [] = batch_pca(save_path, failed_path, data_path, dir_name, dir_config)
    pca_start = tic;
    config_log = dir_config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, dir_config.include_sessions);

    fprintf('PCA for %s \n', dir_name);
    %% Perform PCA based on MNTS data
    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'event_info', 'mnts_struct', ...
                'filename_meta', 'label_log');
            %% Check variables to make sure they are not empty
            empty_vars = check_variables(file, event_info, label_log, mnts_struct);
            if empty_vars
                continue
            end

            %% PCA
            [component_results, ~, label_log] = calc_pca(label_log, ...
                mnts_struct, dir_config.feature_filter, dir_config.feature_value, ...
                dir_config.apply_z_score);

            % [pca_results, labeled_pcs, pc_log] = calc_pca(label_log, mnts_struct, ...
            % feature_filter, feature_value, apply_z_score)

            %% Saving the file
            matfile = fullfile(save_path, ['pc_analysis_', ...
                filename_meta.filename, '.mat']);
            check_variables(matfile, component_results);
            save(matfile, 'event_info', 'component_results', 'label_log', ...
                'filename_meta', 'config_log', 'label_log');
            clear('label_log', 'event_ts', 'component_results', ...
                'filename_meta');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished PCA for %s. It took %s \n', ...
        dir_name, num2str(toc(pca_start)));
end