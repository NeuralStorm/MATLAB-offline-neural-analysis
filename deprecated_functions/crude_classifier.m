function [classified_struct] = crude_classifier(classify_path, failed_path, file_name, all_events, labeled_data, bin_size, pre_time, post_time, unit_classification, iteration, classified_struct)
    %% Crude classifier
    if pre_time ~= 0
        warning('The classifier will try and classify on the time period before the event took place. Consider changing pre time to 0');
    end
    try
        region_names = fieldnames(labeled_data);
        if unit_classification
            for region = 1:length(region_names)
                current_region = region_names{region};
                for unit = 1:length(labeled_data.(current_region))
                    neuron_name = labeled_data.(current_region){unit};
                    neuron = [neuron_name, labeled_data.(current_region)(unit, 4)];
                    region_map = [labeled_data.(current_region)(:,1), labeled_data.(current_region)(:,4)];
                    % Creates the PSTH object using dark, unknown magic from mythical toolbox
                    psth = NeuroToolbox.PSTHToolbox.PSTH(neuron, all_events, 'bin_size', ... 
                        bin_size, 'PSTH_window', [-abs(pre_time), post_time]);
                    % create template from PSTH object using more dark magic
                    template = NeuroToolbox.PSTHToolbox.SU_Classifier(psth);
                    % peform classification using template with more excitement and fun...
                    decoder_output = template.classify(region_map, all_events, 'SameDataSet', true);
                    if iteration == 1
                        % Initialize dynamic struct fields
                        classified_struct.(current_region).deciscion = {};
                        classified_struct.(current_region).true_event = {};
                        classified_struct.(current_region).correct_trials = [];
                        classified_struct.(current_region).([neuron_name, '_bootstrapped_info']) = [];
                        classified_struct.(current_region).([neuron_name, '_decorder']) = decoder_output;
                        classified_struct.(current_region).deciscion = [classified_struct.(current_region).deciscion, decoder_output.Decision];
                        classified_struct.(current_region).true_event = [classified_struct.(current_region).true_event, decoder_output.Event];
                        correct_trials = cellfun(@strcmp, decoder_output.Decision, decoder_output.Event);
                        classified_struct.(current_region).correct_trials = [classified_struct.(current_region).correct_trials, correct_trials];
                        classified_struct.(current_region).([neuron_name, '_confusion']) = confusionmat(decoder_output.Event, decoder_output.Decision);
                        classified_struct.(current_region).([neuron_name, '_information']) = I_confmatr(classified_struct.(current_region).([neuron_name, '_confusion']));
                        classified_struct.(current_region).([neuron_name, '_accuracy']) = mean(correct_trials);
                        classified_struct.(current_region).([neuron_name, '_PSTH_object']) = psth;
                        % TODO figure out final saved output
                        classified_struct.(current_region).([neuron_name, '_output']) = [decoder_output.Event, decoder_output.Decision, num2cell(correct_trials)];
                    else
                        bootstrapped_confusion = confusionmat(decoder_output.Event, decoder_output.Decision);
                        bootstrapped_info = I_confmatr(bootstrapped_confusion);
                        classified_struct.(current_region).([neuron_name, '_bootstrapped_info']) = [classified_struct.(current_region).([neuron_name, '_bootstrapped_info']); bootstrapped_info];
                    end
                end
            end
        else
            for region = 1:length(region_names)
                current_region = region_names{region};
                region_neurons = [labeled_data.(region_names{region})(:,1), labeled_data.(region_names{region})(:,4)];
                region_psth = NeuroToolbox.PSTHToolbox.PSTH(region_neurons, all_events, 'bin_size', ... 
                    bin_size, 'PSTH_window', [-abs(pre_time), post_time]);
                region_template = NeuroToolbox.PSTHToolbox.SU_Classifier(region_psth);
                region_decoder_output = region_template.classify(region_neurons, all_events, 'SameDataSet', true);
                if iteration == 1
                    % Initialize dynamic struct fields
                    classified_struct.(current_region).deciscion = {};
                    classified_struct.(current_region).true_event = {};
                    classified_struct.(current_region).correct_trials = [];
                    classified_struct.(current_region).decorder = region_decoder_output;
                    classified_struct.(current_region).deciscion = [classified_struct.(current_region).deciscion, region_decoder_output.Decision];
                    classified_struct.(current_region).true_event = [classified_struct.(current_region).true_event, region_decoder_output.Event];
                    correct_trials = cellfun(@strcmp, region_decoder_output.Decision, region_decoder_output.Event);
                    classified_struct.(current_region).correct_trials = [classified_struct.(current_region).correct_trials, correct_trials];
                    classified_struct.(current_region).confusion = confusionmat(region_decoder_output.Event, region_decoder_output.Decision);
                    classified_struct.(current_region).accuracy = mean(correct_trials);
                    classified_struct.(current_region).psth_object = region_psth;
                    classified_struct.(current_region).overall_classification = [classified_struct.(current_region).true_event, classified_struct.(current_region).deciscion, num2cell(classified_struct.(current_region).correct_trials)];
                    classified_struct.(current_region).information = I_confmatr(classified_struct.(current_region).confusion);
                    classified_struct.(current_region).bootstrapped_info = [];
                else
                    region_bootstrapped_confusion = confusionmat(region_decoder_output.Event, region_decoder_output.Decision);
                    region_bootstrapped_info = I_confmatr(region_bootstrapped_confusion);
                    classified_struct.(current_region).bootstrapped_info = [classified_struct.(current_region).bootstrapped_info; region_bootstrapped_info];
                end
            end
        end
    catch ME
        if ~exist(failed_path, 'dir')
            mkdir(classify_path, 'failed');
        end
        filename = ['FAILED.', file_name, '.mat'];
        error_message = getReport( ME, 'extended', 'hyperlinks', 'on');
        warning('%s failed to classify\n', file_name);
        warning(error_message);
        matfile = fullfile(failed_path, filename);
        save(matfile, 'ME');
    end
end