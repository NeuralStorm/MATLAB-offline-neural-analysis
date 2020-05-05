function [] = batch_plot_pca_weights(failed_path, data_path, dir_name, dir_config)
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, dir_config.include_sessions);

    fprintf('Plotting PCA weights for %s \n', dir_name);
    %% Perform PCA based on MNTS data
    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'component_results', 'filename_meta', 'label_log');

            powerband_names = fieldnames(component_results);
            for powerband_i = 1:length(powerband_names)
                curr_power = powerband_names{powerband_i};
                %TODO plot pca weight function call
                plot_pca_weights(component_results, label_log, ...
                    dir_config.feature_filter, dir_config.feature_value, ...
                    dir_config.sub_rows, dir_config.sub_cols);
            end
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
end