function [] = batch_power_pca(save_path, failed_path, data_path, dir_name, dir_config)
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
            load(file, 'mnts_struct', 'filename_meta', 'label_log');
            %% Check variables to make sure they are not empty
            empty_vars = check_variables(file, label_log, mnts_struct);
            if empty_vars
                continue
            end

            component_results = struct;
            powerband_names = fieldnames(mnts_struct);
            pc_log = struct;
            for powerband_i = 1:length(powerband_names)
                curr_power = powerband_names{powerband_i};
                %% PCA
                [power_results, pow_log] = calc_power_pca(label_log.(curr_power), ...
                    mnts_struct.(curr_power), dir_config.use_z_mnts, ...
                    dir_config.feature_filter, dir_config.feature_value);
                component_results.(curr_power) = power_results;
                pc_log.(curr_power) = pow_log;
            end
            %% Saving the file
            matfile = fullfile(save_path, ['pc_analysis_', ...
                filename_meta.filename, '.mat']);
            check_variables(matfile, component_results);
            save(matfile, 'component_results', ...
                'filename_meta', 'config_log', 'label_log', 'pc_log');
            clear('label_log', 'component_results', 'filename_meta');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished PCA for %s. It took %s \n', ...
        dir_name, num2str(toc(pca_start)));
end