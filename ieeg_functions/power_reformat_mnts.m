function [psth_struct, baseline_struct, response_struct] = power_reformat_mnts(label_log, component_results, ...
        bin_size, window_start, window_end, baseline_start, baseline_end, ...
        response_start, response_end, window_shift_time)

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
    %                    'all_events': Nx2 cell array where N is the number of events
    %                                  Column 1: event label (ex: event_1)
    %                    feature_name: struct with fields
    %                                  componenent_variance: Vector with % variance explained by each component
    %                                  eigenvalues: Vector with eigen values
    %                                  coeff: NxN (N = tot features) matrix with coeff weights used to scale mnts into PC space
    %                                         Columns: Component Row: Feature
    %                                  estimated_mean: Vector with estimated means for each feature
    %                                  weighted_mnts: mnts mapped into pc space with feature filter applied
    %                                  tfr: struct with fields for each power
    %                                           (Note: This was added in the batch_power_pca function and not in the calc_pca call)
    %                                           bandname: struct with fields for each event type
    %                                                     event: struct with fields with tfr & z tfr avg, std, ste
    %                                                            fieldnames: avg_tfr, avg_z_tfr, std_tfr, std_z_tfr, ste_tfr, & ste_z_tfr
    % bin_size: size of bins
    % window_start: start time of window
    % window_end: end time of window
    % baseline_start: baseline window start
    % baseline_end: baseline window end
    % response_start: response window start
    % response_end: response window end
    % window_shift_time: Time point where window shifts from pre to post
    %% Output:
    % psth_struct: struct w/ fields for each feature
    %              'all_events': Nx2 cell array where N is the number of events
    %                            Column 1: event label (ex: event_1)
    %              feature_name: struct typically based on regions and powers
    %                            relative_response: Numerical matrix with dimensions Trials x ((tot pcs or channels) * tot bins)
    %                            event: struct with fields:
    %                                   relative_response: Numerical matrix w/ dims Trials x ((tot pcs or channels) * tot bins)
    %                                   psth: Numerical matrix w/ dims 1 X ((tot pcs or channels) * tot bins)
    %                                         Mathematically: Sum of trials in relative response
    %                                   componenet: struct based on components (either pc or channel) used to create relative response
    %                                               relative_response: Numerical matrix w/ dims Trials x tot bins
    %                                               psth: Numerical matrix w/ dims 1 X tot bins
    % baseline_struct: same as psth_struct, but tot_bins = len(baseline_start:bin_size:baseline_end)
    % response_struct: same as psth_struct, but tot_bins = len(response_start:bin_size:response_end)

    psth_struct = struct;
    all_events = component_results.all_events;
    psth_struct.all_events = all_events;

    unique_regions = fieldnames(label_log);
    tot_bins = length(-abs(window_start):bin_size:window_end) - 1;
    %% Convert weighted mnts into relative response
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        region_labels = label_log.(region).sig_channels;
        region_mnts = component_results.(region).weighted_mnts;
        [tot_rows, tot_components] = size(region_mnts);
        tot_trials = tot_rows / tot_bins;
        relative_response = mnts_to_psth(region_mnts, tot_trials, tot_components, tot_bins);
        psth_struct.(region) = split_relative_response(relative_response, region_labels, ...
            all_events(1, :), tot_bins);
        psth_struct.(region).relative_response = relative_response;

        unique_events = all_events(:, 1);
        unique_events = unique_events(~ismember(unique_events, 'all'));
        for event_i = 1:numel(unique_events)
            event = unique_events{event_i};
            event_indices = all_events{ismember(all_events(:, 1), event), 2};
            event_response = relative_response(event_indices, :);
            [tot_events, ~] = size(event_response);
            event_struct = split_relative_response(event_response, region_labels, ...
                [{event}, {ones(tot_events, 1)}], tot_bins);
            psth_struct.(region).(event) = event_struct.(event);
            relative_response = [relative_response; event_response];
        end

        psth_struct.(region).relative_response = relative_response;
    end

    %% Create the analysis windows for PSTH analysis
    [baseline_struct, response_struct] = create_analysis_windows(label_log, psth_struct, ...
    window_start, baseline_start, baseline_end, window_end, response_start, response_end, bin_size, window_shift_time);
end