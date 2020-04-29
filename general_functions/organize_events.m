function [event_strings, all_events, event_ts] = organize_events(event_ts, ...
        trial_lower_bound, trial_range, wanted_events)

    if iscell(trial_range)
        trial_range = trial_range{:};
    end
    if iscell(wanted_events)
        wanted_events = wanted_events{:};
    end
    %% Double checks that event timestamps taken from parser is abve the threshold
    event_count_table = tabulate(event_ts(:,1));
    for event = 1:length(event_count_table(:,1))
        event_num = event_count_table(event, 1);
        event_count = event_count_table(event, 2);
        if event_count < trial_lower_bound
            event_ts(event_ts(:,1) == event_num, :) = [];
        end
    end

    % Truncates events to desired trial range
    if ~isempty(trial_range) && ~all(isnan(trial_range))
        try
            event_ts = event_ts(trial_range, :);
        catch ME
            warning(ME.identifier, '%s', ME.message);
            warning('Animal does not have enough trials for the decided trial range. Truncating to the length of events it has.');
            event_ts = event_ts(trial_range(1):length(event_ts), :);
        end
    end

    if isempty(wanted_events) || all(isnan(wanted_events))
        wanted_events = unique(event_ts(:,1));
    end
    wanted_events = sort(wanted_events);

    event_strings = {};
    for i = 1: length(wanted_events)
        event_strings{end+1} = ['event_', num2str(wanted_events(i))];
    end

    all_events = {};
    remove_events = [];
    for event = 1:length(event_strings)
        %% Slices out the desired trials from the events matrix (Inclusive range)
        event_trials = event_ts(event_ts(:, 1) == wanted_events(event), 2);
        if isempty(event_trials)
            remove_events = [remove_events, event];
            warning('No trials for %s', event_strings{event});
            continue;
        else
            all_events = [all_events; event_strings{event}, {event_trials}];
        end
    end
    event_strings(remove_events) = [];
end