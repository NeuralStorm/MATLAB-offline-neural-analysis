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
            load(file, 'event_ts', 'mnts_struct', 'selected_data',...
                'filename_meta', 'label_log');
            %% Check variables to make sure they are not empty
            empty_vars = check_variables(file, event_ts, label_log, mnts_struct);
            if empty_vars
                continue
            end

            %% PCA
            [component_results, selected_data, label_log] = calc_pca(selected_data, ...
                mnts_struct, dir_config.feature_filter, dir_config.feature_value);

            %% Saving the file
            matfile = fullfile(save_path, ['pc_analysis_', ...
                filename_meta.filename, '.mat']);
            check_variables(matfile, component_results);
            save(matfile, 'selected_data', 'event_ts', 'component_results', ...
                'filename_meta', 'config_log', 'label_log');
            clear('label_log', 'event_ts', 'component_results', 'selected_data', ...
                'filename_meta');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished PCA for %s. It took %s \n', ...
        dir_name, num2str(toc(pca_start)));
end