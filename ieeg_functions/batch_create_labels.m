function [] = batch_create_labels(data_path, failed_path, labels_path, ...
        label_table, dir_config)

    %% Purpose: Go through file list and create/append labels csv
    %% Input:
    % data_path: path to load files from before analysis is ran
    % failed_path: path to save errors at
    % labels_path: path to save/load labels csv
    % label_table: table with information of current recordingv
    %              field: table with columns (can be empty, but must have the columns set up)
    %                     'channel': String with name of channel
    %                     'selected_channels': Boolean if channel is used
    %                     'user_channels': String with user defined mapping
    %                     'label': String: associated chan_group or grouping of electrodes
    %                     'label_id': Int: unique id used for labels
    %                     'recording_session': Int: File recording session number that above applies to
    %                     'recording_notes': String with user defined notes for channel
    % dir_config: config settings for that subject
    %% Output:
    %  No output, label csv is saved at labels path

    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, dir_config.include_sessions);
    for file_index = 1:length(file_list)
        %% Load file contents
        file = [data_path, '/', file_list(file_index).name];
        [~, filename, ~] = fileparts(file);
        filename_meta = get_filename_info(filename);
        try
            %% Load file contents
            file = [data_path, '/', file_list(file_index).name];
            load(file, 'power_struct');

            label_table = create_ieeg_labels(label_table, power_struct.anat, ...
                filename_meta.session_num);
            clear('power_struct');
            save(file, 'filename_meta', '-append');
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end
    [~, ~, chan_group_ids] = unique(label_table.chan_group);
    label_table.chan_group_id = chan_group_ids;

    %% Only write unique rows to prevent repetitive labels
    [~, ind] = unique(label_table, 'rows');
    label_table = label_table(ind,:);
    writetable(label_table, labels_path, 'Delimiter', ',');
end