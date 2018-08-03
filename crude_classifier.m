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

     % Creates a directory to store the failed files
     failed_path = [classify_path, '/failed'];
     if ~exist(failed_path, 'dir')
         mkdir(classify_path, 'failed');
     else
         delete([failed_path, '/*']);
     end

    %% Iterates through all the psth formated files to for classifiers
    for h = 1: length(psth_files)
        %% Creating all nec directories and paths to save graphs to
        % Creates file with absolute path to file location
        failed_classifying = {};
        file = [psth_path, '/', psth_files(h).name];
        [file_path, file_name, file_extension] = fileparts(file);
        split_name = strsplit(file_name, '.');
        current_day = split_name{6};
        fprintf('Classifying PSTH for %s on %s\n', animal_name, current_day);
        try
            load(file);
            events_cell = event_struct.all_events;
            
            classified_struct = struct;
            % Initialize dynamic struct fields
            classified_struct.deciscion = {};
            classified_struct.true_event = {};
            classified_struct.correct_trials = [];
            for i = 1:length(neuron_map)
                neuron = [neuron_map(i,1), neuron_map(i,2)];
                 % Creates the PSTH object using dark, unknown magic from mythical toolbox
                psth = NeuroToolbox.PSTHToolbox.PSTH(neuron, events_cell, 'bin_size', ... 
                bin_size, 'PSTH_window', [-abs(pre_time), post_time]);
                % create template from PSTH object using more dark magic
                template = NeuroToolbox.PSTHToolbox.SU_Classifier(psth);
                % peform classification using template with more excitement and fun...
                decoder_output = template.classify(neuron_map, events_cell, 'SameDataSet', true);
                classified_struct.(['neuron_', num2str(i), '_decorder']) = decoder_output;
                classified_struct.deciscion = [classified_struct.deciscion, decoder_output.Decision];
                classified_struct.true_event = [classified_struct.true_event, decoder_output.Event];
                correct_trials = cellfun(@strcmp, decoder_output.Decision, decoder_output.Event);
                classified_struct.correct_trials = [classified_struct.correct_trials, correct_trials];
                incorrect_trials = {};
                for trial = 1: length(correct_trials)
                    if ~correct_trials(trial)
                        incorrect_trials{end + 1, 1} = decoder_output.Event{trial};
                        incorrect_trials{end, 2} = decoder_output.Decision{trial};
                    end
                end
                classified_struct.(['neuron_', num2str(i), '_incorrect']) = incorrect_trials;
                classified_struct.(['neuron_', num2str(i), '_confusion']) = confusionmat(decoder_output.Event, decoder_output.Decision);
                classified_struct.(['neuron_', num2str(i), '_accuracy']) = mean(correct_trials);
                classified_struct.(['neuron_', num2str(i), '_PSTH_object']) = psth;
                fprintf('Finished classifying neuron %s\n', num2str(i));
            end
            %% Does population classification
            % % Creates the PSTH object using dark, unknown magic from mythical toolbox
            % psth = NeuroToolbox.PSTHToolbox.PSTH(neuron_map, events_cell, 'bin_size', ... 
            %         bin_size, 'PSTH_window', [-abs(pre_time), post_time], 'show_progress', true);
            % % create template from PSTH object using more dark magic
            % template = NeuroToolbox.PSTHToolbox.SU_Classifier(psth);
            % % peform classification using template with more excitement and fun...
            % decoder_output = template.classify(neuron_map, events_cell, 'BatchMode', true, 'SameDataSet', true);
            % quantify performance
            % correct_trials = cellfun(@strcmp, decoder_output.Decision, decoder_output.Event);
            % incorrect_trials = {};
            % for i = 1: length(correct_trials)
            %     if ~correct_trials(i)
            %         incorrect_trials{end + 1, 1} = decoder_output.Event{i};
            %         incorrect_trials{end, 2} = decoder_output.Decision{i};
            %     end
            % end
            % confusion_matrix = confusionmat(decoder_output.Event, decoder_output.Decision);
            % accuracy = mean(correct_trials);

            %% Saving classifier info
            fprintf('Finished classifying for %s\n', current_day);
            filename = ['CLASSIFIED.', file_name, '.mat'];
            matfile = fullfile(classify_path, filename);
            % save(matfile, 'psth', 'template', 'decoder_output', 'correct_trials', 'accuracy', 'neuron_map', ...
            %     'events_cell', 'incorrect_trials', 'confusion_matrix');
            save(matfile, 'classified_struct', 'neuron_map', 'events_cell');
        catch ME
            failed_classifying{end + 1} = file_name;
            failed_classifying{end, 2} = ME;
            filename = ['FAILED.', file_name, '.mat'];
            warning('%s failed to classify\n', file_name);
            warning('Error: %s\n', ME.message);
            matfile = fullfile(failed_path, filename);
            save(matfile, 'failed_classifying');
        end
    end
    toc;
end