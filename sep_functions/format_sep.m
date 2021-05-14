function data_map = format_sep(data_map, event_samples, ...
        sample_rate, window_start, window_end, square_pulse, include_events)

    unique_events = fieldnames(event_samples);
    for event_i = 1:length(unique_events)
        event = unique_events{event_i};

        %% Skip unwanted events
        if ~iscell(include_events) && ~isempty(include_events) && ~isnan(include_events)
            if ~ismember(event_i, include_events)
                continue
            end
        end

        if isempty(event_samples.(event))
            warning('Empty event matrix. Skipping %s', event);
            continue
        end

        %% Skip unwanted events
        if square_pulse
            event_ts = event_samples.(event)(1,:);
        end

        %% Create array of all trial samples based on event times
        trial_indices = arrayfun(@(x) ...
            (x + (window_start*sample_rate)):(x+(window_end*sample_rate)), ...
            event_ts, 'UniformOutput', false);
        trial_indices = horzcat(trial_indices{:});
        %% Slice SEPs
        data_map.channel_data = data_map.channel_data(:, trial_indices);
    end
end