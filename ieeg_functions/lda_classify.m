function [pop_table, results] = lda_classify(rr_data, event_info)
    tic

    %% Create population table
    pop_headers = [["chan_group", "string"]; ["tot_trials", "double"]; ...
                   ["tot_chans", "double"]; ["performance", "double"]; ["mutual_info", "double"]];
    pop_table = prealloc_table(pop_headers, [0, size(pop_headers, 1)]);

    %% grab label for all the trials
    labels = event_info.event_labels;

    results = struct;

    unique_ch_groups = fieldnames(rr_data);
    for ch_g_i = 1:numel(unique_ch_groups)
        %% Go through each ch_g space to do classification
        ch_g = unique_ch_groups{ch_g_i};
        chan_order = rr_data.(ch_g).chan_order;
        tot_chans = numel(chan_order);

        relative_response = rr_data.(ch_g).relative_response;

        [tot_trials, ~] = size(relative_response);
        predicted_events = cell(tot_trials, 1);
        true_events = cell(tot_trials, 1);
        parfor trial_i = 1:tot_trials
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

        results.(ch_g) = struct('confusion_matrix', conf, 'mutual_info', mutual_info, ...
                            'performance', perf, 'trial_log', trial_log);

        %% table update
        a = [{ch_g}, tot_trials, tot_chans, perf, mutual_info];
        pop_table = vertcat_cell(pop_table, a, pop_headers(:, 1), "after");
    end
    toc
end