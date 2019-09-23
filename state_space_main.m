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
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%        Format PSTH         %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %TODO add option for pca/ica or psth
        if config.create_psth
            psth_path = batch_format_psth(parsed_path, animal_name, config);
        else
            psth_path = [parsed_path, '/psth'];
        end

        if config.process_grf
            config.cutoff_freq = config.cutoff_freq / (2 * config.sampling_rate);
            [kalman_path, ~] = create_dir(parsed_path, 'kalman');
            measurement_path = [animal_path, '/kalman_measurements'];
            file_list = dir([measurement_path, '/*.csv']);
            for file_index = 1:length(file_list)
                file = [measurement_path, '/', file_list(file_index).name];
                [~, filename, ~] = fileparts(file);
                psth_filename = erase(filename, '.grf');
                psth_file = fullfile(psth_path, ['psth_format_', psth_filename, '.mat']);
                load(psth_file, 'event_ts', 'labeled_data', 'psth_struct');
                data = readtable(file);
                grf_table = data(:, 1:3);
                grf_table.Properties.VariableNames = {'forelimb','left_hindlimb', 'right_hindlimb'};
                measurements = process_raw_grf(grf_table, event_ts, config.pre_time, config.post_time, config.bin_size, ...
                    config.sampling_rate, config.n_order, config.cutoff_freq, config.filter_type);

                %% Saving the file
                matfile = fullfile(kalman_path, [filename, '.mat']);
                empty_vars = check_variables(matfile, event_ts, measurements);
                if empty_vars
                    continue
                end
                save(matfile, 'measurements', 'event_ts', 'labeled_data', 'psth_struct');
            end
        end

        if config.kalman_analysis
            batch_kalman(kalman_path, psth_path, config)
        end



    end
    toc(start_time);
end