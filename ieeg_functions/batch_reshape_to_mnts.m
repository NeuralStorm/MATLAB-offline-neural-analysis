function [] = batch_reshape_to_mnts(save_path, failed_path, data_path, ...
    dir_name, dir_config, label_table)
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
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% Load file contents
            file = [data_path, '/', file_list(file_index).name];
            load(file, 'GTH', 'filename_meta');

            %% Grab channels for current session num
            session_labels = label_table(label_table.recording_session ...
                == filename_meta.session_num, :);

            %% Format mnts
            %TODO parameters: trial selection, bin size, time window
            [mnts_struct, label_log] = reshape_to_mnts(session_labels, GTH, ...
                dir_config.select_powers, dir_config.select_regions);

            %% Saving outputs
            matfile = fullfile(save_path, ['mnts_format_', ...
                filename_meta.filename, '.mat']);
            save(matfile, 'mnts_struct', 'label_log', 'filename_meta');
            %TODO
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished calculating mnts for %s. It took %s \n', ...
        dir_name, num2str(toc(mnts_start)));
end