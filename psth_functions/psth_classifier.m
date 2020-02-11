function [confusion_matrix, mutual_info, predicted_events, true_events, correct_trials, performance] = psth_classifier(psth_struct, event_strings)
    predicted_events = [];
    true_events = [];
    for event = 1:length(event_strings)
        current_event = event_strings{event};
        current_response = psth_struct.(current_event).relative_response;
        [tot_event_trials, ~] = size(current_response);
        for trial = 1:tot_event_trials
            %% Get the trial template and update current event template to exclude trial
            trial_template = current_response(trial, :);
            psth_template = current_response;
            psth_template(trial, :) = [];
            psth_template = sum(psth_template) / (tot_event_trials - 1);
            psth_struct.(current_event).psth = psth_template;

            %% Euclidian distance and fnding closest match
            euclidian_results = [event_strings', cell(length(event_strings), 1)];
            for template_event = 1:length(event_strings)
                template_name = event_strings{template_event};
                psth_template = psth_struct.(template_name).psth;
                euclidian_distance = sqrt(sum((psth_template - trial_template).^2));
                euclidian_results(template_event, end) = {euclidian_distance};
            end

            %% Trial classification information
            [~, min_index] = min([euclidian_results{:, end}]);
            classified_event = euclidian_results{min_index, 1};
            predicted_events = [predicted_events; {classified_event}];
            true_events = [true_events; {current_event}];
        end
        psth_struct.(current_event).psth = sum(current_response) / tot_event_trials;
    end
    %% Find the information and performance for current region
    confusion_matrix = confusionmat(true_events, predicted_events);
    mutual_info = I_confmatr(confusion_matrix);
    correct_trials = cellfun(@strcmp, true_events, predicted_events);
    performance = mean(correct_trials);
    correct_trials = table(true_events, predicted_events, correct_trials, ...
        'VariableNames', {'true', 'predicted', 'correct'});
end