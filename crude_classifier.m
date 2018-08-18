function [classified_struct] = crude_classifer(failed_path, file_name, all_events, neuron_map, right_neurons, left_neurons, bin_size, pre_time, post_time, unit_classification, iteration, classified_struct)
    %% Crude classifier
    if pre_time ~= 0
        warning('The classifier will try and classify on the time period before the event took place. Consider changing pre time to 0');
    end
    try
        failed_classifying = {};
        if unit_classification
            for i = 1:length(neuron_map)
                neuron = [neuron_map(i,1), neuron_map(i,2)];
                % Creates the PSTH object using dark, unknown magic from mythical toolbox
                psth = NeuroToolbox.PSTHToolbox.PSTH(neuron, all_events, 'bin_size', ... 
                    bin_size, 'PSTH_window', [-abs(pre_time), post_time]);
                % create template from PSTH object using more dark magic
                template = NeuroToolbox.PSTHToolbox.SU_Classifier(psth);
                % peform classification using template with more excitement and fun...
                decoder_output = template.classify(neuron_map, all_events, 'SameDataSet', true);
                if iteration == 1
                    % Initialize dynamic struct fields
                    classified_struct.deciscion = {};
                    classified_struct.true_event = {};
                    classified_struct.correct_trials = [];
                    classified_struct.([neuron_map{i, 1}, '_bootstrapped_info']) = [];
                    classified_struct.([neuron_map{i, 1}, '_decorder']) = decoder_output;
                    classified_struct.deciscion = [classified_struct.deciscion, decoder_output.Decision];
                    classified_struct.true_event = [classified_struct.true_event, decoder_output.Event];
                    correct_trials = cellfun(@strcmp, decoder_output.Decision, decoder_output.Event);
                    classified_struct.correct_trials = [classified_struct.correct_trials, correct_trials];
                    classified_struct.([neuron_map{i, 1}, '_confusion']) = confusionmat(decoder_output.Event, decoder_output.Decision);
                    classified_struct.([neuron_map{i, 1}, '_information']) = I_confmatr(classified_struct.([neuron_map{i, 1}, '_confusion']));
                    classified_struct.([neuron_map{i, 1}, '_accuracy']) = mean(correct_trials);
                    classified_struct.([neuron_map{i, 1}, '_PSTH_object']) = psth;
                    % TODO figure out final saved output
                    classified_struct.([neuron_map{i, 1}, '_output']) = [decoder_output.Event, decoder_output.Decision, num2cell(correct_trials)];
                else
                    bootstrapped_confusion = confusionmat(decoder_output.Event, decoder_output.Decision);
                    bootstrapped_info = I_confmatr(bootstrapped_confusion);
                    classified_struct.([neuron_map{i, 1}, '_bootstrapped_info']) = [classified_struct.([neuron_map{i, 1}, '_bootstrapped_info']); bootstrapped_info];
                end
            end
        else
            %% Right neurons
            % Creates the PSTH object using dark, unknown magic from mythical toolbox
            right_psth = NeuroToolbox.PSTHToolbox.PSTH(right_neurons, all_events, 'bin_size', ... 
                bin_size, 'PSTH_window', [-abs(pre_time), post_time]);
            % create template from PSTH object using more dark magic
            right_template = NeuroToolbox.PSTHToolbox.SU_Classifier(right_psth);
            % peform classification using template with more excitement and fun...
            right_decoder_output = right_template.classify(right_neurons, all_events, 'SameDataSet', true);
            %% Left neurons
            % Creates the PSTH object using dark, unknown magic from mythical toolbox
            left_psth = NeuroToolbox.PSTHToolbox.PSTH(left_neurons, all_events, 'bin_size', ... 
                bin_size, 'PSTH_window', [-abs(pre_time), post_time]);
            % create template from PSTH object using more dark magic
            left_template = NeuroToolbox.PSTHToolbox.SU_Classifier(left_psth);
            % peform classification using template with more excitement and fun...
            left_decoder_output = left_template.classify(left_neurons, all_events, 'SameDataSet', true);
            if iteration == 1
                % Initialize dynamic struct fields
                classified_struct.right_deciscion = {};
                classified_struct.right_true_event = {};
                classified_struct.right_correct_trials = [];
                classified_struct.left_deciscion = {};
                classified_struct.left_true_event = {};
                classified_struct.left_correct_trials = [];
                %% Right neurons
                classified_struct.right_decorder = right_decoder_output;
                classified_struct.right_deciscion = [classified_struct.right_deciscion, right_decoder_output.Decision];
                classified_struct.right_true_event = [classified_struct.right_true_event, right_decoder_output.Event];
                right_correct_trials = cellfun(@strcmp, right_decoder_output.Decision, right_decoder_output.Event);
                classified_struct.right_correct_trials = [classified_struct.right_correct_trials, right_correct_trials];
                classified_struct.right_confusion = confusionmat(right_decoder_output.Event, right_decoder_output.Decision);
                classified_struct.right_accuracy = mean(right_correct_trials);
                classified_struct.right_psth_object = right_psth;
                classified_struct.right_overall_classification = [classified_struct.right_true_event, classified_struct.right_deciscion, num2cell(classified_struct.right_correct_trials)];
                classified_struct.right_information = I_confmatr(classified_struct.right_confusion);
                classified_struct.right_bootstrapped_info = [];
                %% Left Neurons
                classified_struct.left_decorder = left_decoder_output;
                classified_struct.left_deciscion = [classified_struct.left_deciscion, left_decoder_output.Decision];
                classified_struct.left_true_event = [classified_struct.left_true_event, left_decoder_output.Event];
                left_correct_trials = cellfun(@strcmp, left_decoder_output.Decision, left_decoder_output.Event);
                classified_struct.left_correct_trials = [classified_struct.left_correct_trials, left_correct_trials];
                classified_struct.left_confusion = confusionmat(left_decoder_output.Event, left_decoder_output.Decision);
                classified_struct.left_accuracy = mean(left_correct_trials);
                classified_struct.left_psth_object = left_psth;
                classified_struct.left_overall_classification = [classified_struct.left_true_event, classified_struct.left_deciscion, num2cell(classified_struct.left_correct_trials)];
                classified_struct.left_information = I_confmatr(classified_struct.left_confusion);
                classified_struct.left_bootstrapped_info = [];
            else
                %% Right Neurons
                right_bootstrapped_confusion = confusionmat(right_decoder_output.Event, right_decoder_output.Decision);
                right_bootstrapped_info = I_confmatr(right_bootstrapped_confusion);
                classified_struct.right_bootstrapped_info = [classified_struct.right_bootstrapped_info; right_bootstrapped_info];
                %% Left Neurons
                left_bootstrapped_confusion = confusionmat(left_decoder_output.Event, left_decoder_output.Decision);
                left_bootstrapped_info = I_confmatr(left_bootstrapped_confusion);
                classified_struct.left_bootstrapped_info = [classified_struct.left_bootstrapped_info; left_bootstrapped_info];
            end
        end
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