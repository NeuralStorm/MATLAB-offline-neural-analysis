function [file_list, child_path, failed_path] = create_dir(parent_path, child_name, file_extension)
    % mkdir parentFolder folderName
    file_type = [parent_path, '/*', file_extension];
    file_list = dir(file_type);

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