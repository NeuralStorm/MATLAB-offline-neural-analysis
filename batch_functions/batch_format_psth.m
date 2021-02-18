function [] = batch_format_psth(save_path, failed_path, data_path, dir_name, config, label_table)
    psth_start = tic;
    config_log = config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

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
            load(file, 'event_info', 'labeled_data', 'filename_meta');
            %% Select channels
            selected_data = select_data(labeled_data, ...
                label_table, filename_meta.session_num);
            %% Check parsed variables to make sure they are not empty
            empty_vars = check_variables(file, event_info, selected_data);
            if empty_vars
                continue
            end

            %% Format PSTH
            [psth_struct, event_info, label_log] = format_PSTH(event_info, ...
                selected_data, config.bin_size, config.window_start, config.window_end, ...
                config.wanted_events, config.trial_range);

            %% Saving outputs
            matfile = fullfile(save_path, ['PSTH_format_', filename_meta.filename, '.mat']);
            save(matfile, 'psth_struct', 'event_info', 'selected_data', ...
                'filename_meta', 'config_log', 'label_log');
            clear('psth_struct', 'event_ts', 'event_info', 'selected_data', 'label_log', ...
                'filename_meta');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished calculating PSTH for %s. It took %s \n', ...
        dir_name, num2str(toc(psth_start)));
end