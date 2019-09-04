function [pca_results, labeled_pcs] = calc_pca(labeled_data, mnts_struct, ...
        feature_filter, feature_value)

    pca_results = struct;
    pca_results.all_events = mnts_struct.all_events;
    labeled_pcs = labeled_data;

    unique_regions = fieldnames(labeled_data);
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        %% Grab z scored mnts format for current region and does PCA
        pca_input = mnts_struct.(region).z_mnts;
        [coeff, pca_score, eigenvalues, ~, pc_variance, estimated_mean] = pca(pca_input);

        %% Store PCA results
        pca_results.(region).component_variance = pc_variance;
        pca_results.(region).eigenvalues = eigenvalues;
        pca_results.(region).coeff = coeff;
        pca_results.(region).estimated_mean = estimated_mean;

        %% Determine what pcs to use
        [~, tot_pcs] = size(pca_score);
        if strcmpi(feature_filter, 'pcs')
            %% Grabs desired number of principal components from the score
            if feature_value > tot_pcs
                pca_results.(region).original_weighted_mnts = pca_score;
            else
                tot_pcs = feature_value;
                pca_results.(region).original_weighted_mnts = pca_score;
                pca_score = pca_score(:, 1:tot_pcs);
                labeled_pcs.(region) = labeled_pcs.(region)(1:tot_pcs, :);
            end
        elseif strcmpi(feature_filter, 'eigen')
            %TODO check eigenvalues and recreate pca scores with new weights
            % subthreshold_i = find(eigenvalues < feature_filter);
            % eigenvalues(subthreshold_i) = [];
        elseif strcmpi(feature_filter, 'percent_var')
            %% Finds componets needed to explain desired variance
            if feature_filter < 1
                %% Feature filtered is percentage because the variance is also a percentage
                feature_filter = feature_filter * 100;
            end
            percent_var = 0;
            for var_index = 1:length(pc_variance)
                percent_var = percent_var + pc_variance(var_index);
                if percent_var > feature_value
                    tot_pcs = var_index;
                    break
                end
            end
            pca_results.(region).original_weighted_mnts = pca_score;
            %% Recalculate the scores with the new set of coefficients
            pca_score = (mnts_struct.(region).z_mnts - estimated_mean) * coeff(:,1:tot_pcs);
            labeled_pcs.(region) = labeled_pcs.(region)(1:tot_pcs, :);
        end
        pca_results.(region).weighted_mnts = pca_score;
        [~, tot_components] = size(pca_score);
        pc_names = cell(tot_components, 1);
        for component_i = 1:tot_components
            pc_names{component_i} = ['pc_', num2str(component_i)];
        end
        %% Reset labeled data
        labeled_pcs.(region).sig_channels = pc_names;
        labeled_pcs.(region).user_channels = pc_names;
        labeled_pcs.(region).channel_data = num2cell(pca_score, 1)';
    end
end