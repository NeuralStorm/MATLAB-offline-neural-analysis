function [trajectory_struct, trajectory_labels] = gpfa_to_psth(gpfa_results, psth_struct, labeled_data)
    %TODO then update filtered events cell array to have proper counts
    unique_regions = fieldnames(gpfa_results);
    trajectory_struct = struct;
    %! need to fix altered event list
    trajectory_struct.all_events = psth_struct.all_events;
    trajectory_labels = labeled_data;
    all_events = [];
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        region_events = psth_struct.(region).filtered_events;
        unique_events = fieldnames(gpfa_results.(region));
        relative_response = [];
        for event_i = 1:length(unique_events)
            event = unique_events{event_i};
            event_seqTrain = gpfa_results.(region).(event).seqTrain;
            tot_event_trials = length(event_seqTrain);
            [tot_factors, tot_bins] = size(event_seqTrain(1).xsm);
            event_relative_response = zeros(tot_event_trials, (tot_bins * tot_factors));
            for trial = 1:tot_event_trials
                %TODO give flag for xsm or xorth
                event_relative_response(trial, :) = reshape(event_seqTrain(trial).xorth, [1, (tot_bins * tot_factors)]);
            end
            trajectory_struct.(region).(event).relative_response = event_relative_response;
            trajectory_struct.(region).(event).psth = sum(event_relative_response, 1) / tot_event_trials;
            relative_response = [relative_response; event_relative_response];

            %% Store individual factors
            factor_strings = [];
            for factor_i = 1:tot_factors
                factor_strings = [factor_strings; {['factor_', num2str(factor_i)]}];
            end
            %% Split columns in relative response
            bin_start = 1;
            bin_end = tot_bins;
            for factor_i = 1:tot_factors
                curr_factor = factor_strings{factor_i};
                factor_response = event_relative_response(:, bin_start:bin_end);
                trajectory_struct.(region).(event).(curr_factor).relative_response = factor_response;
                trajectory_struct.(region).(event).(curr_factor).psth = sum(factor_response, 1) / tot_event_trials;
                bin_start = bin_end + 1;
                bin_end = bin_end + tot_bins;
            end
            %% Create trajectory labeled struct
            if tot_factors > height(trajectory_labels.(region))
                tot_factors = height(trajectory_labels.(region));
                factor_strings = factor_strings(1:tot_factors, :);
            end
            trajectory_labels.(region) = trajectory_labels.(region)(1:tot_factors, :);
            trajectory_labels.(region).sig_channels = factor_strings;
            trajectory_labels.(region).user_channels = factor_strings;
            trajectory_labels.(region).channel_data = cell(tot_factors, 1);
        end

        [tot_trials, ~] = size(relative_response);
        trajectory_struct.(region).relative_response = relative_response;
        trajectory_struct.(region).psth = sum(relative_response, 1) / tot_trials;
    end
end