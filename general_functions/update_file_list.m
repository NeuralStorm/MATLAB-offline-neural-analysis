function [updated_list] = update_file_list(file_list, failed_path, include_sessions)
    if iscell(include_sessions)
        include_sessions = include_sessions{:};
    end

    if all(isempty(include_sessions)) || all(isnan(include_sessions))
        updated_list = file_list;
        return
    end

    session_list = [];
    for file_i = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_i).name);
        file_meta = get_filename_info(filename);
        session_list = [session_list, file_meta.session_num];
    end
    files_i = ismember(session_list, include_sessions);
    updated_list = file_list(files_i);
    [~, missing_i] = setdiff(include_sessions, session_list);
    if ~isempty(missing_i)
        missing_cell = strtrim(cellstr(num2str(include_sessions(missing_i)'))');
        missing_string = char;
        for cell_i = 1:length(missing_cell)
            curr_string = missing_cell{cell_i};
            missing_string = [missing_string, ' ', curr_string];
        end
        try
            error('Missing sessions: %s', missing_string)
        catch ME
            handle_ME(ME, failed_path, 'missing_sessions');
        end
    end

    if isempty(updated_list)
        try
            error('No file sessions')
        catch ME
            handle_ME(ME, failed_path, 'no_sessions');
        end
    end

end