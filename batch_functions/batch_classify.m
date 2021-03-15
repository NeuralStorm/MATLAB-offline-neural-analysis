function [] = batch_classify(project_path, save_path, failed_path, data_path, dir_name, filename_substring_one, config)
    %TODO check for uniqueness before running analysis to save computation time more 
    classifier_start = tic;
    config_log = config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

    %% Pull variable names into workspace scope for log
    bin_size = config.bin_size; window_start = config.window_start;
    window_end = config.window_end; response_start = config.response_start;
    response_end = config.response_end;
    boot_iterations = config.boot_iterations; wanted_events = config.wanted_events;

    meta_headers = {'filename', 'animal_id', 'exp_group', 'exp_condition', ...
        'optional_info', 'date', 'record_session', 'bin_size', 'window_start', ...
        'response_start', 'response_end', 'window_end', ...
        'boot_iterations', 'selected_events'};
    %TODO fix bug that prevents selected_events from being used in checking for uniqueness
    ignore_headers = {'performance', 'mutual_info', 'boot_info', 'corrected_info', ...
        'synergy_redundancy', 'synergistic', 'selected_events'};

    sprintf('PSTH classification for %s \n', dir_name);

    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        %% Run through files
        try
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'psth_struct', 'event_info', 'filename_meta', 'label_log');
            %! use label_log to pull the label metadata out (user_chans, recording_notes)
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, psth_struct, event_info, label_log);
            if empty_vars
                continue
            end

            %% Classify
            [pop_table, chan_table, classify_res] = do_psth_classifier(...
                psth_struct, event_info, bin_size, window_start, window_end, ...
                response_start, response_end);

            %% Bootstrap
            if boot_iterations > 0
                [boot_pop, boot_chan] = psth_bootstrapper(psth_struct, ...
                    event_info, bin_size, window_start, window_end, ...
                    response_start, response_end, boot_iterations);
                %% Join classification and boot results
                pop_table = join(pop_table, boot_pop, 'Keys', 'region');
                chan_table = join(chan_table, boot_chan, 'Keys', 'channel');
                %% Add corrected_info col (mutual info - bootstrapped mutual info)
                pop_table.corrected_info = pop_table.mutual_info - pop_table.boot_mutual_info;
                chan_table.corrected_info = chan_table.mutual_info - chan_table.boot_mutual_info;
            else
                %% If not bootstrapping, fill columns with NaN to prevent dim mismatch on csv output
                pop_table = add_nan_cols(pop_table);
                chan_table = add_nan_cols(chan_table);
            end

            %% PSTH synergy redundancy
            %TODO reimplement
            % [pop_table] = synergy_redundancy(pop_table, chan_table, ...
            %     boot_iterations);

            %% Add info to results table
            meta_data = [
                {filename_meta.filename}, {filename_meta.animal_id}, ...
                {filename_meta.experimental_group}, ...
                {filename_meta.experimental_condition}, ...
                {filename_meta.optional_info}, filename_meta.session_date, ...
                filename_meta.session_num, bin_size, window_start, ...
                response_start, response_end, window_end...
                boot_iterations, wanted_events
            ];

            matfile = fullfile(save_path, ['psth_classifier_', filename_meta.filename, '.mat']);
            check_variables(matfile, classify_res, pop_table, chan_table);
            save(matfile, 'classify_res', 'pop_table', 'chan_table', ...
                'config_log', 'label_log');

            %% Add meta data to table before export to csv
            tot_rows = height(pop_table);
            pop_table = horzcat_cell(pop_table, repmat(meta_data, [tot_rows, 1]), meta_headers, 'before');
            tot_rows = height(chan_table);
            chan_table = horzcat_cell(chan_table, repmat(meta_data, [tot_rows, 1]), meta_headers, 'before');
            %% Append to CSV
            pop_csv_path = fullfile(project_path, [filename_substring_one, '_pop_classification_info.csv']);
            export_csv(pop_csv_path, pop_table, ignore_headers)
            chan_csv_path = fullfile(project_path, [filename_substring_one,'_chan_classification_info.csv']);
            clear('classify_res', 'pop_table', 'chan_table', 'label_log');
            export_csv(chan_csv_path, chan_table, ignore_headers);
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished PSTH classifier for %s. It took %s \n', ...
        dir_name, num2str(toc(classifier_start)));
end

function [in_table] = add_nan_cols(in_table)
    tot_rows = height(in_table);
    in_table.boot_perf = nan(tot_rows, 1);
    in_table.boot_mutual_info = nan(tot_rows, 1);
    in_table.corrected_info = nan(tot_rows, 1);
end