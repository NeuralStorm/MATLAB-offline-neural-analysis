function [results] = lda_classify(psth_struct, label_log)
    tic
    %TODO time window?
    % -1 -> 0 | -2 -> 0 | -0.5 -> 0
    %TODO try a few dims

    %% Create labels used to train LDA model
    all_i = find(ismember(psth_struct.all_events(:, 1), 'all'));
    safe_i = find(ismember(psth_struct.all_events(:, 1), 'safebet'));
    gamble_i = find(ismember(psth_struct.all_events(:, 1), 'gambles'));
    labels = cell(numel(psth_struct.all_events{all_i, 2}), 1);
    labels(psth_struct.all_events{safe_i, 2}) = {'safebet'};
    labels(psth_struct.all_events{gamble_i, 2}) = {'gambles'};

    results = struct;

    relative_response = [];
    unique_features = fieldnames(label_log);
    for feature_i = 1:numel(unique_features)
        %% Go through each feature space to do classification
        feature = unique_features{feature_i};
        %TODO generalize events
        curr_response = psth_struct.(feature).all.relative_response;
        %% Grab first component
        %TODO give parameter to control # of componenets
        relative_response = [relative_response, curr_response];
    end

    % clear('psth_struct', 'label_log', 'pc_log');
    [tot_trials, ~] = size(relative_response);
    predicted_events = cell(tot_trials, 1);
    true_events = cell(tot_trials, 1);
    for trial_i = 1:tot_trials
        %% Separation of test and train sets
        test_trial = relative_response(trial_i, :);
        train_response = relative_response;
        train_response(trial_i, :) = [];
        train_labels = labels;
        train_labels(trial_i) = [];

        %% Train model with data
        lin_model = fitcdiscr(train_response, train_labels, 'SaveMemory', 'on');
        %% Predict label of left out trial
        classified_out = predict(lin_model, test_trial);

        predicted_events(trial_i) = classified_out;
        true_events(trial_i) = labels(trial_i);
    end
    confusion_matrix = confusionmat(true_events, predicted_events);
    correct_trials = cellfun(@strcmp, true_events, predicted_events);
    results.confusion_matrix = confusion_matrix;
    results.mutual_info = I_confmatr(confusion_matrix);
    results.correct_trials = correct_trials;
    results.performance = mean(correct_trials);
    results.correct_trials = table(true_events, predicted_events, correct_trials, ...
        'VariableNames', {'true', 'predicted', 'correct'});
    toc
end