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
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%        Format PSTH         %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if config.create_psth
            psth_start = tic;
            % warning('Since the pre time is set to 0, there will not be a psth generated with only the pre time activity.\n');
            [parsed_files, psth_path, failed_path] = create_dir(parsed_path, 'psth', '.mat');

            fprintf('Calculating PSTH for %s \n', animal_name);
            %% Goes through all the files and creates PSTHs according to the parameters set in config
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

                    %% Format PSTH
                    [event_struct, event_ts, event_strings] = ...
                        format_PSTH(event_ts, labeled_neurons, config.bin_size, config.pre_time, ...
                        config.post_time, config.wanted_events, config.trial_range, config.trial_lower_bound);

                    %% Saving outputs
                    matfile = fullfile(psth_path, ['PSTH_format_', filename, '.mat']);
                    %% Check PSTH output to make sure there are no issues with the output
                    empty_vars = check_variables(matfile, event_struct, event_ts, event_strings);
                    if empty_vars
                        continue
                    end

                    %% Save file if all variables are not empty
                    save(matfile, 'event_struct', 'event_ts', 'event_strings', 'labeled_neurons');
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

        %! Add variables to config
        process_grf = true;
        sampling_rate = 1000;
        n_order = 2;
        cutoff_freq = 200 / sampling_rate;
        filter_type = 'low';
        if process_grf
            [~, kalman_path, ~] = create_dir(parsed_path, 'kalman', '.csv');
            measurement_path = [animal_path, '/kalman_measurements'];
            file_list = dir([measurement_path, '/*.csv']);
            for file_index = 1:length(file_list)
                file = [measurement_path, '/', file_list(file_index).name];
                [~, filename, ~] = fileparts(file);
                psth_filename = erase(filename, '.grf');
                psth_file = fullfile(psth_path, ['psth_format_', psth_filename, '.mat']);
                load(psth_file, 'event_ts', 'labeled_neurons', 'event_struct');
                data = readtable(file);
                grf_table = data(:, 1:3);
                grf_table.Properties.VariableNames = {'forelimb','left_hindlimb', 'right_hindlimb'};
                measurements = process_raw_grf(grf_table, event_ts, config.pre_time, config.post_time, config.bin_size, ...
                    sampling_rate, n_order, cutoff_freq, filter_type);

                %% Saving the file
                matfile = fullfile(kalman_path, [filename, '.mat']);
                empty_vars = check_variables(matfile, event_ts, measurements);
                if empty_vars
                    continue
                end
                save(matfile, 'measurements', 'event_ts', 'labeled_neurons', 'event_struct');
            end
        end

        % % %! Add variables to config
        % is_kalman = true;
        % if is_kalman
        %     [file_list, closed_path, ~] = create_dir(kalman_path, 'closed_form', '.mat');
        %     for file_index = 1:length(file_list)
        %         file = [kalman_path, '/', file_list(file_index).name];
        %         [~, filename, ~] = fileparts(file);
        %         psth_filename = erase(filename, '.grf');
        %         psth_file = fullfile(psth_path, ['psth_format_', psth_filename, '.mat']);
        %         load(psth_file, 'event_ts', 'labeled_neurons', 'event_struct');


        %         %% Saving the file
        %         matfile = fullfile(kalman_path, [filename, '.mat']);
        %         empty_vars = check_variables(matfile, event_ts, grf_responses);
        %         if empty_vars
        %             continue
        %         end
        %         save(matfile, 'grf_responses', 'event_ts', 'labeled_neurons', 'event_struct');
        %     end
        % end



    end
    toc(start_time);
end