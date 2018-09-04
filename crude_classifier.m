function [classified_struct] = crude_classifer(failed_path, file_name, all_events, neuron_map, labeled_neurons, bin_size, pre_time, post_time, unit_classification, iteration, classified_struct)
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
            region_names = fieldnames(labeled_neurons);
            for region = 1:length(region_names)
                region_neurons = [labeled_neurons.(region_names{region})(:,1), labeled_neurons.(region_names{region})(:,end)];
                region_psth = NeuroToolbox.PSTHToolbox.PSTH(region_neurons, all_events, 'bin_size', ... 
                    bin_size, 'PSTH_window', [-abs(pre_time), post_time]);
                region_template = NeuroToolbox.PSTHToolbox.SU_Classifier(region_psth);
                region_decoder_output = region_template.classify(region_neurons, all_events, 'SameDataSet', true);
                if iteration == 1
                    % Initialize dynamic struct fields
                    classified_struct.([region_names{region}, '_deciscion']) = {};
                    classified_struct.([region_names{region}, '_true_event']) = {};
                    classified_struct.([region_names{region}, '_correct_trials']) = [];
                    classified_struct.([region_names{region}, '_decorder']) = region_decoder_output;
                    classified_struct.([region_names{region}, '_deciscion']) = [classified_struct.([region_names{region}, '_deciscion']), region_decoder_output.Decision];
                    classified_struct.([region_names{region}, '_true_event']) = [classified_struct.([region_names{region}, '_true_event']), region_decoder_output.Event];
                    correct_trials = cellfun(@strcmp, region_decoder_output.Decision, region_decoder_output.Event);
                    classified_struct.([region_names{region}, '_correct_trials']) = [classified_struct.([region_names{region}, '_correct_trials']), correct_trials];
                    classified_struct.([region_names{region}, '_confusion']) = confusionmat(region_decoder_output.Event, region_decoder_output.Decision);
                    classified_struct.([region_names{region}, '_accuracy']) = mean(correct_trials);
                    classified_struct.([region_names{region}, '_psth_object']) = region_psth;
                    classified_struct.([region_names{region}, '_overall_classification']) = [classified_struct.([region_names{region}, '_true_event']), classified_struct.([region_names{region}, '_deciscion']), num2cell(classified_struct.([region_names{region}, '_correct_trials']))];
                    classified_struct.([region_names{region}, '_information']) = I_confmatr(classified_struct.([region_names{region}, '_confusion']));
                    classified_struct.([region_names{region}, '_bootstrapped_info']) = [];
                else
                    region_bootstrapped_confusion = confusionmat(region_decoder_output.Event, region_decoder_output.Decision);
                    region_bootstrapped_info = I_confmatr(region_bootstrapped_confusion);
                    classified_struct.([region_names{region}, '_bootstrapped_info']) = [classified_struct.([region_names{region}, '_bootstrapped_info']); region_bootstrapped_info];
                end
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