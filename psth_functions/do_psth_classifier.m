function [pop_table, chan_table] = do_psth_classifier(psth_struct, event_info, bin_size, window_start, window_end, ...
    response_start, response_end)

    %TODO also return structs with confusion matrix
    pop_headers = [["label", "string"]; ["performance", "double"]; ...
                   ["mutual_info", "double"]];
    chan_headers = [["label", "string"]; ["channels", "string"]; ...
                    ["performance", "double"]; ["mutual_info", "double"]];

    unique_regions = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    [~, tot_bins] = get_bins(response_start, response_end, bin_size);

    [pop_table, chan_table] = create_table();

    for reg_i = 1:length(unique_regions)
        region = unique_regions{reg_i};
        chan_order = psth_struct.(region).label_order;
        tot_chans = numel(chan_order);

        event_struct = create_event_struct(psth_struct.(region), event_info, ...
            bin_size, window_start, window_end, response_start, response_end);

        %% Unit classification
        chan_s = 1;
        chan_e = tot_bins;
        for chan_i = 1:tot_chans
            chan = chan_order{chan_i};
            %% slice channel from shuffled event struct
            chan_struct = slice_event_channels(event_struct, chan_s, chan_e);
            [~, mutual_info, ~, perf] = psth_classifier(chan_struct, unique_events);
            %% Add channel classifier info to chan table
            a = [{region}, {chan}, perf, mutual_info];
            chan_table = concat_cell(chan_table, a, chan_headers(:, 1));
            %% Update channel counter
            chan_s = chan_s + tot_bins;
            chan_e = chan_e + tot_bins;
        end

        %% Population classification
        [~, mutual_info, ~, perf] = psth_classifier(event_struct, unique_events);

        %% Add region classifier to pop table
        a = [{region}, perf, mutual_info];
        pop_table = concat_cell(pop_table, a, pop_headers(:, 1));

    end
end

function [pop_table, chan_table] = create_table()
    %% Create population table
    pop_headers = [["label", "string"]; ["performance", "double"]; ...
                   ["mutual_info", "double"]];
    pop_table = table('Size',[0, 3], ...
        'VariableNames', pop_headers(:, 1), ...
        'VariableTypes', pop_headers(:, 2));
    %% Create channel table
    chan_headers = [["label", "string"]; ["channels", "string"]; ...
                    ["performance", "double"]; ["mutual_info", "double"]];
    chan_table = table('Size',[0, 4], ...
        'VariableNames', chan_headers(:, 1), ...
        'VariableTypes', chan_headers(:, 2));
end