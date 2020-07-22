function [] = batch_plot_corr(dir_name, save_path, failed_path, ...
        data_path, dir_config)

    graph_start = tic;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, dir_config.include_sessions);
    fprintf('Graphing for %s \n', dir_name);
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

            plot_corr(save_path, component_results, label_log);
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished graphing for %s. It took %s \n', ...
        dir_name, num2str(toc(graph_start)));
end