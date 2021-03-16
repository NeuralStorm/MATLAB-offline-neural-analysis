function [pop_table, chan_table, classify_res] = do_psth_classifier(psth_struct, event_info, bin_size, window_start, window_end, ...
        response_start, response_end)
    %% Create population table
    pop_headers = [["region", "string"]; ["performance", "double"]; ...
                   ["mutual_info", "double"]];
    pop_table = prealloc_table(pop_headers, [0, size(pop_headers, 1)]);
    %% Create channel table
    chan_headers = [["region", "string"]; ["channel", "string"]; ...
                    ["performance", "double"]; ["mutual_info", "double"]];
    chan_table = prealloc_table(chan_headers, [0, size(chan_headers, 1)]);
    %% Create struct to store all results from classifier
    classify_res = struct;

    unique_regions = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    [~, tot_bins] = get_bins(response_start, response_end, bin_size);

    for reg_i = 1:length(unique_regions)
        region = unique_regions{reg_i};
        chan_order = psth_struct.(region).label_order;
        tot_chans = numel(chan_order);

        event_struct = create_event_struct(psth_struct.(region), event_info, ...
            bin_size, window_start, window_end, response_start, response_end);

        %% Population classification
        [conf, mutual_info, trial_log, perf] = psth_classifier(event_struct, unique_events);
        %% Store classification results in table and struct
        a = [{region}, perf, mutual_info];
        pop_table = concat_cell(pop_table, a, pop_headers(:, 1));
        classify_res.(region) = struct('confusion_matrix', conf, ...
            'mutual_info', mutual_info, 'performance', perf, 'trial_log', trial_log);

        %% Unit classification
        chan_s = 1;
        chan_e = tot_bins;
        for chan_i = 1:tot_chans
            chan = chan_order{chan_i};
            %% slice channel from shuffled event struct
            chan_struct = slice_event_channels(event_struct, chan_s, chan_e);
            [conf, mutual_info, trial_log, perf] = psth_classifier(chan_struct, unique_events);
            %% Store classification results in table and struct
            a = [{region}, {chan}, perf, mutual_info];
            chan_table = concat_cell(chan_table, a, chan_headers(:, 1));
            classify_res.(region).(chan) = struct('confusion_matrix', conf, ...
                'mutual_info', mutual_info, 'performance', perf, 'trial_log', trial_log);
            %% Update channel counter
            chan_s = chan_s + tot_bins;
            chan_e = chan_e + tot_bins;
        end
    end
end