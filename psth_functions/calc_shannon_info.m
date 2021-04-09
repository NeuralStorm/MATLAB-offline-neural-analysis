function [res] = calc_shannon_info(psth_struct, event_info, bin_size, window_start, ...
                                window_end, response_start, response_end)

    %% Create info table
    headers = [["region", "string"]; ["channel", "string"]; ["event", "string"]; ...
               ["entropy", "double"]; ["mutual_info", "double"]];
    res = prealloc_table(headers, [0, size(headers, 1)]);

    unique_regions = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    tot_events = numel(unique_events);
    [~, tot_bins] = get_bins(window_start, window_end, bin_size);

    for reg_i = 1:length(unique_regions)
        region = unique_regions{reg_i};
        chan_order = psth_struct.(region).label_order;
        tot_chans = numel(chan_order);
        %% Start channel counter
        chan_s = 1;
        chan_e = tot_bins;
        for chan_i = 1:tot_chans
            chan = psth_struct.(region).label_order{chan_i};
            %% Grab entire response for channel
            chan_rr = psth_struct.(region).relative_response(:, chan_s:chan_e);
            response_rr = slice_rr(chan_rr, bin_size, window_start, ...
                window_end, response_start, response_end);
            %% Find mutual information for response_rr
            mi = calc_event_mi(response_rr, event_info);
            for event_i = 1:tot_events
                %% Calculate event entropies
                event = unique_events{event_i};
                event_indices = event_info.event_indices(strcmpi(event_info.event_labels, event), :);
                chan_rr = psth_struct.(region).relative_response(event_indices, chan_s:chan_e);
                response_rr = slice_rr(chan_rr, bin_size, window_start, ...
                    window_end, response_start, response_end);

                %% Get response probabilities and calculate entropy
                [~, response_prob] = get_prob(response_rr);
                response_entropy = calc_entropy(response_prob);
                a = [{region}, {chan}, {event}, response_entropy, mi];
                %% Store results in table
                res = concat_cell(res, a, headers(:, 1));
            end
            %% Update channel counter
            chan_s = chan_s + tot_bins;
            chan_e = chan_e + tot_bins;
        end
    end
end

function [response, response_prob] = get_prob(rr)
    [response, ~, response_i] = unique(rr, 'rows');
    response_prob = tabulate(response_i);
    response_prob = response_prob(:, end) / 100;
    response_prob(response_prob == 0) = [];
end

function [res] = calc_entropy(response_prob)
    res = 0;
    for prob_i = 1:numel(response_prob)
        prob = response_prob(prob_i);
        res = res - prob * log2(prob);
    end
end

function [mi] = calc_event_mi(rr, event_info)
    tot_trials = height(event_info);
    assert(tot_trials == size(rr, 1), ...
        'Event info should have the same trials as the relative response');
    unique_events = unique(event_info.event_labels);
    mi = 0;
    [response_patterns, response_prob] = get_prob(rr);
    for event_i = 1:numel(unique_events)
        event = unique_events{event_i};
        event_indices = event_info.event_indices(strcmpi(event_info.event_labels, event), :);
        event_prob = numel(event_indices) / tot_trials;
        event_rr = rr(event_indices, :);
        [event_patterns, event_response_prob] = get_prob(event_rr);
        [~, a_i, b_i] = intersect(event_patterns, response_patterns, 'rows');
        mi = mi + event_prob * ...
            sum(event_response_prob(a_i) .* log2(event_response_prob(a_i) ./ response_prob(b_i)));
    end
end