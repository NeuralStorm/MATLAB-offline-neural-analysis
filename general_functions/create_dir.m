function [file_list, child_path, failed_path] = create_dir(parent_path, child_name, file_extension,ignore_sessions)
    % mkdir parentFolder folderName
    file_type = [parent_path, '/*', file_extension];
    file_list = dir(file_type);
    %for ignoring training sessions that are not needed
    if exist('ignore_sessions') == 0
    else
        for i = 1:length(ignore_sessions)
            delete_j_index = 0;
            for j = 1:length(file_list)
                file_split = split(file_list(j).name,".");
                if str2num(file_split{4,1}) == ignore_sessions(i)
                    delete_j_index = j;
                    break;
                end
            end
            if delete_j_index ~= 0
                file_list(delete_j_index) = [];
            end
        end
    end
    %% Checks and creates a rf directory if it does not exists
    child_path = [parent_path, '/', child_name];
    if ~exist(child_path, 'dir')
        mkdir(parent_path, child_name);
    end

    %% Deletes the failed directory if it already exists
    failed_path = [parent_path, '/failed_', child_name];
    if exist(failed_path, 'dir') == 7
        delete([failed_path, '/*']);
        rmdir(failed_path);
    end
end