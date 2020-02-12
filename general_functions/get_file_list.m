function [file_list] = get_file_list(parent_path, file_extension, ignore_sessions)
% mkdir parentFolder folderName
    file_type = [parent_path, '/*', file_extension];
    file_list = dir(file_type);
    %for ignoring training sessions that are not needed
    for i = 1:length(ignore_sessions)
        delete_j_index = 0;
        for j = 1:length(file_list)
            file_split = split(file_list(j).name, {'.', '_'});
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

