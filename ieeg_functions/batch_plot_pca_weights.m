function [] = batch_plot_pca_weights(save_path, failed_path, data_path, dir_name, dir_config)
    %% Purpose: Go through file list and plot electrode weights across components
    %% Input:
    % save_path: path to save files at
    % failed_path: path to save errors at
    % data_path: path to load files from before analysis is ran
    % dir_name: Name of dir that data came from (usually subject #)
    % dir_config: config settings for that subject
    %% Output:
    %  No output, plots are saved at specified save location
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

            plot_pca_weights(save_path, component_results, label_log, ...
                dir_config.feature_filter, dir_config.feature_value, ...
                dir_config.ymax_scale, dir_config.sub_rows, dir_config.sub_columns, ...
                filename_meta.session_num);
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
end