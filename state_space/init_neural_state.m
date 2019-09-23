function [region_obs] = init_neural_state(psth_struct, event_ts, trial_range)

    %% Determine total number of trials across all events
    all_events = psth_struct.all_events;
    [tot_events, ~] = size(all_events);
    tot_event_trials = 0;
    for event_index = 1:tot_events
        tot_event_trials = tot_event_trials + length(all_events{event_index, 2});
    end

    %% Verify that event_ts and all events have same trials
    [tot_trials, ~] = size(event_ts);
    if tot_event_trials ~= tot_trials
        if tot_event_trials < tot_trials
            if ~isempty(trial_range)
                try
                    event_ts = event_ts(trial_range(1):trial_range(2), :);
                catch ME
                    warning(ME.identifier, '%s', ME.message);
                    warning('Animal does not have enough trials for the decided trial range. Truncating to the length of events it has.');
                    event_ts = event_ts(trial_range(1):length(event_ts), :);
                end
            end
        else
            error('More event trials present than in event timestamp array');
        end
    end
    assert(tot_trials == tot_event_trials);
    unique_regions = setdiff(fieldnames(psth_struct), 'all_events');

    event_list = [(1:1:length(event_ts(:,1)))', event_ts];
    event_list = num2cell(sortrows(event_list, 2));
    col_names = {'trial_number', 'event_label', 'event_ts', 'observations'};
    region_obs = struct;
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        region_response = psth_struct.(region).relative_response;
        %! zscore entire response across all trials? --> 0 mean for bins or trials?
        region_response = zscore(region_response, 0, 2);
        region_trials = [event_list, num2cell(region_response, 2)];
        region_table = cell2table(region_trials, 'VariableNames', col_names);
        region_obs.(region) = region_table;
    end
end