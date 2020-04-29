function [] = batch_create_labels(data_path, failed_path, labels_path, ...
        label_table, dir_config)
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
            load(file, 'GTH');

            label_table = create_ieeg_labels(label_table, GTH.anat, filename_meta);
            save(file, 'filename_meta', '-append');
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end
    [~, ~, label_ids] = unique(label_table.label);
    label_table.label_id = label_ids;

    %% Only write unique rows to prevent repetitive labels
    [~, ind] = unique(label_table, 'rows');
    label_table = label_table(ind,:);
    writetable(label_table, labels_path, 'Delimiter', ',');
end