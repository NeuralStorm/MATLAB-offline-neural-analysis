function [event_struct, event_ts, event_strings] = format_PSTH(...
        event_ts, labeled_neurons, bin_size, pre_time, post_time, wanted_events, trial_range, trial_lower_bound)
    if pre_time > 0
        pre_time_bins = (length(-abs(pre_time): bin_size: 0)) - 1;
    else
        pre_time_bins = 0;
    end
    post_time_bins = (length(0:bin_size:post_time)) - 1;

    event_struct = struct;

    %% Double checks that event timestamps taken from parser is abve the threshold
    event_count_table = tabulate(event_ts(:,1));
    for event = 1:length(event_count_table(:,1))
        event_num = event_count_table(event, 1);
        event_count = event_count_table(event, 2);
        if event_count < trial_lower_bound
            % current_prob_timing(current_prob_timing == 0) = [];
            event_ts(event_ts(:,1) == event_num, :) = [];
        end
    end

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

    if isempty(wanted_events)
        wanted_events = unique(event_ts(:,1));
    end
    wanted_events = sort(wanted_events);

    event_strings = {};
    for i = 1: length(wanted_events)
        event_strings{end+1} = ['event_', num2str(wanted_events(i))];
    end

    event_struct.all_events = {};
    for event = 1: length(event_strings)
        %% Slices out the desired trials from the events matrix (Inclusive range)
        event_struct.all_events = [event_struct.all_events; event_strings{event}, {event_ts(event_ts == wanted_events(event), 2)}];
        if isempty(event_struct.all_events{event, 2})
            %% Remove empty events
            event_struct.all_events(event, :) = [];
            event_strings(event) = [];
        end
    end

    %% Creates the PSTH
    unique_regions = fieldnames(labeled_neurons);
    for region = 1:length(unique_regions)
        region_name = unique_regions{region};
        region_neurons = [labeled_neurons.(region_name)(:,1), labeled_neurons.(region_name)(:,4)];
        region_response = create_relative_response(region_neurons, event_struct.all_events, ...
            bin_size, pre_time, post_time);

        for event = 1:length(event_strings)
            current_event = event_strings{event};
            current_psth = region_response.(current_event).psth;
            [pre_time_activity, post_time_activity] = split_psth(current_psth, pre_time, pre_time_bins, post_time_bins);
            region_response.(current_event).norm_pre_time_activity = pre_time_activity;
            region_response.(current_event).norm_post_time_activity = post_time_activity;
        end
        event_struct.(region_name) = region_response;
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
        pre_time_activity = NaN;
        post_time_activity = psth;
    end
end