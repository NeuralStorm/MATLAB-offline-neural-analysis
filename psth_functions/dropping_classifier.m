function [res] = dropping_classifier(rr_data, event_info, drop_method, ...
        channel_info, bin_size, window_start, window_end, response_start, response_end)
    %% Create res table
    headers = [["chan_group", "string"]; ["tot_chans", "double"]; ["dropped_chan", "double"]; ...
               ["performance", "double"]; ["mutual_info", "double"]];
    res = prealloc_table(headers, [0, size(headers, 1)]);

    unique_ch_groups = fieldnames(rr_data);
    unique_events = unique(event_info.event_labels);
    [~, tot_bins] = get_bins(window_start, window_end, bin_size);

    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        chan_list = rr_data.(ch_group).chan_order;
        tot_chans = numel(chan_list);

        %% Population classification
        event_struct = create_event_struct(rr_data.(ch_group), event_info, ...
            bin_size, window_start, window_end, response_start, response_end);
        [~, mutual_info, ~, perf] = psth_classifier(event_struct, unique_events);
        %% Classification results with all channels
        a = [{ch_group}, tot_chans, {"none"}, perf, mutual_info];
        res = vertcat_cell(res, a, headers(:, 1), "after");
        %% Get drop order for chan_group
        reg_info = channel_info(strcmpi(channel_info.chan_group, ch_group), :);
        chan_order = get_chan_order(chan_list, drop_method, reg_info);
        while tot_chans > 1
            chan = chan_order{1};
            chan_i = find(ismember(rr_data.(ch_group).chan_order, chan));
            %% Get channel relative response
            chan_e = chan_i * tot_bins;
            chan_s = chan_e - tot_bins + 1;

            %% Drop channel
            rr_data.(ch_group).relative_response(:, chan_s:chan_e) = [];

            %% Build up event struct and classify
            event_struct = create_event_struct(rr_data.(ch_group), event_info, ...
                bin_size, window_start, window_end, response_start, response_end);
            [~, mutual_info, ~, perf] = psth_classifier(event_struct, unique_events);

            %% Update channel order
            chan_order(1) = [];
            rr_data.(ch_group).chan_order = chan_order;
            tot_chans = numel(chan_order);

            %% Store results
            a = [{ch_group}, tot_chans, {chan}, perf, mutual_info];
            res = vertcat_cell(res, a, headers(:, 1), "after");
        end
    end
end

function [chan_order] = get_chan_order(chan_list, drop_method, chan_table)
    if strcmpi(drop_method, 'random')
        %% CASE: Random order
        chan_order = chan_list(randperm(numel(chan_list)));
        return
    end
    assert(istable(chan_table) && height(chan_table) == numel(chan_list));
    if strcmpi(drop_method, 'percent_var')
        %% CASE: Drop channels by max % variance
        sorted_chans = sortrows(chan_table, "variance", 'descend');
        chan_order = sorted_chans.channel;
    elseif any(ismember(chan_table.Properties.VariableNames, drop_method))
        %% CASE: use previous classifier results to sort
        sorted_chans = sortrows(chan_table, drop_method, 'descend');
        chan_order = sorted_chans.channel;
    else
        error('Unrecognized drop method %s', drop_method);
    end
end