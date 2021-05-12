function [project_path] = get_project_path(params)
    %% Get project path. If not path is given, then use uigetdir to get path
    p = inputParser;
    arg_name = 'path';
    default_val = '';
    addOptional(p, arg_name, default_val);
    parse(p, params{:});
    assert(ischar(p.Results.path), "path parameter must be a char");
    if ~isempty(p.Results.path)
        project_path = p.Results.path;
    else
        project_path = uigetdir(pwd);
    end
end