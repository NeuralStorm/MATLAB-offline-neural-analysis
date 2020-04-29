function [] = batch_format_psth(save_path, failed_path, data_path, dir_name, config, label_table)
    psth_start = tic;
    config_log = config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

    window_start = config.window_start; baseline_start = config.baseline_start; baseline_end = config.baseline_end;
    window_end = config.window_end; response_start = config.response_start; response_end = config.response_end;
    bin_size = config.bin_size;
    wanted_events = config.wanted_events; trial_lower_bound = config.trial_lower_bound;
    trial_range = config.trial_range;

    %% Remove unselected channels
    label_table(label_table.selected_channels == 0, :) = [];

    fprintf('Calculating PSTH for %s \n', dir_name);
    %% Goes through all the files and creates PSTHs according to the parameters set in config
    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% Load file contents
            file = [data_path, '/', file_list(file_index).name];
            load(file, 'event_ts', 'labeled_data', 'filename_meta');
            %% Select channels
            selected_data = select_data(labeled_data, ...
                label_table, filename_meta.session_num);
            %% Check parsed variables to make sure they are not empty
            empty_vars = check_variables(file, event_ts, selected_data);
            if empty_vars
                continue
            end

            %% Format PSTH
            [psth_struct, event_ts, label_log] = format_PSTH(event_ts, ...
                selected_data, bin_size, window_start, window_end, ...
                wanted_events, trial_range, trial_lower_bound);

            %% Add analysis window
            [baseline_window, response_window] = create_analysis_windows(selected_data, ...
                psth_struct, window_start, baseline_start, baseline_end, window_end, response_start, ...
                response_end, bin_size);

            %% Saving outputs
            matfile = fullfile(save_path, ['PSTH_format_', filename_meta.filename, '.mat']);
            %% Check PSTH output to make sure there are no issues with the output
            empty_vars = check_variables(matfile, psth_struct, event_ts);
            if empty_vars
                continue
            end

            %% Save file if all variables are not empty
            save(matfile, 'psth_struct', 'event_ts', 'selected_data', ...
                'baseline_window', 'response_window', 'filename_meta', ...
                'config_log', 'label_log');
            clear('psth_struct', 'event_ts', 'selected_data', 'label_log', ...
                'baseline_window', 'response_window', 'filename_meta');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished calculating PSTH for %s. It took %s \n', ...
        dir_name, num2str(toc(psth_start)));
end