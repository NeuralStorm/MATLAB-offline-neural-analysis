function [] = batch_classify(project_path, save_path, failed_path, data_path, dir_name, filename_substring_one, config)
    classifier_start = tic;
    config_log = config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

    %% Pull variable names into workspace scope for log
    bin_size = config.bin_size; window_start = config.window_start; baseline_start = config.baseline_start;
    baseline_end = config.baseline_end; window_end = config.window_end; response_start = config.response_start;
    response_end = config.response_end; bootstrap_classifier = config.bootstrap_classifier;
    boot_iterations = config.boot_iterations; wanted_events = config.wanted_events;

    meta_headers = {'filename', 'animal_id', 'exp_group', 'exp_condition', ...
        'optional_info', 'date', 'record_session', 'bin_size', 'window_start', ...
        'baseline_start', 'baseline_end', 'window_end', 'response_start', 'response_end', ...
        'bootstrap_classifier', 'boot_iterations', 'selected_events'};
    analysis_headers = {'region', 'sig_channels', 'user_channels', 'performance', 'mutual_info', ...
        'boot_info', 'corrected_info', 'synergy_redundancy', 'synergistic', 'recording_notes'};
    ignore_headers = {'performance', 'mutual_info', 'boot_info', 'corrected_info', ...
        'synergy_redundancy', 'synergistic'};

    sprintf('PSTH classification for %s \n', dir_name);

    pop_config_info = table;
    unit_config_info = table;
    pop_info = [];
    unit_info = [];
    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        %% Run through files
        try
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'selected_data', 'event_ts', 'response_window', ...
                'filename_meta', 'label_log');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, selected_data, event_ts, response_window);
            if empty_vars
                continue
            end

            if iscell(wanted_events)
                wanted_events = wanted_events{:};
            end
            if isempty(wanted_events) || all(isnan(wanted_events))
                wanted_events = [];
                wanted_events = unique(event_ts(:,1))';
            end

            %% Classify and bootstrap
            [unit_struct, pop_struct, pop_table, unit_table] = psth_bootstrapper( ...
                selected_data, response_window, event_ts, wanted_events, ...
                boot_iterations, bootstrap_classifier, bin_size, ...
                window_start, baseline_start, baseline_end, window_end, ...
                response_start, response_end, analysis_headers);

            %% PSTH synergy redundancy
            [pop_table] = synergy_redundancy(pop_table, unit_table, ...
                config.bootstrap_classifier);

            %% Add info to results table
            current_general_info = [
                {filename_meta.filename}, {filename_meta.animal_id}, ...
                {filename_meta.experimental_group}, ...
                {filename_meta.experimental_condition}, ...
                {filename_meta.optional_info}, filename_meta.session_date, ...
                filename_meta.session_num, bin_size, window_start, baseline_start, ...
                baseline_end, window_end, response_start, response_end, ...
                bootstrap_classifier, boot_iterations, wanted_events
            ];
            [pop_config_info, pop_info] = ...
                concat_tables(meta_headers, pop_config_info, current_general_info, pop_info, pop_table);
            [unit_config_info, unit_info] = ...
                concat_tables(meta_headers, unit_config_info, current_general_info, unit_info, unit_table);

            matfile = fullfile(save_path, ['psth_classifier_', filename_meta.filename, '.mat']);
            check_variables(matfile, unit_struct, pop_struct, pop_table, unit_table);
            save(matfile, 'pop_struct', 'unit_struct', 'pop_table', ...
                'unit_table', 'config_log', 'label_log');
            clear('unit_struct', 'pop_struct', 'pop_table', 'unit_table', 'label_log');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end

    %% CSV set up for unit analysis
    unit_results = [unit_config_info, unit_info];
    unit_csv_path = fullfile(project_path, [filename_substring_one,'_unit_classification_info.csv']);
    export_csv(unit_csv_path, unit_results, ignore_headers)
    %% CSV set up for pop analysis
    pop_results = [pop_config_info, pop_info];
    pop_csv_path = fullfile(project_path, [filename_substring_one, '_pop_classification_info.csv']);
    export_csv(pop_csv_path, pop_results, ignore_headers)

    fprintf('Finished PSTH classifier for %s. It took %s \n', ...
        dir_name, num2str(toc(classifier_start)));
end