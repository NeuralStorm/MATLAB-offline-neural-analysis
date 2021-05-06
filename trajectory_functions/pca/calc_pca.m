function [pca_results, pc_log] = calc_pca(chan_group_log, mnts_struct, ...
        feature_filter, feature_value, apply_z_score)

    %% Purpose: Run Principal Component Analysis (pca) on feature sets stored in mnts_struct
    %% Input
    % chan_group_log: struct w/ fields for each feature set
    %            field: table with columns
    %                       'channel': String with name of channel
    %                       'selected_channels': Boolean if channel is used
    %                       'user_channels': String with user defined mapping
    %                       'label': String: associated chan_group or grouping of electrodes
    %                       'label_id': Int: unique id used for labels
    %                       'recording_session': Int: File recording session number that above applies to
    %                       'recording_notes': String with user defined notes for channel
    % mnts_struct: struct w/ fields for each feature set matching the feature set in chan_group_log
    %              fields:
    %                     'all_events': Nx2 cell array where N is the number of events
    %                                   Column 1: event label (ex: event_1)
    %                                   Column 2: Numeric array with timestamps for events
    %                     feature_name: struct with fields:
    %                                       Note: Order of observations are assumed to be group by event types for later separation
    %                                       mnts: Numeric input array for PCA
    %                                             Columns: Features (typically electrodes)
    %                                             Rows: Observations (typically trials * time value)
    %                                       z_mnts: Numeric input z scored array for PCA
    % feature_filter: String with description for pcs
    %                 'all': keep all pcs after PCA
    %                 'pcs': Keep # of pcs set in feature_value
    %                 'percent_var': Use X# of PCs that meet set % in feature_value
    % feature_value: Int matched to feature_filter
    %                'all': unused
    %                'pcs': Int for # of pcs to keep
    %                'percent_var': % of variance desired to be explained by pcs
    % use_z_mnts: Boolean
    %             1: use z_mnts for input into PCA
    %             0: use mnts for input into PCA
    %% Output
    % pca_results: struct w/ fields for each feature set ran through PCA
    %              fields:
    %                      feature_name: struct with fields
    %                                        componenent_variance: Vector with % variance explained by each component
    %                                        eigenvalues: Vector with eigen values
    %                                        coeff: NxN (N = tot features) matrix with coeff weights used to scale mnts into PC space
    %                                                   Columns: Component Row: Feature
    %                                        estimated_mean: Vector with estimated means for each feature
    %                                        mnts: mnts mapped into pc space with feature filter applied
    % pc_log: similar to chan_group_log, but with feature filter applied (ex: 3 pcs would only contain 3 pc names)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strcmpi(feature_filter, "percent_var")
        assert(feature_value <= 1, 'If filtering on percent_var, feature_value must be represented in decimal and not percentage');
        feature_value = feature_value * 100;
    end

    pca_results = struct;

    unique_ch_groups = unique(chan_group_log.chan_group);
    pc_log = table;
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        %% Grab mnts and apply z score accordingly
        pca_input = mnts_struct.(ch_group).mnts;
        if apply_z_score
            pca_input = zscore(pca_input);
        end
        [coeff, pca_score, eigenvalues, ~, pc_variance, estimated_mean] = pca(pca_input);

        labeled_pcs = chan_group_log(strcmpi(chan_group_log.chan_group, ch_group), :);

        %% Store PCA results
        pca_results.(ch_group).component_variance = pc_variance;
        pca_results.(ch_group).eigenvalues = eigenvalues;
        pca_results.(ch_group).coeff = coeff;
        pca_results.(ch_group).estimated_mean = estimated_mean;

        %% Adjust score matrix according to feature filter
        [~, tot_pcs] = size(pca_score);
        if strcmpi(feature_filter, 'pcs') && tot_pcs > feature_value
            %% Grabs desired number of principal components from the score
            tot_pcs = feature_value;
            pca_score = pca_score(:, 1:tot_pcs);
            labeled_pcs = labeled_pcs(1:tot_pcs, :);
        elseif strcmpi(feature_filter, 'eigen')
            %TODO check eigenvalues and recreate pca scores with new weights
            error('Eigen option not implemented yet');
            % subthreshold_i = find(eigenvalues < feature_filter);
            % eigenvalues(subthreshold_i) = [];
        elseif strcmpi(feature_filter, 'percent_var') && feature_value < 100
            %% Finds componets needed to explain desired variance
            var_sum = cumsum(pc_variance);
            tot_pcs = find(var_sum >= feature_value, 1);
            %% Grabs components needed
            pca_score = pca_score(:,1:tot_pcs);
            labeled_pcs = labeled_pcs(1:tot_pcs, :);
        end
        pca_results.(ch_group).orig_chan_order = mnts_struct.(ch_group).orig_chan_order;
        pca_results.(ch_group).mnts = pca_score;
        [~, tot_components] = size(pca_score);
        pc_names = cell(tot_components, 1);
        for component_i = 1:tot_components
            pc_names{component_i} = [ch_group, '_pc_', num2str(component_i)];
        end
        %% Reset labeled data
        labeled_pcs.channel = pc_names;
        labeled_pcs.user_channels = pc_names;
        pca_results.(ch_group).chan_order = pc_names;
        pc_log = [pc_log; labeled_pcs];
    end
end