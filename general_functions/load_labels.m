function [label_table] = load_labels(animal_path, csv_id, ignore_sessions)
    csv_list = get_file_list(animal_path, '.csv', ignore_sessions);
    csv_list = csv_list([csv_list.isdir] == 0 ...
        & contains({csv_list.name}, csv_id));

    %% Enforces that there is only one labels file
    if isempty(csv_list)
        error('Must have a labels csv in order to label channels.');
    elseif length(csv_list) > 1
        error('Too many label files, unclear which label file to use');
    end
    csv_file = fullfile(csv_list(1).folder, csv_list(1).name);
    label_table = readtable(csv_file);

    if isempty(label_table)
        error('Must have valid labels in csv.');
    end

    label_headers = label_table.Properties.VariableNames;
    expected_headers = {{'sig_channels'}, {'user_channels'}, {'label'}, {'label_id'}, ...
        {'recording_session'}, {'date'}, {'recording_notes'}};
    if length(label_headers) ~= length(expected_headers)
        celldisp(expected_headers, 'Expected headers: ');
        error('Must have the above headers in labels');
    end
    header_diffs = all(cellfun(@strcmpi, label_headers, expected_headers));
    if ~header_diffs
        celldisp(expected_headers(~header_diffs), 'missing headers');
        error('Must have above headers in csv');
    end
end