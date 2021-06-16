function [channel_map] = create_channel_map(data_table, event_info, sample_rate, ...
        baseline_start, baseline_end, threshold_scalar)

    headers = [["channel", "cell"]; ["channel_data", "double"]];
    channel_map = prealloc_table(headers, [0, size(headers, 1)]);
    for chan_i = 1:height(data_table)
        chan = data_table.channel{chan_i};
        data = data_table.channel_data(:);
        [spikes, ~] = continuous_extract_spikes(data, threshold_scalar,...
            event_info.event_ts, sample_rate, baseline_start, baseline_end);
        a = [{chan}, spikes'];
        channel_map = vertcat_cell(channel_map, a, headers(:, 1), "after");
    end
end