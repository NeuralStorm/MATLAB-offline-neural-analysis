function [pca_struct, pca_results, event_ts, event_struct, labeled_pcs] = calc_pca(labeled_neurons, event_ts,  ...
    bin_size, pre_time, post_time, wanted_events, trial_range, trial_lower_bound)

    event_window = -(abs(pre_time)):bin_size:(abs(post_time));
    tot_bins = length(event_window) - 1;
    pca_results = struct;
    event_struct = struct;
    labeled_pcs = labeled_neurons;

    %% Format neuron and event timestamps into pca format
    % see Laubach et al. 1999
    [pca_struct, all_events, event_ts] = create_pca_input(labeled_neurons, event_ts,  ...
        event_window, wanted_events, trial_range, trial_lower_bound);
    [tot_trials, ~] = size(event_ts);
    event_struct.all_events = all_events;

    unique_regions = fieldnames(labeled_neurons);
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        pca_input = pca_struct.(region).z_region_pca_input;
        [~, pca_score, eigenvalues, ~, pc_variance, ~] = pca(pca_input);
        pca_results.(region).pc_variance = pc_variance;
        pca_results.(region).eigenvalues = eigenvalues;
        pca_results.(region).pca_score = pca_score;

        %TODO figure out how to handle selection of PCs
        %TODO set threshold percentage that pcs must explain?
        [~, tot_pcs] = size(pca_score);

        pca_relative_response = nan(tot_trials, tot_pcs);
        pc_names = cell(tot_pcs, 1);
        for pc_index = 1:tot_pcs
            pc_start = (tot_bins * pc_index - tot_bins + 1);
            pc_end = tot_bins * pc_index;
            for trial = 1:tot_trials
                start_index = (tot_bins * trial - tot_bins + 1);
                end_index = tot_bins * trial;
                pca_relative_response(trial, pc_start:pc_end) = pca_score(start_index:end_index, pc_index);
            end
            pc_names{pc_index} = ['pc_', num2str(pc_index)];
        end
        labeled_pcs.(region)(:, 1) = pc_names;
        event_struct.(region).relative_response = pca_relative_response;
        event_struct.(region).psth = sum(pca_relative_response, 1) / tot_trials;

        %% Split pca relative response into events
        event_start = 1;
        event_end = length(all_events{1, 2});
        for event_index = 1:length(all_events(:, 1))
            event = all_events{event_index, 1};
            tot_event_trials = length(all_events{event_index, 2});
            event_relative_response = pca_relative_response(event_start:event_end, :);
            event_struct.(region).(event).relative_response = event_relative_response;
            event_struct.(region).(event).psth = sum(event_relative_response, 1) / tot_event_trials;
            event_start = event_end + 1;
            event_end = event_end + tot_event_trials;
        end

        %% Recreate labeled_neurons to contain the transformed information
    end
end