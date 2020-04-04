function [file_list] = get_file_list(parent_path, file_extension)
    file_type = [parent_path, '/*', file_extension];
    file_list = dir(file_type);

    if isempty(file_list)
        error('No files in list')
    end
end

