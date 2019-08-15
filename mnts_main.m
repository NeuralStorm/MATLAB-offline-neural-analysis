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
        export_params(animal_path, 'main', config);
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
                [parsed_files, mnts_path, failed_path] = create_dir(parsed_path, 'mnts', '.mat');

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
                        [mnts_struct, event_ts, event_strings, labeled_data] = format_mnts(event_ts, ...
                            labeled_data, config.bin_size, config.pre_time, config.post_time, config.wanted_events, ...
                            config.trial_range, config.trial_lower_bound);

                        %% Saving outputs
                        matfile = fullfile(mnts_path, ['mnts_format_', filename, '.mat']);
                        %% Check PSTH output to make sure there are no issues with the output
                        empty_vars = check_variables(matfile, mnts_struct, event_ts, event_strings, labeled_data);
                        if empty_vars
                            continue
                        end

                        %% Save file if all variables are not empty
                        save(matfile, 'mnts_struct', 'event_ts', 'event_strings', 'labeled_data');
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
                [mnts_files, pca_path, failed_path] = create_dir(mnts_path, 'pca', '.mat');

                fprintf('PCA for %s \n', animal_name);
                %% Goes through all the files and performs pca according to the parameters set in config
                for file_index = 1:length(mnts_files)
                    try
                        %% pull info from filename and set up file path for analysis
                        file = fullfile(mnts_path, mnts_files(file_index).name);
                        [~, filename, ~] = fileparts(file);
                        filename = erase(filename, 'mnts_format_');
                        filename = erase(filename, 'mnts.format.');
                        load(file, 'event_ts', 'labeled_data', 'mnts_struct');
                        %% Check variables to make sure they are not empty
                        empty_vars = check_variables(file, event_ts, labeled_data, mnts_struct);
                        if empty_vars
                            continue
                        end

                        %% PCA
                        [component_results, labeled_data] = calc_pca(labeled_data, ...
                            mnts_struct, config.feature_filter, config.feature_value);

                        %% Saving the file
                        matfile = fullfile(pca_path, ['pc_analysis_', filename, '.mat']);
                        check_variables(matfile, component_results, labeled_data);
                        save(matfile, 'labeled_data', 'event_ts', 'component_results');
                        clear('labeled_data', 'event_ts', 'component_results');
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                fprintf('Finished PCA for %s. It took %s \n', ...
                    animal_name, num2str(toc(pca_start)));
            else
                pca_path = [mnts_path, '/pca'];
            end

            if config.convert_mnts_psth
                psth_path = batch_mnts_to_psth(animal_name, pca_path, 'psth', ...
                    '.mat', 'pc', 'analysis', 'pca_psth', config);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     Normalized Variance    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.nv_analysis
                batch_nv(animal_name, original_path, psth_path, 'normalized_variance_analysis', ...
                    '.mat', 'pca', 'psth', config)
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.rf_analysis
                pc_rf_path = batch_recfield(animal_name, original_path, psth_path, 'receptive_field_analysis', ...
                    '.mat', 'pca', 'psth', config);
            else
                pc_rf_path = [psth_path, '/receptive_field_analysis'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, psth_path, 'pc_graphs', '.mat', 'pca', 'psth', ...
                    config.bin_size, config.pre_time, config.post_time, config.pre_start, ...
                    config.pre_end, config.post_start, config.post_end, config.rf_analysis, pc_rf_path, ...
                    config.make_region_subplot, config.sub_columns, config.sub_rows);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.psth_classify
                batch_classify(animal_name, original_path, psth_path, 'classifier', '.mat', ...
                    'pca', 'psth', config);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.info_analysis
                batch_info(animal_name, psth_path, 'mutual_info', ...
                    '.mat', 'pca', 'psth');
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %             ICA            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.ic_analysis
                ica_start = tic;
                [mnts_files, ica_path, failed_path] = create_dir(mnts_path, 'ica', '.mat');
                fprintf('ICA for %s \n', animal_name);
                %% Goes through all the files and performs pca according to the parameters set in config
                for file_index = 1:length(mnts_files)
                    try
                        %% pull info from filename and set up file path for analysis
                        file = fullfile(mnts_path, mnts_files(file_index).name);
                        [~, filename, ~] = fileparts(file);
                        filename = erase(filename, 'mnts_format_');
                        filename = erase(filename, 'mnts.format.');
                        load(file, 'event_ts', 'labeled_data', 'mnts_struct');
                        %% Check variables to make sure they are not empty
                        empty_vars = check_variables(file, event_ts, labeled_data, mnts_struct);
                        if empty_vars
                            continue
                        end

                        %% ICA
                        [labeled_data, component_results] = calc_ica(labeled_data, mnts_struct, ...
                            config.ic_pc, config.extended, config.sphering, config.anneal, ...
                            config.anneal_deg, config.bias, config.momentum, config.max_steps, ...
                            config.stop, config.rnd_reset, config.verbose);

                        %% Saving the file
                        matfile = fullfile(ica_path, ['ic_analysis_', filename, '.mat']);
                        empty_vars = check_variables(matfile, labeled_data, component_results);
                        if empty_vars
                            continue
                        end
                        save(matfile, 'labeled_data', 'event_ts', 'component_results');
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                fprintf('Finished ICA for %s. It took %s \n', ...
                    animal_name, num2str(toc(ica_start)));
            end

            if config.convert_mnts_psth
                psth_path = batch_mnts_to_psth(animal_name, ica_path, 'psth', ...
                    '.mat', 'ic', 'analysis', 'ica_psth', config);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     Normalized Variance    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.nv_analysis
                batch_nv(animal_name, original_path, psth_path, 'normalized_variance_analysis', ...
                    '.mat', 'ica', 'psth', config)
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.rf_analysis
                ic_rf_path = batch_recfield(animal_name, original_path, psth_path, 'receptive_field_analysis', ...
                    '.mat', 'ica', 'psth', config);
            else
                ic_rf_path = [psth_path, '/receptive_field_analysis'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, psth_path, 'pc_graphs', '.mat', 'ica', 'psth', ...
                    config.bin_size, config.pre_time, config.post_time, config.pre_start, ...
                    config.pre_end, config.post_start, config.post_end, config.rf_analysis, ic_rf_path, ...
                    config.make_region_subplot, config.sub_columns, config.sub_rows);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.psth_classify
                batch_classify(animal_name, original_path, psth_path, 'classifier', '.mat', ...
                    'ica', 'psth', config);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.info_analysis
                batch_info(animal_name, psth_path, 'mutual_info', ...
                    '.mat', 'ica', 'psth');
            end

        end
    end
    toc(start_time);
end