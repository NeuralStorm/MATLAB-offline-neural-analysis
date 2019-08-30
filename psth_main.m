function [] = psth_main()
    %% Get directory with all animals and their data
    original_path = uigetdir(pwd);
    start_time = tic;
    animal_list = dir(original_path);
    animal_names = {animal_list([animal_list.isdir] == 1 & ~contains({animal_list.name}, '.')).name};
    for animal = 1:length(animal_names)
        animal_name = animal_names{animal};
        animal_path = fullfile(...
            animal_list(strcmpi(animal_names{animal}, {animal_list.name})).folder, animal_name);
        config = import_config(animal_path, 'psth');
        export_params(animal_path, 'main', config);
        training_session_config_array = [];
        % For ignoring certain training sessions
        if isfield(config,'ignore_sessions')
            training_session_config_array = config.ignore_sessions;
        end
        % Skips animals we want to ignore
        if config.ignore_animal
            continue;
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Parser           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.parse_files
                %% Parse files
                %! Might remove the file handling in the future
                parsed_path = parser(animal_path, animal_name, config.total_trials, ...
                    config.total_events, config.trial_lower_bound, ...
                    config.is_non_strobed_and_strobed, config.event_map);
            else
                parsed_path = [animal_path, '/parsed'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%       Label Channels       %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.label_channels
                %% Label channels
                %! Might remove the file handling in the future
                batch_label(animal_path, animal_name, parsed_path);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%        Format PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.create_psth
                psth_start = tic;
                % warning('Since the pre time is set to 0, there will not be a psth generated with only the pre time activity.\n');
                [parsed_files, psth_path, failed_path] = create_dir(parsed_path, 'psth', '.mat', training_session_config_array);

                fprintf('Calculating PSTH for %s \n', animal_name);
                %% Goes through all the files and creates PSTHs according to the parameters set in config
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

                        %% Format PSTH
                        [psth_struct, event_ts, event_strings] = ...
                            format_PSTH(event_ts, labeled_data, config.bin_size, config.pre_time, ...
                            config.post_time, config.wanted_events, config.trial_range, config.trial_lower_bound);

                        %% Add analysis window
                        [baseline_window, response_window] = create_analysis_windows(labeled_data, psth_struct, ...
                            config.pre_time, config.pre_start, config.pre_end, config.post_time, ...
                            config.post_start, config.post_end, config.bin_size);

                        %% Saving outputs
                        matfile = fullfile(psth_path, ['PSTH_format_', filename, '.mat']);
                        %% Check PSTH output to make sure there are no issues with the output
                        empty_vars = check_variables(matfile, psth_struct, event_ts, event_strings);
                        if empty_vars
                            continue
                        end

                        %% Save file if all variables are not empty
                        save(matfile, 'psth_struct', 'event_ts', 'event_strings', 'labeled_data', 'baseline_window', 'response_window');
                        export_params(psth_path, 'format_psth', parsed_path, failed_path, animal_name, config);
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                fprintf('Finished calculating PSTH for %s. It took %s \n', ...
                    animal_name, num2str(toc(psth_start)));
            else
                psth_path = [parsed_path, '/psth'];
            end

            if config.update_psth_windows
                file_type = [psth_path, '/*', '.mat'];
                file_list = dir(file_type);
                for file_index = 1:length(file_list)
                    try
                        %% pull info from filename and set up file path for analysis
                        file = fullfile(psth_path, file_list(file_index).name);
                        [~, filename, ~] = fileparts(file);

                        %% Load needed variables from psth and does the receptive field analysis
                        load(file, 'labeled_data', 'baseline_window', 'response_window', 'event_ts', ...
                            'event_strings', 'psth_struct');
                        %% Check psth variables to make sure they are not empty
                        empty_vars = check_variables(file, baseline_window, response_window, labeled_data, ...
                            event_ts, event_strings, psth_struct);
                        if empty_vars
                            continue
                        end

                        %% Add analysis window
                        [baseline_window, response_window] = create_analysis_windows(labeled_data, psth_struct, ...
                            config.pre_time, config.pre_start, config.pre_end, config.post_time, ...
                            config.post_start, config.post_end, config.bin_size);

                        %% Saving outputs
                        matfile = fullfile(psth_path, [filename, '.mat']);
                        %% Check PSTH output to make sure there are no issues with the output
                        empty_vars = check_variables(matfile, psth_struct, event_ts, event_strings);
                        if empty_vars
                            continue
                        end

                        %% Save file if all variables are not empty
                        save(matfile, 'psth_struct', 'event_ts', 'event_strings', 'labeled_data', 'baseline_window', 'response_window');
                        export_params(psth_path, 'format_psth', parsed_path, failed_path, animal_name, config);
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.rf_analysis
                rf_path = batch_recfield(animal_name, original_path, psth_path, 'receptive_field_analysis', ...
                    '.mat', 'PSTH', 'format', config, training_session_config_array);
            else
                rf_path = [psth_path, '/receptive_field_analysis'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, psth_path, 'psth_graphs', '.mat', 'PSTH', 'format', ...
                    config.bin_size, config.pre_time, config.post_time, config.pre_start, ...
                    config.pre_end, config.post_start, config.post_end, config.rf_analysis, rf_path, ...
                    config.make_region_subplot, config.sub_columns, config.sub_rows, training_session_config_array);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     Normalized Variance    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.nv_analysis
                batch_nv(animal_name, original_path, psth_path, 'normalized_variance_analysis', ...
                    '.mat', 'psth', 'format', config, training_session_config_array)
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.psth_classify
                batch_classify(animal_name, original_path, psth_path, 'classifier', '.mat', ...
                    'PSTH', 'format', config, training_session_config_array);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.info_analysis
                batch_info(animal_name, psth_path, 'mutual_info', ...
                    '.mat', 'psth', 'format', training_session_config_array);
            end
        end
    end
    toc(start_time);
end