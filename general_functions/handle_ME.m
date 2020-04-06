function [] = handle_ME(ME, failed_path, filename)
    %% Error handling, saves exception in a failed directory
    if ~exist(failed_path, 'dir')
        mkdir(failed_path);
    end
    filename = ['FAILED.', filename, '.mat'];
    error_message = getReport(ME, 'extended', 'hyperlinks', 'on');
    warning(error_message);
    matfile = fullfile(failed_path, filename);
    save(matfile, 'ME');
end