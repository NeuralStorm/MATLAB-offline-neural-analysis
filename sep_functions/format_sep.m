function sliced_signals = format_sep(data_map, event_samples, ...
        sample_rate, sep_window, square_pulse, wanted_events)

    unique_events = fieldnames(event_samples);
    sliced_signals = struct([]);
    for event_i = 1:length(unique_events)
        event = unique_events{event_i};

        %% Skip unwanted events
        if ~iscell(wanted_events) && ~isempty(wanted_events) && ~isnan(wanted_events)
            if ~ismember(event_i, wanted_events)
                continue
            end
        end

        %% Skip unwanted events
        if square_pulse
            event_ts = event_samples.(event)(1,:);
        end

        window_start = abs(sep_window(1)) * sample_rate; 
        window_end = abs(sep_window(2)) * sample_rate; 

        sample_window_start = arrayfun(@(x) (x - window_start), event_ts);
        sample_window_end = arrayfun(@(x) (x + window_end), event_ts);
        sample_window = [sample_window_start; sample_window_end];

        event_map = data_map;
        for channel = 1:length(data_map)
            %% Initialize sep formatted data for event
            chan_signals = zeros(length(event_ts), (sample_window(2,1) ...
                - sample_window(1,1) + 1));
            %% Go through each trial and slice out sep
            for trial = 1:length(sample_window)
                chan_signals(trial,:) = data_map(channel).data( ...
                    sample_window(1, trial):sample_window(2, trial));
            end
            %% Replace data with sep data
            event_map(channel).data = chan_signals;
        end
        [event_map(:).event] = deal({event});

        %% Append event data to sliced signals
        sliced_signals = [sliced_signals; event_map];
    end
end