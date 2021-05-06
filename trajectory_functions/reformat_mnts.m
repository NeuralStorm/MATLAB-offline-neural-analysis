function [rr_data] = reformat_mnts(chan_group_log, component_results, tot_bins)
    %% Purpose: Reformat MNTS to PSTH
    % mnts: multineuron time series
    %       Observations (trials * tot bins) x Features (components or channels)
    % psth: peri-stimulis time histogram
    %       Trials X (Features (components or channels) * tot bins)
    %% Input
    % chan_group_log: struct w/ fields for each feature set
    %            field: table with columns
    %                   'channel': String with name of channel
    %                   'selected_channels': Boolean if channel is used
    %                   'user_channels': String with user defined mapping
    %                   'chan_group': String: associated chan_group or grouping of electrodes
    %                   'chan_group_id': Int: unique id used for chan_groups
    %                   'recording_session': Int: File recording session number that above applies to
    %                   'recording_notes': String with user defined notes for channel
    % component_results: struct w/ fields for each feature set ran through PCA
    %                    feature_name: struct with fields
    %                                  componenent_variance: Vector with % variance explained by each component
    %                                  eigenvalues: Vector with eigen values
    %                                  coeff: NxN (N = tot features) matrix with coeff weights used to scale mnts into PC space
    %                                         Columns: Component Row: Feature
    %                                  estimated_mean: Vector with estimated means for each feature
    %                                  mnts: mnts matrix
    % tot_bins: total bins that unit has within the mnts
    %% Output:
    % rr_data: struct w/ fields for each feature
    %              feature_name: struct typically based on chan_group and powers
    %                            relative_response: Numerical matrix with dimensions Trials x ((tot pcs or channels) * tot bins)
    rr_data = struct;
    unique_ch_groups = unique(chan_group_log.chan_group);
    %% Convert weighted mnts into relative response
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        ch_group_mnts = component_results.(ch_group).mnts;
        [tot_rows, tot_components] = size(ch_group_mnts);
        tot_trials = tot_rows / tot_bins;
        rr = mnts_to_psth(ch_group_mnts, tot_trials, tot_components, tot_bins);
        rr_data.(ch_group).relative_response = rr;
        rr_data.(ch_group).chan_order = component_results.(ch_group).chan_order;
        rr_data.(ch_group).orig_chan_order = component_results.(ch_group).orig_chan_order;
    end
end