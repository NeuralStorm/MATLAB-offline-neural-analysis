function [results] = lda_classify(psth_struct, event_info)
    true_list = event_info.event_labels;

    results = struct;
    relative_response = psth_struct.relative_response;

    [tot_trials, ~] = size(relative_response);
    predicted_list = cell(tot_trials, 1);
    for trial_i = 1:tot_trials
        %% Separation of test and train sets
        test_trial = relative_response(trial_i, :);
        train_response = relative_response;
        train_response(trial_i, :) = [];
        train_labels = true_list;
        train_labels(trial_i) = [];

        %% Train model with data
        lin_model = fitcdiscr(train_response, train_labels, 'SaveMemory', 'on');
        %% Predict label of left out trial
        classified_out = predict(lin_model, test_trial);
        predicted_list(trial_i) = classified_out;
    end
    confusion_matrix = confusionmat(true_list, predicted_list);
    correct_trials = cellfun(@strcmp, true_list, predicted_list);
    results.confusion_matrix = confusion_matrix;
    results.mutual_info = I_confmatr(confusion_matrix);
    results.correct_trials = correct_trials;
    results.performance = mean(correct_trials);
    results.correct_trials = table(true_list, predicted_list, correct_trials, ...
        'VariableNames', {'true', 'predicted', 'correct'});
end