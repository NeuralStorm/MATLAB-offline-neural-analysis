function [] = batch_plot_corr(dir_name, save_path, failed_path, ...
        data_path, dir_config)

    %% Purpose: Go through file list and plot feature space correlations
    %% Input:
    % dir_name: Name of dir that data came from (usually subject #)
    % save_path: path to save files at
    % failed_path: path to save errors at
    % data_path: path to load files from before analysis is ran
    % dir_config: config settings for that subject
    %% Output:
    %  No output, plots are saved at specified save location

    corr_start = tic;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, dir_config.include_sessions);
    fprintf('Graphing correlations for %s \n', dir_name);
    %% Goes through all the files and calculates mutual info according to the parameters set in dir_config
    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'component_results', 'label_log', 'filename_meta');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, component_results, label_log);
            if empty_vars
                continue
            end

            plot_corr(save_path, component_results, label_log, ...
                dir_config.feature_filter, dir_config.feature_value, ...
                dir_config.min_components, dir_config.corr_components, ...
                dir_config.sub_rows, dir_config.sub_columns, ...
                dir_config.subplot_shrinking, dir_config.legend_loc);

            clear('component_results', 'label_log', 'filename_meta');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished correlation graphing for %s. It took %s \n', ...
        dir_name, num2str(toc(corr_start)));
end