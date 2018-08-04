function [classify_path] = crude_classifer(psth_path, animal_name, bin_size, pre_time, post_time, wanted_events, tiltToolboxPath, decoderPath, unit_classification)
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
            classified_struct.overall_classification = {};
            if unit_classification
                for i = 1:length(neuron_map)
                    neuron = [neuron_map(i,1), neuron_map(i,2)];
                    % Creates the PSTH object using dark, unknown magic from mythical toolbox
                    psth = NeuroToolbox.PSTHToolbox.PSTH(neuron, events_cell, 'bin_size', ... 
                    bin_size, 'PSTH_window', [-abs(pre_time), post_time]);
                    % create template from PSTH object using more dark magic
                    template = NeuroToolbox.PSTHToolbox.SU_Classifier(psth);
                    % peform classification using template with more excitement and fun...
                    decoder_output = template.classify(neuron_map, events_cell, 'SameDataSet', true);
                    classified_struct.([neuron_map{i, 1}, '_decorder']) = decoder_output;
                    classified_struct.deciscion = [classified_struct.deciscion, decoder_output.Decision];
                    classified_struct.true_event = [classified_struct.true_event, decoder_output.Event];
                    correct_trials = cellfun(@strcmp, decoder_output.Decision, decoder_output.Event);
                    classified_struct.correct_trials = [classified_struct.correct_trials, correct_trials];
                    classified_struct.([neuron_map{i, 1}, '_confusion']) = confusionmat(decoder_output.Event, decoder_output.Decision);
                    classified_struct.([neuron_map{i, 1}, '_accuracy']) = mean(correct_trials);
                    classified_struct.([neuron_map{i, 1}, '_PSTH_object']) = psth;
                    % TODO figure out final saved output
                    classified_struct.([neuron_map{i, 1}, '_output']) = [decoder_output.Event, decoder_output.Decision, num2cell(correct_trials)];
                    fprintf('Finished classifying neuron %s\n', neuron_map{i, 1});
                end
            else
                % Creates the PSTH object using dark, unknown magic from mythical toolbox
                psth = NeuroToolbox.PSTHToolbox.PSTH(neuron_map, events_cell, 'bin_size', ... 
                            bin_size, 'PSTH_window', [-abs(pre_time), post_time], 'show_progress', true);
                % create template from PSTH object using more dark magic
                template = NeuroToolbox.PSTHToolbox.SU_Classifier(psth);
                % peform classification using template with more excitement and fun...
                decoder_output = template.classify(neuron_map, events_cell, 'BatchMode', true, 'SameDataSet', true);
                classified_struct.population_decorder = decoder_output;
                classified_struct.deciscion = [classified_struct.deciscion, decoder_output.Decision];
                classified_struct.true_event = [classified_struct.true_event, decoder_output.Event];
                correct_trials = cellfun(@strcmp, decoder_output.Decision, decoder_output.Event);
                classified_struct.correct_trials = [classified_struct.correct_trials, correct_trials];
                classified_struct.population_confusion = confusionmat(decoder_output.Event, decoder_output.Decision);
                classified_struct.population_accuracy = mean(correct_trials);
                classified_struct.psth_object = psth;
                classified_struct.overall_classification = [classified_struct.true_event, classified_struct.deciscion, num2cell(classified_struct.correct_trials)];
                fprintf('Finished classifying population n %s\n', num2str(i));
            end

            %% Saving classifier info
            fprintf('Finished classifying for %s\n', current_day);
            filename = ['CLASSIFIED.', file_name, '.mat'];
            matfile = fullfile(classify_path, filename);
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