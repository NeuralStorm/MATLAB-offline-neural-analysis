function [] = export_params(current_path, name_modifier, varargin)
    param_table = table;
    for i = 1:nargin
        switch i
            case 1
                % first parameter is current path
                current_row = cell2table([{inputname(i)}, {current_path}]);
            case 2
                % We do not care about file name modifier
                continue
            otherwise
                % Handles varargin
                % TODO automate subtraction of hard coded 2
                value = varargin{i - 2};
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

    table_path = fullfile(current_path, ['/', name_modifier, '_params.csv']);
    writetable(param_table, table_path);
end