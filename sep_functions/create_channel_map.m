function [channel_map] = create_channel_map(data_table, event_info, sample_rate, ...
    baseline_start, baseline_end, threshold_scalar)

    headers = [["channel", "cell"]; ["channel_data", "cell"]];
    channel_map = prealloc_table(headers, [height(data_table), size(headers, 1)]);
    for chan_i = 1:height(data_table)
        chan = data_table.channel{chan_i};
        data = data_table.channel_data(chan_i, :);
        assert(size(data, 1) == 1, 'Findpeaks requires vector, not matrix');
        [spikes, ~] = continuous_extract_spikes(data, threshold_scalar,...
            event_info.event_ts, sample_rate, baseline_start, baseline_end);
        a = [{chan}, spikes'];
        a = cell2table(a, 'VariableNames', headers(:,1));
        channel_map(chan_i, :) = a;
    end
end