function [res] = calc_shannon_info(rr_data, event_info, bin_size, window_start, ...
                                window_end, response_start, response_end)
    %% Abbreviations
    % *_t = timing, *_c = count

    %% Create info table
    headers = [["chan_group", "string"]; ["channel", "string"]; ...
               ["event", "string"]; ["entropy_time", "double"]; ...
               ["entropy_count", "double"]; ["mutual_info_time", "double"]; ...
               ["mutual_info_count", "double"]];
    res = prealloc_table(headers, [0, size(headers, 1)]);

    unique_ch_groups = fieldnames(rr_data);
    unique_events = unique(event_info.event_labels);
    tot_events = numel(unique_events);
    [~, tot_bins] = get_bins(window_start, window_end, bin_size);

    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        chan_order = rr_data.(ch_group).chan_order;
        tot_chans = numel(chan_order);
        %% Start channel counter
        chan_s = 1;
        chan_e = tot_bins;
        for chan_i = 1:tot_chans
            chan = rr_data.(ch_group).chan_order{chan_i};
            %% Grab entire response for channel
            chan_rr = rr_data.(ch_group).relative_response(:, chan_s:chan_e);
            response_rr = slice_rr(chan_rr, bin_size, window_start, ...
                window_end, response_start, response_end);
            %% Find timing mutual information for response_rr
            mi_t = calc_event_mi(response_rr, event_info);
            mi_c = calc_event_mi(sum(response_rr, 2), event_info);
            for event_i = 1:tot_events
                %% Calculate event entropies
                event = unique_events{event_i};
                event_indices = event_info.event_indices(strcmpi(event_info.event_labels, event), :);
                chan_rr = rr_data.(ch_group).relative_response(event_indices, chan_s:chan_e);
                response_rr = slice_rr(chan_rr, bin_size, window_start, ...
                    window_end, response_start, response_end);

                %% Get timing probabilities and calculate timing entropy
                [~, prob_t] = get_prob(response_rr);
                entropy_t = calc_entropy(prob_t);

                %% Get count probabilities and calculate count entropy
                [~, prob_c] = get_prob(sum(response_rr, 2));
                entropy_c = calc_entropy(prob_c);

                a = [{ch_group}, {chan}, {event}, entropy_t, entropy_c, mi_t, mi_c];
                %% Store results in table
                res = vertcat_cell(res, a, headers(:, 1), "after");
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