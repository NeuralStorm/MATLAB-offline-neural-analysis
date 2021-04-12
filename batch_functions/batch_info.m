function [] = batch_info(project_path, save_path, failed_path, data_path, dir_name, filename_substring_one, config)
    info_start = tic;
    config_log = config;

    %% Shannon table
    csv_path = fullfile(project_path, [filename_substring_one, '_shannon_info_results.csv']);
    meta_headers = {'filename', 'animal_id', 'exp_group', 'exp_condition', ...
        'optional_info', 'date', 'record_session', 'window_start', 'window_end', ...
        'response_start', 'response_end', 'bin_size'};
    ignore_headers = {'entropy_time', 'entropy_count', 'mutual_info_time', 'mutual_info_count'};

    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

    fprintf('Mutual Info for %s \n', dir_name);
    %% Goes through all the files and calculates mutual info according to the parameters set in config
    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'psth_struct', 'event_info', 'label_log', 'filename_meta');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, psth_struct, event_info, label_log);
            if empty_vars
                warning('Animal: %s Does not have all the variables required for this analysis. Skipping...', dir_name);
                continue
            end

            %% Mutual information
            shannon_info = calc_shannon_info(psth_struct, event_info, ...
                config.bin_size, config.window_start, config.window_end, ...
                config.response_start, config.response_end);

            %% Saving the file
            matfile = fullfile(save_path, ['mutual_info_', filename_meta.filename, '.mat']);
            check_variables(matfile, shannon_info);
            save(matfile, 'label_log', 'shannon_info', 'config_log');

            %% Capture data to save to csv from current day
            meta_data = [
                {filename_meta.filename}, {filename_meta.animal_id}, ...
                {filename_meta.experimental_group}, ...
                {filename_meta.experimental_condition}, ...
                {filename_meta.optional_info}, filename_meta.session_date, ...
                filename_meta.session_num, config.window_start, config.window_end, ...
                config.response_start, config.response_end, config.bin_size];

            %% Append to receptive field CSV
            tot_rows = height(shannon_info);
            shannon_info = horzcat_cell(shannon_info, repmat(meta_data, [tot_rows, 1]), meta_headers, 'before');
            export_csv(csv_path, shannon_info, ignore_headers);

            clear('label_log', 'psth_struct', 'event_info', 'label_log', 'filename_meta', 'shannon_info');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished information analysis for %s. It took %s \n', ...
        dir_name, num2str(toc(info_start)));
end