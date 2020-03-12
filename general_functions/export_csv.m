function [] = export_csv(csv_path, column_names, general_table, analysis_table)
    var_types = [];
    for column = 1:width(general_table)
        var_types = [var_types, {class(general_table.(column))}];
    end

    for column = 1:width(analysis_table)
        var_types = [var_types, {class(analysis_table.(column))}];
    end
    results_table = table('Size', [0, length(column_names)], 'VariableTypes', ...
        var_types, 'VariableNames', column_names);
    if exist(csv_path, 'file')
        results_table = readtable(csv_path);
        if strcmpi(class(results_table.recording_notes), 'double')
            results_table.recording_notes = num2cell(results_table.recording_notes);
        end
    end

    %% Append new results to existing results table
    new_results_table = [general_table analysis_table];
    results_table = [results_table; new_results_table];

    %% Creating filter columns to find unique rows in csv
    general_col_i = 1:1:width(general_table);
    non_double_col_i = [];
    for col_i = 1:width(results_table)
        if ~strcmpi(var_types{col_i}, 'double')
            %% Skips doubles to help prevent taking NaN in unique
            non_double_col_i = [non_double_col_i, col_i];
        end
    end
    check_cols = union(general_col_i, non_double_col_i);
    %% Verify columns used in unique dont have nan
    nan_cols = [];
    for col_i = check_cols
        if strcmpi(var_types{col_i}, 'double')
            curr_col = column_names{col_i};
            if any(isnan(results_table.(curr_col)))
                nan_cols = [nan_cols, col_i];
            end
        elseif ismember(var_types{col_i}, {'string', 'char', 'cell'})
            curr_col = column_names{col_i};
            if any(ismissing(results_table.(curr_col)))
                nan_cols = [nan_cols, col_i];
            end
        end
    end
    if ~isempty(nan_cols)
        check_cols = check_cols(~ismember(check_cols, nan_cols));
    end

    %% Isolate unique rows and write to csv
    [~, ind] = unique(results_table(:, check_cols), 'rows');
    results_table = results_table(ind,:);
    writetable(results_table, csv_path, 'Delimiter', ',');
end