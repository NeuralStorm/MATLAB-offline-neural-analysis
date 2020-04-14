function [] = batch_format_mnts(save_path, failed_path, data_path, dir_name, ...
        dir_config, label_table)
    mnts_start = tic;
    config_log = dir_config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, ...
        dir_config.include_sessions);

    %% Remove unselected channels
    label_table(label_table.selected_channels == 0, :) = [];

    fprintf('Calculating mnts for %s \n', dir_name);
    %% Creates mnts from parsed data according to the parameters set in config
    for file_index = 1:length(file_list)
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

            %% Format mnts
            [mnts_struct, event_ts, selected_data, label_log] = format_mnts(...
            event_ts, selected_data, dir_config.bin_size, dir_config.pre_time, ...
                dir_config.post_time, dir_config.wanted_events, ...
                dir_config.trial_range, dir_config.trial_lower_bound);

            %% Saving outputs
            matfile = fullfile(save_path, ['mnts_format_', ...
                filename_meta.filename, '.mat']);
            %% Check PSTH output to make sure there are no issues with the output
            empty_vars = check_variables(matfile, mnts_struct, ...
                event_ts, selected_data);
            if empty_vars
                continue
            end

            %% Save file if all variables are not empty
            save(matfile, 'mnts_struct', 'event_ts', 'selected_data', ...
                'filename_meta', 'config_log', 'label_log');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished calculating mnts for %s. It took %s \n', ...
        dir_name, num2str(toc(mnts_start)));
end