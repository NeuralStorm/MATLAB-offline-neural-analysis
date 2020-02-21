function [ica_path] = batch_ica(mnts_path, animal_name, config)
    ica_start = tic;
    [ica_path, failed_path] = create_dir(mnts_path, 'ica');
    [mnts_files] = get_file_list(mnts_path, '.mat', config.ignore_sessions);
    fprintf('ICA for %s \n', animal_name);
    %% Goes through all the files and performs pca according to the parameters set in config
    for file_index = 1:length(mnts_files)
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(mnts_path, mnts_files(file_index).name);
            [~, filename, ~] = fileparts(file);
            filename = erase(filename, 'mnts_format_');
            filename = erase(filename, 'mnts.format.');
            load(file, 'event_ts', 'selected_data', 'mnts_struct', 'filename_meta');
            %% Check variables to make sure they are not empty
            empty_vars = check_variables(file, event_ts, selected_data, mnts_struct);
            if empty_vars
                continue
            end

            %% ICA
            [selected_data, component_results] = calc_ica(selected_data, mnts_struct, ...
                config.ic_pc, config.extended, config.sphering, config.anneal, ...
                config.anneal_deg, config.bias, config.momentum, config.max_steps, ...
                config.stop, config.rnd_reset, config.verbose);

            %% Saving the file
            matfile = fullfile(ica_path, ['ic_analysis_', filename, '.mat']);
            empty_vars = check_variables(matfile, selected_data, component_results);
            if empty_vars
                continue
            end
            save(matfile, 'selected_data', 'event_ts', 'component_results', 'filename_meta');
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end
    fprintf('Finished ICA for %s. It took %s \n', ...
        animal_name, num2str(toc(ica_start)));
end