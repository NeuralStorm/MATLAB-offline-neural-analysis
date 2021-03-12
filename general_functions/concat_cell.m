function [in_table] = concat_cell(in_table, in_cell, var_names)
    sub_table = cell2table(in_cell, 'VariableNames', var_names);
    in_table = [in_table; sub_table];
end