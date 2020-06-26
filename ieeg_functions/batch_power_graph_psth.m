function [] = batch_power_graph_psth(save_path, failed_path, data_path, dir_name, dir_config)

    %% Purpose: Go through file list and time course of features
    %% Input:
    % save_path: path to save files at
    % failed_path: path to save errors at
    % data_path: path to load files from before analysis is ran
    % dir_name: Name of dir that data came from (usually subject #)
    % dir_config: config settings for that subject
    %% Output:
    %  No output, plots are saved at specified save location

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
            load(file, 'psth_struct', 'pc_log', 'filename_meta');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, psth_struct, pc_log);
            if empty_vars
                continue
            end

            % make psths
            power_graph_PSTH(save_path, psth_struct, pc_log, dir_config);
            clear('psth_struct', 'pc_log', 'filename_meta');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished graphing for %s. It took %s \n', ...
        dir_name, num2str(toc(graph_start)));
end