function [pop_table, chan_table, classify_res] = do_psth_classifier_template(rr_data, ...
        event_info, bin_size, window_start, window_end, response_start, response_end)
    %% Create population table
    pop_headers = [["scheme", "string"]; ["chan_group", "string"]; ["tot_trials", "double"]; ...
                   ["tot_train_trials", "double"]; ["tot_test_trials", "double"]; ["tot_chans", "double"]; ...
                   ["performance", "double"]; ["mutual_info", "double"]];
    pop_table = prealloc_table(pop_headers, [0, size(pop_headers, 1)]);
    %% Create channel table
    chan_headers = [["scheme", "string"]; ["chan_group", "string"]; ["channel", "string"]; ...
                    ["tot_trials", "double"]; ["tot_train_trials", "double"]; ["tot_test_trials", "double"]; ...
                    ["performance", "double"]; ["mutual_info", "double"]];
    chan_table = prealloc_table(chan_headers, [0, size(chan_headers, 1)]);
    %% Create struct to store all results from classifier
    classify_res = struct;

    unique_ch_groups = fieldnames(rr_data);
    tot_trials = height(event_info);
    tot_train_trials = height(event_info(logical(event_info.include_trials), :));
    tot_test_trials = height(event_info(~logical(event_info.include_trials), :));
    [~, tot_bins] = get_bins(response_start, response_end, bin_size);

    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        chan_order = rr_data.(ch_group).chan_order;
        tot_chans = numel(chan_order);
        ch_group_rr = rr_data.(ch_group).relative_response;
        ch_group_rr = slice_rr(ch_group_rr, bin_size, window_start, ...
            window_end, response_start, response_end);

        %% Population classification
        % [conf, mutual_info, trial_log, perf] = psth_classifier_templates(ch_group_rr, event_info);
        % %% Store classification results in table and struct
        % a = [{ch_group}, tot_trials, tot_selected_trials, tot_chans, perf, mutual_info];
        % pop_table = vertcat_cell(pop_table, a, pop_headers(:, 1), "after");
        % classify_res.(ch_group) = struct('confusion_matrix', conf, ...
        %     'mutual_info', mutual_info, 'performance', perf, 'trial_log', trial_log);

        %% Population classification: Template only
        [conf, mutual_info, trial_log, perf] = psth_classifier_templates(ch_group_rr, event_info, 'template');
        %% Store classification results in table and struct
        a = [{'template'}, {ch_group}, tot_trials, tot_train_trials, tot_train_trials, tot_chans, perf, mutual_info];
        pop_table = vertcat_cell(pop_table, a, pop_headers(:, 1), "after");
        classify_res.(['template_', ch_group]) = struct('confusion_matrix', conf, ...
            'mutual_info', mutual_info, 'performance', perf, 'trial_log', trial_log);

        %% Population classification: Non-template only
        [conf, mutual_info, trial_log, perf] = psth_classifier_templates(ch_group_rr, event_info, 'non_template');
        %% Store classification results in table and struct
        a = [{'non_template'}, {ch_group}, tot_trials, tot_train_trials, tot_test_trials, tot_chans, perf, mutual_info];
        pop_table = vertcat_cell(pop_table, a, pop_headers(:, 1), "after");
        classify_res.(['non_template_', ch_group]) = struct('confusion_matrix', conf, ...
            'mutual_info', mutual_info, 'performance', perf, 'trial_log', trial_log);

        %% chan classification
        chan_s = 1;
        chan_e = tot_bins;
        for chan_i = 1:tot_chans
            chan = chan_order{chan_i};
            %% slice channel from shuffled event struct
            chan_rr = rr_data.(ch_group).relative_response(:, chan_s:chan_e);
            chan_rr = slice_rr(chan_rr, bin_size, window_start, ...
                window_end, response_start, response_end);
            %% Channel Classification
            % [conf, mutual_info, trial_log, perf] = psth_classifier_templates(chan_rr, event_info);
            % %% Store classification results in table and struct
            % a = [{ch_group}, {chan}, tot_trials, tot_selected_trials, perf, mutual_info];
            % chan_table = vertcat_cell(chan_table, a, chan_headers(:, 1), "after");
            % classify_res.(ch_group).(chan) = struct('confusion_matrix', conf, ...
            %     'mutual_info', mutual_info, 'performance', perf, 'trial_log', trial_log);

            %% Channel Classification: Template only
            [conf, mutual_info, trial_log, perf] = psth_classifier_templates(chan_rr, event_info, 'template');
            %% Store classification results in table and struct
            a = [{'template'}, {ch_group}, {chan}, tot_trials, tot_train_trials, tot_train_trials, perf, mutual_info];
            chan_table = vertcat_cell(chan_table, a, chan_headers(:, 1), "after");
            classify_res.(ch_group).(['template_', chan]) = struct('confusion_matrix', conf, ...
                'mutual_info', mutual_info, 'performance', perf, 'trial_log', trial_log);

            %% Channel Classification: Non-template only
            [conf, mutual_info, trial_log, perf] = psth_classifier_templates(chan_rr, event_info, 'non_template');
            %% Store classification results in table and struct
            a = [{'non_template'}, {ch_group}, {chan}, tot_trials, tot_train_trials, tot_test_trials, perf, mutual_info];
            chan_table = vertcat_cell(chan_table, a, chan_headers(:, 1), "after");
            classify_res.(ch_group).(['non_template_', chan]) = struct('confusion_matrix', conf, ...
                'mutual_info', mutual_info, 'performance', perf, 'trial_log', trial_log);
            %% Update channel counter
            chan_s = chan_s + tot_bins;
            chan_e = chan_e + tot_bins;
        end
    end
end