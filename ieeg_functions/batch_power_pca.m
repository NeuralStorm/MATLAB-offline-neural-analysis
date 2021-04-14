function [] = batch_power_pca(save_path, failed_path, data_path, dir_name, dir_config)
    %% Purpose: Go through file list and run pca on file set
    %% Input:
    % save_path: path to save files at
    % failed_path: path to save errors at
    % data_path: path to load files from before analysis is ran
    % dir_name: Name of dir that data came from (usually subject #)
    % dir_config: config settings for that subject
    %% Output:
    %  No output, analysis results are saved in file at specified save location

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
            load(file, 'mnts_struct', 'filename_meta', 'label_log', 'event_info');
            %% Check variables to make sure they are not empty
            empty_vars = check_variables(file, label_log, mnts_struct);
            if empty_vars
                continue
            end

            [component_results, ~, pc_log] = calc_pca(label_log, ...
                mnts_struct, dir_config.feature_filter, ...
                dir_config.feature_value, dir_config.apply_z_score);

            %% Add tfr to component_results
            unique_features = unique(label_log.label);
            for feature_i = 1:numel(unique_features)
                feature = unique_features{feature_i};
                component_results.(feature).tfr = mnts_struct.(feature).tfr;
                component_results.(feature).band_shift = mnts_struct.(feature).band_shift;
            end
            %% Saving the file
            matfile = fullfile(save_path, ['pc_analysis_', ...
                filename_meta.filename, '.mat']);
            check_variables(matfile, component_results);
            save(matfile, '-v7.3', 'component_results', ...
                'filename_meta', 'config_log', 'label_log', 'pc_log', 'event_info');
            clear('label_log', 'component_results', 'filename_meta', 'pc_log', 'config_log');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished PCA for %s. It took %s \n', ...
        dir_name, num2str(toc(pca_start)));
end