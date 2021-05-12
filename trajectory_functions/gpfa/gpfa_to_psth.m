function [trajectory_struct] = gpfa_to_psth(gpfa_results, event_info)
    %TODO add in chan_group_log and update with factor names similar to PCA/ICA
    unique_ch_groups = fieldnames(gpfa_results);
    unique_events = unique(event_info.event_labels);
    trajectory_struct = struct;
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        relative_response = [];
        for event_i = 1:length(unique_events)
            event = unique_events{event_i};
            event_seqTrain = gpfa_results.(ch_group).(event).seqTrain;
            tot_event_trials = length(event_seqTrain);
            [tot_factors, tot_bins] = size(event_seqTrain(1).xsm);
            event_relative_response = zeros(tot_event_trials, (tot_bins * tot_factors));
            for trial = 1:tot_event_trials
                %TODO give flag for xsm or xorth
                event_relative_response(trial, :) = reshape(event_seqTrain(trial).xorth, [1, (tot_bins * tot_factors)]);
            end
            relative_response = [relative_response; event_relative_response];
        end
        trajectory_struct.(ch_group).relative_response = relative_response;
    end
end