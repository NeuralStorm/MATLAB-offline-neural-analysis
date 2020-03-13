function [dir_path] = enforce_dir_layout(parent_path, dir_name, failed_path, e_msg_1, e_msg_2)
    try
        if ~exist(parent_path, 'dir')
            error(e_msg_1);
        end
        dir_path = [parent_path, '/', dir_name];
        if ~exist(dir_path, 'dir')
            error(e_msg_2);
        end
    catch ME
        handle_ME(ME, failed_path, [dir_name, '_missing_dirs.mat']);
    end
end