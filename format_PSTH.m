function [event_struct, event_ts, event_strings, labeled_neurons] = format_PSTH(...
        event_ts, labeled_neurons, bin_size, pre_time, post_time, wanted_events, trial_range)
    if pre_time > 0
        pre_time_bins = (length(-abs(pre_time): bin_size: 0)) - 1;
    else
        pre_time_bins = 0;
    end
    post_time_bins = (length(0:bin_size:post_time)) - 1;

    event_strings = {};
    if isempty(wanted_events)
        wanted_events = unique(event_ts(:,1));
    end
    wanted_events = sort(wanted_events);
    for i = 1: length(wanted_events)
        event_strings{end+1} = ['event_', num2str(wanted_events(i))];
    end
    event_struct = struct;

    % Truncates events to desired trial range from total_trials * total_events
    if ~isempty(trial_range)
        try
            event_ts = event_ts(trial_range(1):trial_range(2), :);
        catch ME
            warning(ME.identifier, '%s', ME.message);
            warning('Animal does not have enough trials for the decided trial range. Truncating to the length of events it has.');
            event_ts = event_ts(trial_range(1):length(event_ts), :);
        end
    end

    event_struct.all_events = {};
    for i = 1: length(wanted_events)
        %% Slices out the desired trials from the events matrix (Inclusive range)
        event_struct.all_events = [event_struct.all_events; event_strings{i}, {event_ts(event_ts == wanted_events(i), 2)}];
    end

    %% Creates the PSTH
    unique_regions = fieldnames(labeled_neurons);
    for region = 1:length(unique_regions)
        region_name = unique_regions{region};
        labeled_map = labeled_neurons.(region_name)(:,4);
        event_struct.(region_name).relative_response = create_relative_response(labeled_map, event_struct.all_events(:,2), ...
            bin_size, pre_time, post_time);
    end

    try
        events_array = event_struct.all_events(:,2);
        event_count = 0;
        for event = 1:length(events_array)
            current_event = event_strings{event};
            %% get normalized psth for regions
            for region = 1:length(unique_regions(:,1))
                region_name = unique_regions{region};
                event_relative_response = event_struct.(region_name).relative_response( ...
                    (event_count + 1): 1: (event_count + length(events_array{event})), :);
                current_psth = sum(event_relative_response, 1) ...
                    / length(events_array{event});
                % normalized psth is the normalized psth
                event_struct.(region_name).(current_event).psth = current_psth;
                [pre_time_activity, post_time_activity] = split_psth(current_psth, pre_time, pre_time_bins, post_time_bins);
                event_struct.(region_name).(current_event).norm_pre_time_activity = pre_time_activity;
                event_struct.(region_name).(current_event).norm_post_time_activity = post_time_activity;
                event_struct.(region_name).(current_event).relative_response = event_relative_response;
            end
            % Updates event_count to scale sum properly for next row
            event_count = event_count + length(events_array{event});
        end
    catch ME
        error_message = getReport( ME, 'extended', 'hyperlinks', 'on');
        warning(error_message);
        rethrow(ME)
    end
end

function [pre_time_activity, post_time_activity] = split_psth(psth, pre_time, pre_time_bins, post_time_bins)
    pre_time_activity = [];
    post_time_activity = [];
    %% Breaks down the PSTH into pre psth
    if pre_time ~= 0
        %% Creates pre time PSTH
        pre = pre_time_bins;
        while pre < length(psth)
            pre_time_activity = [pre_time_activity; psth((pre - pre_time_bins + 1 ): pre)];
            % Update counter
            pre = pre + post_time_bins + pre_time_bins;
        end
        %% Creates post time PSTH
        post = pre_time_bins + post_time_bins; 
        while post <= length(psth)
            post_time_activity = [post_time_activity; psth((post - post_time_bins + 1): post)];
            post = post + pre_time_bins + post_time_bins;
        end
    else
        warning('Since the pre time is set to 0, there will not be a psth generated with only the pre time activity.\n');
        pre_time_activity = NaN;
        post_time_activity = psth;
    end
end