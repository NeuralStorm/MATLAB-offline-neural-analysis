function [pop_table, chan_table, classify_res] = do_psth_classifier(rr_data, event_info, bin_size, window_start, window_end, ...
        response_start, response_end)
    %% Create population table
    pop_headers = [["chan_group", "string"]; ["performance", "double"]; ...
                   ["mutual_info", "double"]];
    pop_table = prealloc_table(pop_headers, [0, size(pop_headers, 1)]);
    %% Create channel table
    chan_headers = [["chan_group", "string"]; ["channel", "string"]; ...
                    ["performance", "double"]; ["mutual_info", "double"]];
    chan_table = prealloc_table(chan_headers, [0, size(chan_headers, 1)]);
    %% Create struct to store all results from classifier
    classify_res = struct;

    unique_ch_groups = fieldnames(rr_data);
    unique_events = unique(event_info.event_labels);
    [~, tot_bins] = get_bins(response_start, response_end, bin_size);

    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        chan_order = rr_data.(ch_group).chan_order;
        tot_chans = numel(chan_order);

        event_struct = create_event_struct(rr_data.(ch_group), event_info, ...
            bin_size, window_start, window_end, response_start, response_end);

        %% Population classification
        [conf, mutual_info, trial_log, perf] = psth_classifier(event_struct, unique_events);
        %% Store classification results in table and struct
        a = [{ch_group}, perf, mutual_info];
        pop_table = vertcat_cell(pop_table, a, pop_headers(:, 1), "after");
        classify_res.(ch_group) = struct('confusion_matrix', conf, ...
            'mutual_info', mutual_info, 'performance', perf, 'trial_log', trial_log);

        %% chan classification
        chan_s = 1;
        chan_e = tot_bins;
        for chan_i = 1:tot_chans
            chan = chan_order{chan_i};
            %% slice channel from shuffled event struct
            chan_struct = slice_event_channels(event_struct, chan_s, chan_e);
            [conf, mutual_info, trial_log, perf] = psth_classifier(chan_struct, unique_events);
            %% Store classification results in table and struct
            a = [{ch_group}, {chan}, perf, mutual_info];
            chan_table = vertcat_cell(chan_table, a, chan_headers(:, 1), "after");
            classify_res.(ch_group).(chan) = struct('confusion_matrix', conf, ...
                'mutual_info', mutual_info, 'performance', perf, 'trial_log', trial_log);
            %% Update channel counter
            chan_s = chan_s + tot_bins;
            chan_e = chan_e + tot_bins;
        end
    end
end