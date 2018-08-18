function [classify_path] = crude_bootstrapper(psth_path, animal_name, boot_iterations, bin_size, pre_time, post_time, wanted_events, wanted_neurons, unit_classification)
    tic;
    % Grabs all the psth formatted files
    psth_mat_path = strcat(psth_path, '/*.mat');
    psth_files = dir(psth_mat_path);

    % Checks if a classify graph directory exists and if not it creates it
    classify_path = strcat(psth_path, '/classifier');
    if ~exist(classify_path, 'dir')
        mkdir(psth_path, 'classifier');
    end

    % Deletes the failed directory if it already exists
    failed_path = [classify_path, '/failed'];
    if exist(failed_path, 'dir') == 7
    delete([failed_path, '/*']);
    rmdir(failed_path);
    end

    %% Iterates through all the psth formated files and passes them into the clasifier
    for h = 1: length(psth_files)
        failed_bootstrapping = {};
        file = [psth_path, '/', psth_files(h).name];
        [file_path, file_name, file_extension] = fileparts(file);
        split_name = strsplit(file_name, '.');
        current_day = split_name{6};
        fprintf('Bootstrapping PSTH for %s on %s\n', animal_name, current_day);
        try
            load(file);

            for i = 1: boot_iterations
                if i == 1
                    classified_struct = struct;

                    % Preforms standard classification
                    classified_struct = crude_classifier(failed_path, file_name, event_struct.all_events, neuron_map, right_neurons, left_neurons, bin_size, pre_time, post_time, unit_classification, i, classified_struct);
                else
                    % Shuffle event labels from the events matrix
                    shuffled_event_labels = events(:,1);
                    shuffled_event_labels = shuffled_event_labels(randperm(length(shuffled_event_labels)));
                    shuffled_events = [shuffled_event_labels, events(:,2)];
                    % Recreate the event cell array for PSTH object
                    all_events = {};
                    for event = 1: length(wanted_events)
                        %% Slices out the desired trials from the events matrix (Inclusive range)
                        all_events = [all_events; event_strings{event}, {shuffled_events(shuffled_events == wanted_events(event), 2)}];
                    end
                    classified_struct = crude_classifier(failed_path, file_name, all_events, neuron_map, right_neurons, left_neurons, bin_size, pre_time, post_time, unit_classification, i, classified_struct);
                end
            end

            % Goes through all the struct fields in the classified struct
            % And corrects the info by subtracting the bootstrapped info off of the original info
            struct_names = fieldnames(classified_struct);
            for i = 1: length(struct_names)
                if contains(struct_names{i}, '_bootstrapped_info')
                    field_name = strsplit(struct_names{i}, '_');
                    channel_name = field_name{1};
                    classified_struct.(struct_names{i}) = mean(classified_struct.(struct_names{i}));
                    classified_struct.([channel_name, '_corrected_info']) = classified_struct.([channel_name, '_information']) - classified_struct.(struct_names{i});
                end
            end

            %% Saving classifier info
            % fprintf('Finished classifying for %s\n', current_day);
            all_events = event_struct.all_events;
            if unit_classification
                unit_path = [classify_path, '/unit'];
                if ~exist(unit_path, 'dir')
                    mkdir(classify_path, 'unit');
                end
                filename = ['UNIT_CLASSIFIED.', file_name, '.mat'];
                matfile = fullfile(unit_path, filename);
                save(matfile, 'classified_struct', 'neuron_map', 'all_events', 'total_neurons');
            else
                pop_path = [classify_path, '/population'];
                if ~exist(pop_path, 'dir')
                    mkdir(classify_path, 'population');
                end
                filename = ['POP_CLASSIFIED.', file_name, '.mat'];
                matfile = fullfile(pop_path, filename);
                save(matfile, 'classified_struct', 'neuron_map', 'all_events', 'total_neurons', 'right_neurons', 'left_neurons');
            end
        catch ME
            if ~exist(failed_path, 'dir')
                mkdir(classify_path, 'failed');
            end
            failed_bootstrapping{end + 1} = file_name;
            failed_bootstrapping{end, 2} = ME;
            filename = ['FAILED.', file_name, '.mat'];
            warning('%s failed to bootstrap\n', file_name);
            warning('Error: %s\n', ME.message);
            matfile = fullfile(failed_path, filename);
            save(matfile, 'failed_bootstrapping');
        end
    end
    toc;
end