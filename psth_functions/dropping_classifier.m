function [res] = dropping_classifier(psth_struct, event_info, drop_method, ...
        channel_info, bin_size, window_start, window_end, response_start, response_end)
    %% Create res table
    headers = [["region", "string"]; ["tot_chans", "double"]; ["dropped_chan", "double"]; ...
               ["performance", "double"]; ["mutual_info", "double"]];
    res = prealloc_table(headers, [0, size(headers, 1)]);
    classify_res = struct;

    unique_regions = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    [~, tot_bins] = get_bins(window_start, window_end, bin_size);

    for reg_i = 1:length(unique_regions)
        region = unique_regions{reg_i};
        chan_list = psth_struct.(region).label_order;
        tot_chans = numel(chan_list);

        %% Population classification
        event_struct = create_event_struct(psth_struct.(region), event_info, ...
            bin_size, window_start, window_end, response_start, response_end);
        [~, mutual_info, ~, perf] = psth_classifier(event_struct, unique_events);
        %% Classification results with all channels
        a = [{region}, tot_chans, {"none"}, perf, mutual_info];
        res = concat_cell(res, a, headers(:, 1));
        %% Get drop order for region
        %! clean up
        if istable(channel_info)
            reg_info = channel_info(strcmpi(channel_info.region, region), :);
        elseif isstruct(channel_info)
            reg_info = channel_info.(region);
        elseif all(isnan(channel_info))
            reg_info = channel_info;
        else
            error('Unrecognized channel info type');
        end
        chan_order = get_chan_order(chan_list, drop_method, reg_info);
        while tot_chans > 1
            chan = chan_order{1};
            chan_i = find(ismember(psth_struct.(region).label_order, chan));
            %% Get channel relative response
            chan_e = chan_i * tot_bins;
            chan_s = chan_e - tot_bins + 1;

            %% Drop channel
            psth_struct.(region).relative_response(:, chan_s:chan_e) = [];

            %% Build up event struct and classify
            event_struct = create_event_struct(psth_struct.(region), event_info, ...
                bin_size, window_start, window_end, response_start, response_end);
            [~, mutual_info, ~, perf] = psth_classifier(event_struct, unique_events);
            a = [{region}, tot_chans, {chan}, perf, mutual_info];
            res = concat_cell(res, a, headers(:, 1));

            %% Update channel order
            chan_order(1) = [];
            psth_struct.(region).label_order = chan_order;
            tot_chans = numel(chan_order);
        end
    end
end

function [chan_order] = get_chan_order(chan_list, drop_method, values)

    if strcmpi(drop_method, 'random')
        %% CASE: Random order
        chan_order = chan_list(randperm(numel(chan_list)));
    elseif strcmpi(drop_method, 'percent_var')
        %% CASE: Drop channels by max % variance
        %! does not apply to ICA unless components are sorted by variance
        chan_order = chan_list;
    else
        %% CASE: use previous classifier results to sort
        assert(istable(values) && height(values) == numel(chan_list));
        sorted_chans = sortrows(values, drop_method, 'descend');
        chan_order = sorted_chans.channel;
        %! assert that all channels in chan_list exist only once in table
    end

end