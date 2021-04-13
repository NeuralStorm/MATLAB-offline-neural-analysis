function [] = batch_ica(save_path, failed_path, data_path, dir_name, dir_config)
    ica_start = tic;
    config_log = dir_config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, dir_config.include_sessions);

    fprintf('ICA for %s \n', dir_name);
    %% Goes through all the files and performs pca according to the parameters set in config
    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'event_info', 'mnts_struct', 'filename_meta', 'label_log');
            %% Check variables to make sure they are not empty
            empty_vars = check_variables(file, event_info, mnts_struct);
            if empty_vars
                continue
            end

            %% ICA
            [component_results, ~, label_log] = calc_ica(label_log, ...
                mnts_struct, dir_config.ic_pc, dir_config.extended, ...
                dir_config.sphering, dir_config.anneal, dir_config.anneal_deg, ...
                dir_config.bias, dir_config.momentum, dir_config.max_steps, ...
                dir_config.stop, dir_config.rnd_reset, dir_config.verbose);

            %% Saving the file
            matfile = fullfile(save_path, ['ic_analysis_', filename_meta.filename, '.mat']);
            empty_vars = check_variables(matfile, component_results);
            if empty_vars
                continue
            end
            save(matfile, 'event_info', 'component_results', ...
                'filename_meta', 'config_log', 'label_log');
            clear('event_info', 'component_results', ...
                'filename_meta', 'label_log');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished ICA for %s. It took %s \n', ...
        dir_name, num2str(toc(ica_start)));
end