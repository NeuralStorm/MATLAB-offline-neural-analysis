function [label_table] = sep_make_labels(animal_path, animal_name)
    label_start = tic;
    %% Grabs label file and creates labels
    animal_csv_path = [animal_path, '/*.csv'];
    csv_files = dir(animal_csv_path);
    for csv = 1:length(csv_files)
        csv_file = fullfile(animal_path, csv_files(csv).name);
        if contains(csv_files(csv).name, 'labels.csv')
            label_table = readtable(csv_file);
        end
    end

    if isempty(label_table)
        error('Must have a labels csv in order to label channels.');
    end

    label_headers = label_table.Properties.VariableNames;
    expected_headers = {{'sig_channels'}, {'user_channels'}, {'label'}, {'label_id'}};
    if length(label_headers) ~= length(expected_headers)
        celldisp(expected_headers, 'Expected headers: ');
        error('Must have the above headers in labels');
    end
    header_diffs = all(cellfun(@strcmpi, label_headers, expected_headers));
    if ~header_diffs
        celldisp(expected_headers(~header_diffs), 'missing headers');
        error('Must have above headers in csv');
    end

    % Grabs all .mat files in the parsed plx directory
%     parsed_mat_path = strcat(parsed_path, '/*.mat');
%     parsed_files = dir(parsed_mat_path);
% 
%     for file_index = 1:length(parsed_files)
%         file = [parsed_path, '/', parsed_files(file_index).name];
%         [~, file_name, ~] = fileparts(file);
%         [~, ~, ~, session_num, ~, ~] = get_filename_info(file_name);
%         load(file, 'tscounts', 'evcounts', 'event_ts', 'channel_map');
%         check_variables(file, tscounts, evcounts, event_ts, channel_map);
% 
%         labeled_data = label_neurons(channel_map, label_table, session_num);
% 
%         check_variables(file, labeled_data, tscounts, evcounts, event_ts, channel_map);
% 
%         save(file, 'tscounts', 'evcounts', 'event_ts', 'channel_map', 'labeled_data');
%     end
%     fprintf('Finished labeling for %s. It took %s\n', ...
%         animal_name, num2str(toc(label_start)));
end