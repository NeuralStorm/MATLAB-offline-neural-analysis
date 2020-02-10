function [mnts_path] = batch_format_mnts(parsed_path, animal_name, config)
    mnts_start = tic;
    [mnts_path, failed_path] = create_dir(parsed_path, 'mnts');
    [parsed_files] = get_file_list(parsed_path, '.mat', config.ignore_sessions);

    fprintf('Calculating mnts for %s \n', animal_name);
    %% Goes through all the files and creates mnts according to the parameters set in config
    for file_index = 1:length(parsed_files)
        try
            %% Load file contents
            file = [parsed_path, '/', parsed_files(file_index).name];
            [~, filename, ~] = fileparts(file);
            load(file, 'event_ts', 'labeled_data');
            %% Check parsed variables to make sure they are not empty
            empty_vars = check_variables(file, event_ts, labeled_data);
            if empty_vars
                continue
            end

            %% Format mnts
            [mnts_struct, event_ts, labeled_data] = format_mnts(event_ts, ...
                labeled_data, config.bin_size, config.pre_time, config.post_time, config.wanted_events, ...
                config.trial_range, config.trial_lower_bound);

            %% Saving outputs
            matfile = fullfile(mnts_path, ['mnts_format_', filename, '.mat']);
            %% Check PSTH output to make sure there are no issues with the output
            empty_vars = check_variables(matfile, mnts_struct, event_ts, labeled_data);
            if empty_vars
                continue
            end

            %% Save file if all variables are not empty
            save(matfile, 'mnts_struct', 'event_ts', 'labeled_data');
            export_params(mnts_path, 'mnts_psth', parsed_path, failed_path, animal_name, config);
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end
    fprintf('Finished calculating mnts for %s. It took %s \n', ...
        animal_name, num2str(toc(mnts_start)));
end