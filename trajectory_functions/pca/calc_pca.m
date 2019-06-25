function [pca_struct, pca_results, event_ts, event_struct, labeled_pcs] = calc_pca(labeled_neurons, event_ts,  ...
    bin_size, pre_time, post_time, wanted_events, trial_range, trial_lower_bound, feature_filter, feature_value)

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
        [coeff, pca_score, eigenvalues, ~, pc_variance, estimated_mean] = pca(pca_input);
        pca_results.(region).pc_variance = pc_variance;
        pca_results.(region).eigenvalues = eigenvalues;
        pca_results.(region).coeff = coeff;
        pca_results.(region).estimated_mean = estimated_mean;

        [~, tot_pcs] = size(pca_score);
        if strcmpi(feature_filter, 'pcs')
            if feature_value > tot_pcs
                warning('Not enough features available to truncate down to')
                pca_results.(region).old_pca_score = pca_score;
            else
                tot_pcs = feature_value;
                pca_results.(region).old_pca_score = pca_score;
                pca_score = pca_score(:, 1:tot_pcs);
                labeled_pcs.(region) = labeled_pcs.(region)(1:tot_pcs, :);
            end
        elseif strcmpi(feature_filter, 'eigen')
            %TODO check eigenvalues and recreate pca scores with new weights
            % subthreshold_i = find(eigenvalues < feature_filter);
            % eigenvalues(subthreshold_i) = [];
        elseif strcmpi(feature_filter, 'percent_var')
            percent_var = 0;
            for var_index = 1:length(pc_variance)
                percent_var = percent_var + pc_variance(var_index);
                if percent_var > feature_value
                    tot_pcs = var_index;
                    break
                end
            end
            pca_results.(region).old_pca_score = pca_score;
            % test_output = (pca_input-estimated_mean)*coeff;
            pca_score = (pca_struct.(region).z_region_pca_input - estimated_mean) * coeff(:,1:tot_pcs);
            labeled_pcs.(region) = labeled_pcs.(region)(1:tot_pcs, :);
        end
        pca_results.(region).pca_score = pca_score;

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
        event_struct.(region) = split_relative_response(pca_relative_response, pc_names, all_events, bin_size, pre_time, post_time);
        event_struct.(region).relative_response = pca_relative_response;
        event_struct.(region).psth = sum(pca_relative_response, 1) / tot_trials;
    end
end