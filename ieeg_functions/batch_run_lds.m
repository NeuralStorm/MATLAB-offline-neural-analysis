function [] = batch_run_lds(save_path, failed_path, data_path, dir_name, ...
        dir_config)

    lds_start = tic;
    config_log = dir_config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, dir_config.include_sessions);
    fprintf('LDS for %s \n', dir_name);

    tot_bins = get_tot_bins(dir_config.window_start, dir_config.window_end, ...
        dir_config.bin_size);

    for file_i = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_i).name);
        filename_meta.filename = filename;
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_i).name);
            load(file, 'component_results', 'filename_meta', 'label_log', 'event_info');
            %% Check variables to make sure they are not empty
            empty_vars = check_variables(file, component_results);
            if empty_vars
                continue
            end

            [net, lds_results] = run_lds(component_results, event_info, tot_bins, dir_config.latent_variables, ...
                dir_config.em_cycles, dir_config.tolerance);

            %% Saving the file
            matfile = fullfile(save_path, ['lds_results_', ...
                filename_meta.filename, '.mat']);
            %TODO save file
            save(matfile, 'label_log', 'lds_results', 'config_log', 'net');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished LDS for %s. It took %s \n', ...
        dir_name, num2str(toc(lds_start)));
end