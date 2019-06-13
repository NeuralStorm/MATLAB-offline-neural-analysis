function [empty_variable] = check_variables(file, varargin)
    empty_variable = false;
    empty_list = {};
    variable_list = {};
    for arg = 2:nargin
        var_name = inputname(arg);
        var_input = varargin{arg - 1};
        variable_list = [variable_list; {inputname(arg)}, {var_input}];
        if isstruct(var_input)
            empty_variable = isempty(fieldnames(var_input));
            empty_list = [empty_list, inputname(arg)];
        elseif iscell(var_input)
            unique_cells = unique(cellfun(@isempty, var_input));
            empty_variable = length(unique_cells) == 1 & unique_cells == 1;
            empty_list = [empty_list, inputname(arg)];
        elseif isempty(var_input)
            empty_variable = true;
            empty_list = [empty_list, inputname(arg)];
        end
    end
    %% IF variables are empty, print warning and remove file from list
    if empty_variable
        warning('Critical Variable is empty');
        if exist(file, 'file')
            %% Delete old file so its not overwritten with empty variables
            delete(file);
            %% Save variables to an empty folder to keep track
            [file_path, filename, file_ext] = fileparts(file);
            [~, empty_path, ~] = create_dir(file_path, 'missing_variables', file_ext);
            save(fullfile(empty_path, ['missing_vars_', filename]), 'empty_list', 'variable_list');
        end
    end
end