function [confusion_matrix, mutual_info, correct_trials, performance] = psth_classifier_templates(rr_data, event_info)
    predicted_events = [];
    unique_events = unique(event_info.event_labels);
    tot_trials = height(event_info);
    for trial_i = 1:tot_trials
        %% Get the trial template and update current event template to exclude trial
        trial = event_info.event_indices(trial_i);
        trial_template = rr_data(trial, :);

        %% Euclidian distance and fnding closest match
        euclidian_results = [unique_events, cell(length(unique_events), 1)];
        for event_i = 1:length(unique_events)
            event = unique_events{event_i};
            template_i = (event_info.event_indices(...
                strcmpi(event_info.event_labels, event) ...
                & logical(event_info.include_trials) ...
                & event_info.event_indices ~= trial));
            psth_template = calc_psth(rr_data(template_i, :));
            eucl_dist = sqrt(sum((psth_template - trial_template).^2));
            euclidian_results(event_i, end) = {eucl_dist};
        end

        %% Trial classification information
        [~, min_index] = min([euclidian_results{:, end}]);
        classified_event = euclidian_results{min_index, 1};
        predicted_events = [predicted_events; {classified_event}];
    end
    event_info = sortrows(event_info, "event_indices");
    true_events = event_info.event_labels;
    %% Find the information and performance for current chan_group
    confusion_matrix = confusionmat(true_events, predicted_events);
    mutual_info = I_confmatr(confusion_matrix);
    correct_trials = cellfun(@strcmp, true_events, predicted_events);
    performance = mean(correct_trials);
    correct_trials = table(true_events, predicted_events, correct_trials, ...
        'VariableNames', {'true', 'predicted', 'correct'});
end