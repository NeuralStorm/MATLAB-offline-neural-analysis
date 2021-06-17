function [config_table] = import_config(project_path, analysis_type)

    csv_file = fullfile(project_path, ['conf_', analysis_type, '.csv']);
    if ~isfile(csv_file)
        conf_err = "Missing expected conf: "  + csv_file;
        error(conf_err);
    end
    config_table = readtable(csv_file);

    col_names = config_table.Properties.VariableNames;
    for col_i = 1:length(col_names)
        curr_col = col_names{col_i};
        logical_col = false;
        if ismember(class(config_table.(curr_col)), {'string', 'char', 'cell'})
            for entry_i = 1:height(config_table)
                if ismember(class(config_table.(curr_col){entry_i}), {'string', 'char', 'cell'})
                    [entry_value, logical_col] = ...
                        convert_string(config_table.(curr_col){entry_i}, logical_col);
                    config_table.(curr_col){entry_i} = entry_value;
                end
            end
        end
        if logical_col
            config_table.(curr_col) = cell2mat(config_table.(curr_col));
        end
    end
end

function [value, logical_col] = convert_string(string_value, logical_col)
    if all(ismember(string_value, '0123456789+-.eEdD,;: '))
        value = str2num(string_value);
    elseif strcmpi(string_value, 'true')
        value = 1;
        logical_col = true;
    elseif strcmpi(string_value, 'false')
        value = 0;
        logical_col = true;
    else
        value = string_value;
    end
end