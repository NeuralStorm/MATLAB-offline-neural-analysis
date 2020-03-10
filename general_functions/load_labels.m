function [label_table] = load_labels(animal_path, csv_id)
    csv_file = fullfile(animal_path, csv_id);
    if ~isfile(csv_file)
        error('Must have label file to label')
    end
    label_table = readtable(csv_file);



    label_headers = label_table.Properties.VariableNames;
    expected_headers = {{'sig_channels'}, {'selected_channels'}, {'user_channels'}, {'label'}, {'label_id'}, ...
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