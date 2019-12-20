function [] = state_space_main()
    %% Get directory with all animals and their data
    original_path = uigetdir(pwd);
    start_time = tic;
    animal_list = dir(original_path);
    animal_names = {animal_list([animal_list.isdir] == 1 & ~contains({animal_list.name}, '.')).name};
    for animal = 1:length(animal_names)
        animal_name = animal_names{animal};
        animal_path = fullfile(...
            animal_list(strcmpi(animal_names{animal}, {animal_list.name})).folder, animal_name);
        config = import_config(animal_path, 'kalman');
        check_time(config.pre_time, config.pre_start, config.pre_end, config.post_time, ...
            config.post_start, config.post_end, config.bin_size);
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
                    config.is_non_strobed_and_strobed, config.event_map, config.ignore_sessions);
            else
                parsed_path = [animal_path, '/parsed'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%       Label Channels       %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.label_channels
                batch_label(animal_path, animal_name, parsed_path);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     Process Sensor Data    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.process_grf
                config.cutoff_freq = config.cutoff_freq / (2 * config.sampling_rate);
                [kalman_path, ~] = create_dir(parsed_path, 'kalman');
                measurement_path = [animal_path, '/kalman_measurements'];
                measure_file_list = dir([measurement_path, '/*.csv']);
                file_list = get_file_list(parsed_path, '.mat', config.ignore_sessions);
                for file_index = 1:length(file_list)
                    parsed_file = [parsed_path, '/', file_list(file_index).name];
                    [~, filename, ~] = fileparts(parsed_file);
                    load(parsed_file, 'event_ts', 'labeled_data');
                    [~, ~, ~, session_num, ~, ~] = get_filename_info(filename);

                    grf_file = measure_file_list(contains({measure_file_list.name}, num2str(session_num)) & ...
                        contains({measure_file_list.name}, 'grf')).name;
                    %% Nates data
                    raw_data = readtable(fullfile(measurement_path, grf_file));
                    grf_table = raw_data(:, 1:3);
                    grf_table.Properties.VariableNames = {'fl_F','lh_F', 'rh_F'};

                    %% Center of Pressure calculation
                    if config.add_cop
                        disp('Calculating Center of pressure');
                        cop_tic = tic;
                        grf_table = calc_cop(grf_table, 1);
                        toc(cop_tic)
                        disp('Finished Center of pressure');
                    end
                    %% Bharads data
                    % bias_list = {measure_file_list(contains({measure_file_list.name}, num2str(session_num)) & ...
                    %     contains({measure_file_list.name}, 'bias')).name};
                    % bias_table = readtable(fullfile(measurement_path, bias_list{1}));
                    % biased_grf_table = readtable(fullfile(measurement_path, grf_file));
                    % grf_table = grf_bias_correction(bias_table, biased_grf_table);
                    %% Processing measurements --> turn into state in kalman

                    measurements = process_raw_grf(grf_table, event_ts, config.pre_time, config.post_time, config.bin_size, ...
                        config.sampling_rate, config.n_order, config.cutoff_freq, config.filter_type);

                    %% Saving the file
                    matfile = fullfile(kalman_path, [filename, '.mat']);
                    empty_vars = check_variables(matfile, event_ts, measurements);
                    if empty_vars
                        continue
                    end
                    save(matfile, 'measurements', 'event_ts', 'labeled_data', 'grf_table');
                end
            else
                kalman_path = [parsed_path, '/kalman'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%        Format PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.use_psth
                if config.create_psth
                    psth_path = batch_format_psth(parsed_path, animal_name, config);
                else
                    psth_path = [parsed_path, '/psth'];
                end
            elseif config.use_components
                if config.create_mnts
                    [mnts_path] = batch_format_mnts(parsed_path, animal_name, config);
                else
                    mnts_path = [parsed_path, '/mnts'];
                end

                if config.pc_analysis
                    component_path = batch_pca(mnts_path, animal_name, config);
                    analysis_type = 'pc';
                else
                    component_path = batch_ica(mnts_path, animal_name, config);
                    analysis_type = 'ic';
                end

                if config.convert_mnts_psth
                    psth_path = batch_mnts_to_psth(animal_name, component_path, 'psth', ...
                        '.mat', analysis_type, 'analysis', 'psth', config);
                end
            elseif config.use_trajectories
                psth_path = [parsed_path, '/psth'];
                %% Enforce psths exist
                if ~isfolder(psth_path)
                    warning('Need PSTHs for GPFA. Creating PSTHs...');
                    psth_path = batch_format_psth(parsed_path, animal_name, config);
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%       Filter Trials        %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if config.filter_trials
                    %PSTH Path changes here to use the trial observations desired and not alter the original PSTHs
                    fprintf('Filtering trials for %s', animal_name)
                    psth_path = batch_state_filter_trials(parsed_path, kalman_path, config);
                else
                    psth_path = [parsed_path, '/gpfa'];
                end

                % change psth path to use trajectory psths
                if config.gpf_analysis
                    psth_path = batch_gpfa(psth_path, config);
                end
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, psth_path, 'psth_graphs', '.mat', 'PSTH', 'format', ...
                    config.bin_size, config.pre_time, config.post_time, config.pre_start, ...
                    config.pre_end, config.post_start, config.post_end, config.rf_analysis, [], ...
                    config.make_region_subplot, config.sub_columns, config.sub_rows, config.ignore_sessions);
            end

            if config.kalman_analysis
                batch_kalman(kalman_path, psth_path, config)
            end
        end
    end
    toc(start_time);
end