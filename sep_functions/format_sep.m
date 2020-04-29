function sliced_signals = format_sep(data_map, event_samples, ...
        sample_rate, sep_window)

    event_samples = event_samples(1, :);

    window_start = abs(sep_window(1)) * sample_rate; 
    window_end = abs(sep_window(2)) * sample_rate; 

    sample_window_start = arrayfun(@(x) (x - window_start), event_samples);
    sample_window_end = arrayfun(@(x) (x + window_end), event_samples); 
    sample_window = [sample_window_start; sample_window_end]; 

    for channel = 1:length(data_map)
        chan_signals = zeros(length(event_samples), (sample_window(2,1) ...
            - sample_window(1,1) + 1));
        for event = 1:length(sample_window)
            chan_signals(event,:) = data_map(channel).data( ...
                sample_window(1, event):sample_window(2, event));
        end
        data_map(channel).data = chan_signals;
    end
    sliced_signals = data_map;
end