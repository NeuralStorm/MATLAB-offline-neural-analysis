function [classify_path] = crude_classifer(psth_path, animal_name, bin_size, pre_time, post_time, wanted_events, tiltToolboxPath, decoderPath)
    tic;
    %% Crude classifier
    % Grabs all the psth formatted files
    psth_mat_path = strcat(psth_path, '/*.mat');
    psth_files = dir(psth_mat_path);

    % Checks if a classify graph directory exists and if not it creates it
    classify_path = strcat(psth_path, '/classifier');
    if ~exist(classify_path, 'dir')
        mkdir(psth_path, 'classifier');
    end

    % ! DEPRICATED BLOCK:
    % ! Creates event_strings for comptability between versions of calculate_PSTH
    % ! This will be depricated in the future after classification is done
    % ! calculate_PSTH.m returns the event_strings, but we do not want to have to recalculate
    event_strings = {};
    for i = 1: length(wanted_events)
        event_strings{end+1} = ['event_', num2str(wanted_events(i))];
    end

    %% Iterates through all the psth formated files to for classifiers
    for h = 1: length(psth_files)
        %% Creating all nec directories and paths to save graphs to
        % Creates file with absolute path to file location
        file = [psth_path, '/', psth_files(h).name];
        [~, name_str, ~] = fileparts(file);
        split_name = strsplit(name_str, '.');
        current_day = split_name{6};
        fprintf('Classifying PSTH for %s on %s\n', animal_name, current_day);
        load(file);
        struct_names = fieldnames(event_struct);
        % [~, idx] = ismember(event_strings(2), struct_names)
        % Creates the event cell array needed to create the PSTH object
        all_events = {}; % Equivialent to reference
        for i = 1: length(event_strings)
            event = getfield(event_struct, event_strings{i});
            all_events = [all_events, event];
        end
        events_cell = [event_strings', all_events'];
        % Creates tge PSTH object using dark, unknown magic from mythical toolbox
        psth = NeuroToolbox.PSTHToolbox.PSTH(neuron_map, events_cell, 'bin_size', ... 
                bin_size, 'PSTH_window', [-abs(pre_time), post_time], 'show_progress', true);
        % create template from PSTH object using more dark magic
        template = NeuroToolbox.PSTHToolbox.SU_Classifier(psth);
        % peform classification using template with more excitement and fun...
        decoder_output = template.classify(neuron_map, events_cell, 'SameDataSet', true);
        % quantify performance
        correct_trials = cellfun(@strcmp, decoder_output.Decision, decoder_output.Event);
        incorrect_trials = {};
        for i = 1: length(correct_trials)
            if ~correct_trials(i)
                % Correct trial
                % correct_event = strsplit(decoder_output.Event{i}, '_');
                % incorrect_event = strsplit(decoder_output.Decision{i}, '_');
                incorrect_trials{end + 1, 1} = decoder_output.Event{i};
                incorrect_trials{end, 2} = decoder_output.Decision{i};
            end
        end
        tabulated_correct = tabulate(incorrect_trials(:, 1));
        tabulated_incorrect = tabulate(incorrect_trials(:, 2));
        accuracy = mean(correct_trials);

        %% Saving classifier info
        fprintf('Finished classifying for %s\n', current_day);
        [~ ,namestr, ~] = fileparts(file);
        filename = strcat('classifier.format.', namestr);
        filename = strcat(filename, '.mat');
        matfile = fullfile(classify_path, filename);
        save(matfile, 'psth', 'template', 'decoder_output', 'correct_trials', 'accuracy', 'neuron_map', ...
            'events_cell', 'incorrect_trials', 'tabulated_correct', 'tabulated_incorrect');
    end
    toc;
end