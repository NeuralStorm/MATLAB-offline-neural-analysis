function [label_table] = load_labels(dir_path, csv_id)
    %% Load labels file
    csv_file = fullfile(dir_path, csv_id);
    if ~isfile(csv_file)
        error('Must have label file to label')
    end
    label_table = readtable(csv_file);

    %% Gather headers and set expected headers
    label_headers = label_table.Properties.VariableNames;
    expected_headers = [{'channel'}, {'selected_channels'}, {'user_channels'}, {'chan_group'}, {'chan_group_id'}, ...
        {'recording_session'}, {'recording_notes'}];
    logical_headers = ismember(expected_headers, label_headers);

    %% Enforce headers
    if ~all(logical_headers)
        celldisp(expected_headers(~logical_headers), 'Expected headers: ');
        error('Must have the above headers in labels');
    end
end