function [psth_struct] = reformat_mnts(label_log, component_results, tot_bins)
    %% Purpose: Reformat MNTS to PSTH
    % mnts: multineuron time series
    %       Observations (trials * tot bins) x Features (components or channels)
    % psth: peri-stimulis time histogram
    %       Trials X (Features (components or channels) * tot bins)
    %% Input
    % label_log: struct w/ fields for each feature set
    %            field: table with columns
    %                   'sig_channels': String with name of channel
    %                   'selected_channels': Boolean if channel is used
    %                   'user_channels': String with user defined mapping
    %                   'label': String: associated region or grouping of electrodes
    %                   'label_id': Int: unique id used for labels
    %                   'recording_session': Int: File recording session number that above applies to
    %                   'recording_notes': String with user defined notes for channel
    % component_results: struct w/ fields for each feature set ran through PCA
    %                    feature_name: struct with fields
    %                                  componenent_variance: Vector with % variance explained by each component
    %                                  eigenvalues: Vector with eigen values
    %                                  coeff: NxN (N = tot features) matrix with coeff weights used to scale mnts into PC space
    %                                         Columns: Component Row: Feature
    %                                  estimated_mean: Vector with estimated means for each feature
    %                                  weighted_mnts: mnts mapped into pc space with feature filter applied
    % tot_bins: total bins that unit has within the mnts
    %% Output:
    % psth_struct: struct w/ fields for each feature
    %              feature_name: struct typically based on regions and powers
    %                            relative_response: Numerical matrix with dimensions Trials x ((tot pcs or channels) * tot bins)
    psth_struct = struct;
    unique_regions = unique(label_log.label);
    %% Convert weighted mnts into relative response
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        region_mnts = component_results.(region).weighted_mnts;
        [tot_rows, tot_components] = size(region_mnts);
        tot_trials = tot_rows / tot_bins;
        relative_response = mnts_to_psth(region_mnts, tot_trials, tot_components, tot_bins);
        psth_struct.(region).relative_response = relative_response;
        psth_struct.(region).label_order = component_results.(region).label_order;
        psth_struct.(region).chan_order = component_results.(region).chan_order;
    end
end