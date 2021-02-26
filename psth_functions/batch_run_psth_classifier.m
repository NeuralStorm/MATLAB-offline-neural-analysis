function [] = batch_run_psth_classifier(project_path, save_path, failed_path, data_path, dir_name, dir_config)
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

    pop_config_info = table;
    pop_info = [];
    meta_headers = {'filename', 'subj_id', 'bin_size', 'window_start', ...
        'response_start', 'response_end', 'window_end'};
    ignore_headers = {'performance', 'mutual_info'};

    fprintf('Classifying for %s \n', dir_name);
    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'psth_struct', 'filename_meta', 'label_log', 'pc_log', 'event_info');
            event_info = event_info(~ismember(event_info.event_labels, 'all'), :);

            if dir_config.combine_pcs
                psth_struct = combine_feats(psth_struct);
            end

            [pop_table, res_struct] = run_psth_classifier(psth_struct, event_info, ...
                dir_config.bin_size, dir_config.window_start, dir_config.window_end, ...
                dir_config.response_start, dir_config.response_end);

            %% Saving the file
            matfile = fullfile(save_path, ['pc_classify_', ...
                filename_meta.filename, '.mat']);
            save(matfile, 'pop_table', 'res_struct', ...
                'filename_meta', 'config_log', 'label_log', 'pc_log', 'event_info');

            %% Write to csv
            %% Add info to results table
            current_general_info = [
                {filename_meta.filename}, {dir_name}, ...
                dir_config.bin_size, dir_config.window_start, dir_config.response_start,...
                dir_config.response_end, dir_config.window_end];
            [pop_config_info, pop_info] = ...
            concat_tables(meta_headers, pop_config_info, current_general_info, pop_info, pop_table);

            %% Clear variables
            clear('label_log', 'component_results', 'filename_meta', 'pc_log', 'config_log');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    %% CSV set up for pop analysis
    pop_results = [pop_config_info, pop_info];
    pop_csv_path = fullfile(project_path, 'pop_classification_info.csv');
    export_csv(pop_csv_path, pop_results, ignore_headers);
    fprintf('Finished classifying for %s. It took %s \n', ...
        dir_name, num2str(toc(pca_start)));
end