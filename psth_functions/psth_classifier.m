function [confusion_matrix, mutual_info, correct_trials, performance] = psth_classifier(rr_data, unique_events)
    predicted_events = [];
    true_events = [];
    for event_i = 1:length(unique_events)
        event = unique_events{event_i};
        event_rr = rr_data.(event).relative_response;
        [tot_event_trials, ~] = size(event_rr);
        for trial = 1:tot_event_trials
            %% Get the trial template and update current event template to exclude trial
            trial_template = event_rr(trial, :);
            psth_template = event_rr;
            psth_template(trial, :) = [];
            psth_template = calc_psth(psth_template);
            rr_data.(event).psth = psth_template;

            %% Euclidian distance and fnding closest match
            euclidian_results = [unique_events, cell(length(unique_events), 1)];
            for template_event = 1:length(unique_events)
                template_name = unique_events{template_event};
                psth_template = rr_data.(template_name).psth;
                eucl_dist = sqrt(sum((psth_template - trial_template).^2));
                euclidian_results(template_event, end) = {eucl_dist};
            end

            %% Trial classification information
            [~, min_index] = min([euclidian_results{:, end}]);
            classified_event = euclidian_results{min_index, 1};
            predicted_events = [predicted_events; {classified_event}];
            true_events = [true_events; {event}];
        end
        rr_data.(event).psth = calc_psth(event_rr);
    end
    %% Find the information and performance for current chan_group
    confusion_matrix = confusionmat(true_events, predicted_events);
    mutual_info = I_confmatr(confusion_matrix);
    correct_trials = cellfun(@strcmp, true_events, predicted_events);
    performance = mean(correct_trials);
    correct_trials = table(true_events, predicted_events, correct_trials, ...
        'VariableNames', {'true', 'predicted', 'correct'});
end