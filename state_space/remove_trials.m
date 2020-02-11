function [psth_struct, state_struct] = remove_trials(state_table, psth_struct, labeled_data)
    % event_list and trial_list are transposed to agree with for loop syntax
    event_list = unique(state_table.event_label)';
    state_struct = struct;
    tot_bins = length(state_table.trial_number(state_table.trial_number == 1));
    event_strings = psth_struct.all_events(:, 1);
    struct_names = fieldnames(psth_struct);
    meta_info = {'all_events'};
    unique_regions = setdiff(struct_names, meta_info);

    %TODO verify that this doesnt have to be symmetrical
    %TODO generalize & do not hard code threshold scalar
    bad_rh_trials = unique(state_table.trial_number(state_table.rh_F < (mean(state_table.rh_F) - 3 * std(state_table.rh_F))));
    bad_lh_trials = unique(state_table.trial_number(state_table.lh_F < (mean(state_table.lh_F) - 3 * std(state_table.lh_F))));
    bad_fl_trials = unique(state_table.trial_number(state_table.fl_F < (mean(state_table.fl_F) - 3 * std(state_table.fl_F))));
    bad_trials = unique([bad_rh_trials; bad_lh_trials; bad_fl_trials]);
    trial_nums = unique(state_table.trial_number);
    trial_nums = setdiff(trial_nums, bad_trials);
    state_table(ismember(state_table.trial_number, bad_trials), :) = [];

    all_events = [];
    for event_i = 1:length(event_list)
        event_num = event_list(event_i);
        curr_event = ['event_', num2str(event_num)];
        all_events = [all_events; curr_event, ...
            {unique(state_table.event_ts(ismember(state_table.trial_number(state_table.event_label == event_num), trial_nums), :))}];
    end
    psth_struct.all_events = all_events;
    %% Remove incorrect trials
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};

        %% remove trials where forces are unexpected
        relative_response = psth_struct.(region).relative_response;
        relative_response(bad_trials, :) = [];
        event_struct = split_relative_response(relative_response, labeled_data.(region).sig_channels, all_events, tot_bins);

        %% Store results
        psth_struct.(region) = event_struct;
        psth_struct.(region).relative_response = relative_response;
        psth_struct.(region).psth = sum(relative_response) / length(trial_nums);

        [~, ~, ~, ~, correct_trials, ~] = psth_classifier(psth_struct.(region), event_strings');
        correct_trial_nums = trial_nums(correct_trials.correct, :);
        incorrect_trials = ~correct_trials.correct;
        %% Update forces and neural to contain correctly classified trials only
        state_struct.(region) = state_table(ismember(state_table.trial_number, correct_trial_nums), :);
        % updating all_events
        event_all_events = [];
        for event_i = 1:length(event_list)
            event_num = event_list(event_i);
            curr_event = ['event_', num2str(event_num)];
            event_all_events = [event_all_events; curr_event, ...
                {unique(state_struct.(region).event_ts(state_struct.(region).event_label == event_num))}];
        end

        relative_response = psth_struct.(region).relative_response;
        relative_response(incorrect_trials, :) = [];
        event_struct = split_relative_response(relative_response, labeled_data.(region).sig_channels, event_all_events, tot_bins);
        %% Store results
        psth_struct.(region) = event_struct;
        psth_struct.(region).relative_response = relative_response;
        psth_struct.(region).psth = sum(relative_response) / length(trial_nums);
        psth_struct.(region).filtered_events = event_all_events;
        psth_struct.(region).correct_trials = correct_trials;
    end
end