function [] = batch_lda_classify(project_path, save_path, failed_path, data_path, dir_name, filename_substring_one, config)
    %TODO check for uniqueness before running analysis to save computation time more 
    classifier_start = tic;
    config_log = config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

    %% Create csv paths
    pop_csv_path = fullfile(project_path, ['res_', filename_substring_one, '_pop_LDA_classifier.csv']);

    %% Pull variable names into workspace scope for log
    bin_size = config.bin_size; window_start = config.window_start;
    window_end = config.window_end; response_start = config.response_start;
    response_end = config.response_end;
    boot_iterations = config.boot_iterations; include_events = config.include_events;

    meta_headers = {'filename', 'animal_id', 'exp_group', 'exp_condition', ...
        'optional_info', 'date', 'record_session', 'bin_size', 'window_start', ...
        'response_start', 'response_end', 'window_end', ...
        'boot_iterations', 'include_events'};
    %TODO fix bug that prevents include_events from being used in checking for uniqueness
    ignore_headers = {'performance', 'mutual_info', 'boot_info', 'corrected_info', ...
        'synergy_redundancy', 'synergistic', 'include_events', 'user_channels'};

    fprintf('LDA classification for %s \n', dir_name);

    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        %% Run through files
        try
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'rr_data', 'event_info', 'filename_meta', 'chan_group_log');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, rr_data, event_info, chan_group_log);
            if empty_vars
                continue
            end

            if config.combine_chan_groups
                rr_data = combine_chan_groups(rr_data);
            end

            %% Classify
            if config.filt_trials
                [pop_table, classify_res] = scheme_lda_classify(rr_data, event_info);
            else
                [pop_table, classify_res] = lda_classify(rr_data, event_info);
            end


            matfile = fullfile(save_path, ['lda_classifier_', filename_meta.filename, '.mat']);
            check_variables(matfile, classify_res, pop_table);
            save(matfile, 'classify_res', 'pop_table', ...
                'config_log', 'chan_group_log');

            %% Add meta data to table before export to csv
            meta_data = [
                {filename_meta.filename}, {filename_meta.animal_id}, ...
                {filename_meta.experimental_group}, ...
                {filename_meta.experimental_condition}, ...
                {filename_meta.optional_info}, filename_meta.session_date, ...
                filename_meta.session_num, bin_size, window_start, ...
                response_start, response_end, window_end...
                boot_iterations, include_events
            ];
            tot_rows = height(pop_table);
            pop_table = horzcat_cell(pop_table, repmat(meta_data, [tot_rows, 1]), meta_headers, 'before');
            %% Append to CSV
            export_csv(pop_csv_path, pop_table, ignore_headers)
            clear('classify_res', 'pop_table', 'chan_group_log');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished LDA classifier for %s. It took %s \n', ...
        dir_name, num2str(toc(classifier_start)));
end

function [in_table] = add_nan_cols(in_table)
    tot_rows = height(in_table);
    in_table.boot_perf = nan(tot_rows, 1);
    in_table.boot_mutual_info = nan(tot_rows, 1);
    in_table.corrected_info = nan(tot_rows, 1);
end