function [] = batch_format_psth(save_path, failed_path, animal_path, dir_name, config, label_table)
    psth_start = tic;
    config_log = config;
    file_list = get_file_list(animal_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

    pre_time = config.pre_time; pre_start = config.pre_start; pre_end = config.pre_end;
    post_time = config.post_time; post_start = config.post_start; post_end = config.post_end;
    bin_size = config.bin_size;
    wanted_events = config.wanted_events; trial_lower_bound = config.trial_lower_bound;
    trial_range = config.trial_range;

    %% Remove unselected channels
    label_table(label_table.selected_channels == 0, :) = [];

    fprintf('Calculating PSTH for %s \n', dir_name);
    %% Goes through all the files and creates PSTHs according to the parameters set in config
    for file_index = 1:length(file_list)
        try
            %% Load file contents
            file = [animal_path, '/', file_list(file_index).name];
            [~, filename, ~] = fileparts(file);
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
            [psth_struct, event_ts] = format_PSTH(event_ts, selected_data, bin_size, ...
                pre_time, post_time, wanted_events, trial_range, trial_lower_bound);

            %% Add analysis window
            [baseline_window, response_window] = create_analysis_windows(selected_data, ...
                psth_struct, pre_time, pre_start, pre_end, post_time, post_start, ...
                post_end, bin_size);

            %% Saving outputs
            matfile = fullfile(save_path, ['PSTH_format_', filename, '.mat']);
            %% Check PSTH output to make sure there are no issues with the output
            empty_vars = check_variables(matfile, psth_struct, event_ts);
            if empty_vars
                continue
            end

            %% Save file if all variables are not empty
            save(matfile, 'psth_struct', 'event_ts', 'selected_data', ...
                'baseline_window', 'response_window', 'filename_meta', ...
                'config_log');
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end
    fprintf('Finished calculating PSTH for %s. It took %s \n', ...
        dir_name, num2str(toc(psth_start)));
end