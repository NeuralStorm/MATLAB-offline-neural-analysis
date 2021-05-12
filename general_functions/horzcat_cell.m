function [in_table] = horzcat_cell(in_table, in_cell, var_names, pos)
    sub_table = cell2table(in_cell, 'VariableNames', var_names);
    if strcmpi(pos, 'before')
        in_table = [sub_table, in_table];
    elseif strcmpi(pos, 'after')
        in_table = [in_table, sub_table];
    else
        error('Unrecognized position %s, expected before or after', pos);
    end
end