function [] = export_csv(csv_path, new_results, ignore_columns)
    %TODO use uniquetol to check uniqueness for doubles?
    new_results = check_notes(new_results);
    headers = new_results.Properties.VariableNames;
    var_types = get_table_types(new_results);

    %% Find all double columns and convert any columns with multi sized arrays to strings
    %% Convert multi dimensional array to string
    % test_str = [];
    % for i = 1:numel(s)
    %     test_str = [test_str, ' ' num2str(s(i))];
    % end

    if exist(csv_path, 'file')
        results_table = readtable(csv_path);
        results_table = check_notes(results_table);
    else
        results_table = table('Size', [0, length(headers)], 'VariableTypes', ...
            var_types, 'VariableNames', headers);
    end

    %% Append new results to existing results table
    results_table = [results_table; new_results];

    %TODO assert same column headers and column dimensions

    %% Creating filter columns to find unique rows in csv
    check_cols = 1:1:width(results_table);
    remove_cols = [];
    for col_i = 1:width(results_table);
        curr_col = headers{col_i};
        if any(ismember(curr_col, ignore_columns))
            %% Check if column is to be ignored
            remove_cols = [remove_cols, col_i];
            continue;
        end
        curr_type = class(results_table.(curr_col));
        if ismember(curr_type, 'double')
            %% Check for NaNs and remove column if it does (NaN != NaN)
            if any(isnan(results_table.(curr_col)))
                remove_cols = [remove_cols, col_i];
            end
        elseif ismember(var_types{col_i}, {'string', 'char'})
            %% Check for missing since missing doesnt work in unique
            if any(ismissing(results_table.(curr_col)))
                remove_cols = [remove_cols, col_i];
            end
        end
    end

    %% Remove columns that should not be checked for uniqueness
    if ~isempty(remove_cols)
        check_cols = check_cols(~ismember(check_cols, remove_cols));
    end

    [~, ind] = unique(results_table(:, check_cols), 'rows');
    results_table = results_table(ind,:);
    writetable(results_table, csv_path, 'Delimiter', ',');
end

function [data_table] = check_notes(data_table)
    notes_logical = contains(data_table.Properties.VariableNames, 'notes');
    if any(notes_logical)
        note_headers = data_table.Properties.VariableNames(notes_logical);
        for header_i = 1:length(note_headers)
            curr_header = note_headers{header_i};
            if strcmpi(class(data_table.(curr_header)), 'double')
                data_table.(curr_header) = num2cell(data_table.(curr_header));
            end
        end
    end
end

function [table_types] = get_table_types(data_table)
    table_types = [];
    for col_i = 1:width(data_table)
        table_types = [table_types, {class(data_table.(col_i))}];
    end
end