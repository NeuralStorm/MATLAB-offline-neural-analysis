function [pca_results, event_struct, labeled_pcs] = calc_pca(labeled_neurons, ...
    mnts_struct, bin_size, pre_time, post_time, feature_filter, feature_value)

    pca_results = struct;
    event_struct = struct;
    labeled_pcs = labeled_neurons;

    event_window = -(abs(pre_time)):bin_size:(abs(post_time));
    tot_bins = length(event_window) - 1;
    event_struct.all_events = mnts_struct.all_events;

    unique_regions = fieldnames(labeled_neurons);
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        pca_input = mnts_struct.(region).z_mnts;
        [coeff, pca_score, eigenvalues, ~, pc_variance, estimated_mean] = pca(pca_input);
        pca_results.(region).pc_variance = pc_variance;
        pca_results.(region).eigenvalues = eigenvalues;
        pca_results.(region).coeff = coeff;
        pca_results.(region).estimated_mean = estimated_mean;
        
        [tot_rows, tot_pcs] = size(pca_score);
        tot_trials = tot_rows / tot_bins;
        if strcmpi(feature_filter, 'pcs')
            if feature_value > tot_pcs
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
            pca_score = (mnts_struct.(region).z_mnts - estimated_mean) * coeff(:,1:tot_pcs);
            labeled_pcs.(region) = labeled_pcs.(region)(1:tot_pcs, :);
        end
        pca_results.(region).pca_score = pca_score;
        %% Convert score (MNTS) to PSTH
        [pca_relative_response, pc_names] = mnts_to_psth(pca_score, tot_trials, tot_pcs, tot_bins, 'pc');
        labeled_pcs.(region)(:, 1) = pc_names;
        event_struct.(region) = split_relative_response(pca_relative_response, ...
            pc_names, mnts_struct.all_events, bin_size, pre_time, post_time);
        event_struct.(region).relative_response = pca_relative_response;
        event_struct.(region).psth = sum(pca_relative_response, 1) / tot_trials;
        event_struct.(region).mnts = pca_score;
    end
end