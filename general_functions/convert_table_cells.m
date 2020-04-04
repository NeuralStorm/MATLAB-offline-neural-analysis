function [dir_config] = convert_table_cells(dir_config)
    column_headers = dir_config.Properties.VariableNames;
    for entry_i = 1:width(dir_config)
        curr_col = column_headers{entry_i};
        if iscell(dir_config.(curr_col))
            if strcmpi(class(dir_config.(curr_col){:}), 'double')
                continue;
            end
            dir_config.(curr_col) = dir_config.(curr_col){:};
        end
    end
end