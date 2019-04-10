function [] = export_params(current_path, varargin)
    param_table = table;
    for i = 1:nargin
        if i == 1
            current_row = cell2table([{inputname(i)}, {current_path}]);
        else
            value = varargin{i - 1};
            if isstruct(value)
                current_row = [fieldnames(value), struct2cell(value)];
                param_table = [param_table; current_row];
                continue
            elseif length(value) > 1
                value = cellstr(num2str(value));
            end
            current_row = cell2table([{inputname(i)}, {value}]);
        end
        param_table = [param_table; current_row];
    end

    table_path = fullfile(current_path, '/params.csv');
    writetable(param_table, table_path);
end