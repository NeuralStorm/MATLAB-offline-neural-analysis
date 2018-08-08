function [classified_struct] = crude_classifer(failed_path, file_name, all_events, neuron_map, bin_size, pre_time, post_time, unit_classification, iteration, classified_struct)
    %% Crude classifier
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
                % fprintf('Finished classifying neuron %s\n', neuron_map{i, 1});
            end
        else
            % Creates the PSTH object using dark, unknown magic from mythical toolbox
            psth = NeuroToolbox.PSTHToolbox.PSTH(neuron_map, all_events, 'bin_size', ... 
                        bin_size, 'PSTH_window', [-abs(pre_time), post_time], 'show_progress', true);
            % create template from PSTH object using more dark magic
            template = NeuroToolbox.PSTHToolbox.SU_Classifier(psth);
            % peform classification using template with more excitement and fun...
            decoder_output = template.classify(neuron_map, all_events, 'BatchMode', true, 'SameDataSet', true);
            if iteration == 1
                classified_struct.population_decorder = decoder_output;
                classified_struct.deciscion = [classified_struct.deciscion, decoder_output.Decision];
                classified_struct.true_event = [classified_struct.true_event, decoder_output.Event];
                correct_trials = cellfun(@strcmp, decoder_output.Decision, decoder_output.Event);
                classified_struct.correct_trials = [classified_struct.correct_trials, correct_trials];
                classified_struct.population_confusion = confusionmat(decoder_output.Event, decoder_output.Decision);
                classified_struct.population_accuracy = mean(correct_trials);
                classified_struct.psth_object = psth;
                classified_struct.overall_classification = [classified_struct.true_event, classified_struct.deciscion, num2cell(classified_struct.correct_trials)];
            else
                classified_struct.population_booststrap_confusion = confusionmat(decoder_output.Event, decoder_output.Decision);
            end
            fprintf('Finished classifying population n %s\n', num2str(i));
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