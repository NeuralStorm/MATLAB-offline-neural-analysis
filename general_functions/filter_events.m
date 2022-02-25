function [event_info] = filter_events(event_info, include_events, trial_range)
    %% Inputs
    % event_info: table with columns event_labels, event_indices, and event_ts
    % include_events: list of events desired to be analyzed.
    %                 Must be of same type as event_labels
    % trial range: numeric range of which trials to be analyzed
    %% Output
    % event_info filtered according to selected events and trial range

    %% Verify include_events is valid
    if iscell(include_events)
        include_events = include_events{:};
    end
    if ischar(include_events)
        include_events = strrep(include_events, ';', ',');
        include_events = strrep(include_events, ' ', ''); % remove any spaces
        include_events = strsplit(include_events, ',');
        event_info = event_info(ismember(event_info.event_labels, include_events), :);
    elseif isnumeric(include_events) && (~isempty(include_events) && ~all(isnan(include_events)))
        assert(strcmpi(class(event_info.event_labels), class(include_events)), ...
            'include_events must be %s, not %s', ...
            class(event_info.event_labels), class(include_events));
        event_info = event_info(ismember(event_info.event_labels, include_events), :);
    end

    %% Verify trial_range is valid
    if iscell(trial_range) && ~isempty(trial_range)
        if isnumeric(trial_range{1})
            trial_range = trial_range{:};
        else
            error('Expected numeric range, not %s for trial_range', class(trial_range));
        end
    end

    %% Select desired trial range
    if ~isempty(trial_range) && ~all(isnan(trial_range))
        event_info = event_info(ismember(event_info.event_indices, trial_range), :);
    end

    %% Update event indices
    %! Remove event_indices
    tot_trials = height(event_info);
    event_i = 1:1:tot_trials;
    event_info.event_indices = event_i';
end