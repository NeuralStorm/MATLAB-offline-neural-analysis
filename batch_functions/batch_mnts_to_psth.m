function [psth_path] = batch_mnts_to_psth(animal_name, data_path, dir_name, ...
        search_ext, filename_substring_one, filename_substring_two, filename_substring_three, config)

    [files, psth_path, failed_path] = create_dir(data_path, dir_name, search_ext);
    for file_index = 1:length(files)
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, files(file_index).name);
            [~, filename, ~] = fileparts(file);
            filename = erase(filename, [filename_substring_one, '.', filename_substring_two, '.']);
            filename = erase(filename, [filename_substring_one, '_', filename_substring_two, '_']);

            %% Load needed variables from psth and does the receptive field analysis
            load(file, 'labeled_data', 'component_results', 'event_ts');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, labeled_data, component_results, event_ts);
            if empty_vars
                continue
            end

            [psth_struct, baseline_window, response_window] = reformat_mnts(labeled_data, ...
                component_results, config.bin_size, config.pre_time, config.post_time, config.pre_start, ...
                config.pre_end, config.post_start, config.post_end);

            matfile = fullfile(psth_path, [filename_substring_three, '_' filename, '.mat']);
            save(matfile, 'labeled_data', 'psth_struct', 'baseline_window', 'response_window', 'event_ts');
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end
end