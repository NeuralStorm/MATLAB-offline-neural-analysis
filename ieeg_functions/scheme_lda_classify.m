function [pop_table, results] = scheme_lda_classify(rr_data, event_info)
    tic

    % unique_ch_groups = fieldnames(rr_data);
    tot_trials = height(event_info);
    train_set = event_info(event_info.include_trials == 1, :);
    tot_train_trials = height(train_set);
    % tot_test_trials = height(event_info(~logical(event_info.include_trials), :));
    % [~, tot_bins] = get_bins(window_start, window_end, bin_size);

    %% Create population table
    pop_headers = [["scheme", "string"]; ["chan_group", "string"]; ["tot_trials", "double"]; ...
                   ["tot_train_trials", "double"]; ["tot_chans", "double"]; ...
                   ["performance", "double"]; ["mutual_info", "double"]];
    pop_table = prealloc_table(pop_headers, [0, size(pop_headers, 1)]);

    %% grab label for all the trials
    labels = train_set.event_labels;

    results = struct;

    unique_features = fieldnames(rr_data);
    for feature_i = 1:numel(unique_features)
        %% Go through each feature space to do classification
        feature = unique_features{feature_i};
        chan_order = rr_data.(feature).chan_order;
        tot_chans = numel(chan_order);

        relative_response = rr_data.(feature).relative_response;
        relative_response = relative_response(event_info.include_trials == 1, :);

        [tot_rr_trials, ~] = size(relative_response);
        assert(tot_train_trials == tot_rr_trials)
        predicted_events = cell(tot_train_trials, 1);
        true_events = cell(tot_train_trials, 1);
        parfor trial_i = 1:tot_train_trials
            %% Separation of test and train sets
            test_trial = relative_response(trial_i, :);
            train_response = relative_response;
            train_response(trial_i, :) = [];
            train_labels = labels;
            train_labels(trial_i) = [];

            %% Train model with data
            lin_model = fitcdiscr(train_response, train_labels);
            %% Predict label of left out trial
            classified_out = predict(lin_model, test_trial);

            predicted_events(trial_i) = classified_out;
            true_events(trial_i) = labels(trial_i);
        end
        %% Calculate classification metrics
        conf = confusionmat(true_events, predicted_events);
        correct_trials = cellfun(@strcmp, true_events, predicted_events);
        perf = mean(correct_trials);
        mutual_info = I_confmatr(conf);
        trial_log = table(true_events, predicted_events, correct_trials, ...
                    'VariableNames', {'true', 'predicted', 'correct'});

        results.(feature) = struct('confusion_matrix', conf, 'mutual_info', mutual_info, ...
                            'performance', perf, 'trial_log', trial_log);

        %% table update
        a = [{'non_mistake'}, {feature}, tot_trials, tot_train_trials, tot_chans, perf, mutual_info];
        pop_table = vertcat_cell(pop_table, a, pop_headers(:, 1), "after");
    end
    toc
end