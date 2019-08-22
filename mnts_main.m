function [] = mnts_main()
    %% Get directory with all animals and their data
    original_path = uigetdir(pwd);
    start_time = tic;
    animal_list = dir(original_path);
    animal_names = {animal_list([animal_list.isdir] == 1 & ~contains({animal_list.name}, '.')).name};
    for animal = 1:length(animal_names)
        animal_name = animal_names{animal};
        animal_path = fullfile(...
            animal_list(strcmpi(animal_names{animal}, {animal_list.name})).folder, animal_name);
        config = import_config(animal_path);
        total_bins = (length(-abs(config.pre_time):config.bin_size:abs(config.post_time)) - 1);
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
                label_neurons(animal_path, animal_name, parsed_path);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%            MNTS            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.create_mnts
                mnts_start = tic;
                [parsed_files, mnts_path, failed_path] = create_dir(parsed_path, 'mnts', '.mat', training_session_config_array);

                fprintf('Calculating mnts for %s \n', animal_name);
                %% Goes through all the files and creates mnts according to the parameters set in config
                for file_index = 1:length(parsed_files)
                    try
                        %% Load file contents
                        file = [parsed_path, '/', parsed_files(file_index).name];
                        [~, filename, ~] = fileparts(file);
                        load(file, 'event_ts', 'labeled_neurons');
                        %% Check parsed variables to make sure they are not empty
                        empty_vars = check_variables(file, event_ts, labeled_neurons);
                        if empty_vars
                            continue
                        end

                        %% Format mnts
                        [mnts_struct, event_ts, event_strings, labeled_neurons] = format_mnts(event_ts, ...
                            labeled_neurons, config.bin_size, config.pre_time, config.post_time, config.wanted_events, ...
                            config.trial_range, config.trial_lower_bound);

                        %% Saving outputs
                        matfile = fullfile(mnts_path, ['mnts_format_', filename, '.mat']);
                        %% Check PSTH output to make sure there are no issues with the output
                        empty_vars = check_variables(matfile, mnts_struct, event_ts, event_strings, labeled_neurons);
                        if empty_vars
                            continue
                        end

                        %% Save file if all variables are not empty
                        save(matfile, 'mnts_struct', 'event_ts', 'event_strings', 'labeled_neurons');
                        export_params(mnts_path, 'mnts_psth', parsed_path, failed_path, animal_name, config);
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                fprintf('Finished calculating mnts for %s. It took %s \n', ...
                    animal_name, num2str(toc(mnts_start)));
            else
                mnts_path = [parsed_path, '/mnts'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %             PCA            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.pc_analysis
                pca_start = tic;
                [mnts_files, pca_path, failed_path] = create_dir(mnts_path, 'pca', '.mat', training_session_config_array);

                fprintf('PCA for %s \n', animal_name);
                %% Goes through all the files and performs pca according to the parameters set in config
                for file_index = 1:length(mnts_files)
                    try
                        %% pull info from filename and set up file path for analysis
                        file = fullfile(mnts_path, mnts_files(file_index).name);
                        [~, filename, ~] = fileparts(file);
                        filename = erase(filename, 'mnts_format_');
                        filename = erase(filename, 'mnts.format.');
                        load(file, 'event_ts', 'labeled_neurons', 'mnts_struct');
                        %% Check variables to make sure they are not empty
                        empty_vars = check_variables(file, event_ts, labeled_neurons, mnts_struct);
                        if empty_vars
                            continue
                        end

                        %% PCA
                        [pca_results, event_struct, labeled_neurons] = calc_pca(labeled_neurons, ...
                            mnts_struct, config.bin_size, config.pre_time, ...
                            config.post_time, config.feature_filter, config.feature_value);

                        %% Saving the file
                        matfile = fullfile(pca_path, ['pc_analysis_', filename, '.mat']);
                        check_variables(matfile, event_struct, pca_results, labeled_neurons);
                        save(matfile, 'event_struct', 'labeled_neurons', 'event_ts', 'pca_results');
                        clear('event_struct', 'labeled_neurons', 'event_ts', 'pca_results');
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                fprintf('Finished PCA for %s. It took %s \n', ...
                    animal_name, num2str(toc(pca_start)));
            else
                pca_path = [mnts_path, '/pca'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     Normalized Variance    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.nv_analysis
                batch_nv(animal_name, original_path, pca_path, 'normalized_variance_analysis', ...
                    '.mat', 'pc', 'analysis', config, training_session_config_array)
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.rf_analysis
                pc_rf_path = batch_recfield(animal_name, original_path, pca_path, 'receptive_field_analysis', ...
                    '.mat', 'pc', 'analysis', config, training_session_config_array);
            else
                pc_rf_path = [pca_path, '/receptive_field_analysis'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, pca_path, 'pc_graphs', '.mat', 'pc', 'analysis', ...
                    config.bin_size, config.pre_time, config.post_time, config.rf_analysis, pc_rf_path, ...
                    config.make_region_subplot, config.sub_columns, config.sub_rows, training_session_config_array);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.psth_classify
                batch_classify(animal_name, original_path, pca_path, 'classifier', '.mat', 'pc', 'analysis', ...
                    config.boot_iterations, config.bootstrap_classifier, config.bin_size, ...
                    config.pre_time, config.post_time, training_session_config_array);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.info_analysis
                batch_info(animal_name, pca_path, 'mutual_info', ...
                    '.mat', 'pc', 'analysis', training_session_config_array);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %             ICA            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.ic_analysis
                ica_start = tic;
                [mnts_files, ica_path, failed_path] = create_dir(mnts_path, 'ica', '.mat', training_session_config_array);
                fprintf('ICA for %s \n', animal_name);
                %% Goes through all the files and performs pca according to the parameters set in config
                for file_index = 1:length(mnts_files)
                    try
                        %% pull info from filename and set up file path for analysis
                        file = fullfile(mnts_path, mnts_files(file_index).name);
                        [~, filename, ~] = fileparts(file);
                        filename = erase(filename, 'mnts_format_');
                        filename = erase(filename, 'mnts.format.');
                        load(file, 'event_ts', 'labeled_neurons', 'mnts_struct');
                        %% Check variables to make sure they are not empty
                        empty_vars = check_variables(file, event_ts, labeled_neurons, mnts_struct);
                        if empty_vars
                            continue
                        end

                        %% ICA
                        [labeled_neurons, event_struct, ica_results] = ...
                            calc_ica(labeled_neurons, mnts_struct, config.pre_time, config.post_time, ...
                            config.bin_size, config.ic_pc, config.extended, config.sphering, ...
                            config.anneal, config.anneal_deg, config.bias, config.momentum, ...
                            config.max_steps, config.stop, config.rnd_reset, config.verbose);

                        %% Saving the file
                        matfile = fullfile(ica_path, ['ic_analysis_', filename, '.mat']);
                        empty_vars = check_variables(matfile, labeled_neurons, event_struct, ica_results);
                        if empty_vars
                            continue
                        end
                        save(matfile, 'event_struct', 'labeled_neurons', 'event_ts', 'ica_results');
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                fprintf('Finished ICA for %s. It took %s \n', ...
                    animal_name, num2str(toc(ica_start)));
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     Normalized Variance    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.nv_analysis
                batch_nv(animal_name, original_path, ica_path, 'normalized_variance_analysis', ...
                    '.mat', 'ic', 'analysis', config, training_session_config_array)
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.rf_analysis
                ic_rf_path = batch_recfield(animal_name, original_path, ica_path, 'receptive_field_analysis', ...
                    '.mat', 'ic', 'analysis', config, training_session_config_array);
            else
                ic_rf_path = [ica_path, '/receptive_field_analysis'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, ica_path, 'ic_graphs', '.mat', 'ic', 'analysis', ...
                    config.bin_size, config.pre_time, config.post_time, config.rf_analysis, ic_rf_path, ...
                    config.make_region_subplot, config.sub_columns, config.sub_rows, training_session_config_array);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.psth_classify
                batch_classify(animal_name, original_path, ica_path, 'classifier', '.mat', 'ic', 'analysis', ...
                    config.boot_iterations, config.bootstrap_classifier, config.bin_size, ...
                    config.pre_time, config.post_time, training_session_config_array);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.info_analysis
                batch_info(animal_name, ica_path, 'mutual_info', ...
                    '.mat', 'ic', 'analysis', training_session_config_array);
            end

        end
    end
    toc(start_time);
end