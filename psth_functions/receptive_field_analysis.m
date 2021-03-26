function [rec_table] = receptive_field_analysis(...
        psth_struct, event_info, bin_size, window_start, window_end, baseline_start, baseline_end, ...
        response_start, response_end, span, threshold_scale, sig_check, sig_alpha, consec_bins, ...
        mixed_smoothing, cluster_analysis, bin_gap)
    %% Abbreviations: fl = first latency, ll = last latency, pl = peak latency
    %% rm = response magnitude, bfr = background firing rate

    %% Create population table
    rec_headers = [["region", "string"]; ["channel", "string"]; ...
                   ["event", "string"]; ["significant", "double"]; ...
                   ["background_rate", "double"]; ["background_std", "double"]; ...
                   ["avg_response", "double"]; ["response_window_rm", "double"];
                   ["threshold", "double"]; ["p_val", "double"]; ...
                   ["first_latency", "double"]; ["last_latency", "double"]; ...
                   ["duration", "double"]; ["peak_latency", "double"]; ...
                   ["peak_response", "double"]; ["corrected_peak", "double"]; ...
                   ["response_magnitude", "double"]; ["corrected_response_magnitude", "double"]];
    rec_table = prealloc_table(rec_headers, [0, size(rec_headers, 1)]);

    cluster_struct = struct;
    unique_regions = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    [~, tot_bins] = get_bins(window_start, window_end, bin_size);
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        tot_chans = numel(psth_struct.(region).label_order);
        for event_i = 1:numel(unique_events)
            event = unique_events{event_i};
            event_indices = event_info.event_indices(strcmpi(event_info.event_labels, event), :);
            chan_s = 1;
            chan_e = tot_bins;
            for chan_i = 1:tot_chans
                chan = psth_struct.(region).label_order{chan_i};
                chan_rr = psth_struct.(region).relative_response(event_indices, chan_s:chan_e);

                %% Get current PSTH and smooth it based on span
                psth = calc_psth(chan_rr);
                psth = smooth(psth, span)'; %WTF IS GOING ON HERE
                baseline_psth = slice_rr(psth, bin_size, window_start, ...
                    window_end, baseline_start, baseline_end);
                response_psth = slice_rr(psth, bin_size, window_start, ...
                    window_end, response_start, response_end);

                %% Determine if psth is signficant
                [threshold, avg_bfr, bfr_std] = get_threshold(baseline_psth, threshold_scale);
                [is_sig, p_val] = check_significance(baseline_psth, ...
                    response_psth, threshold, consec_bins, sig_check, sig_alpha);

                if is_sig
                    supra_i = find(response_psth > threshold);
                    overall_psth_response = response_psth(supra_i(1):supra_i(end));
                    [fl, ll, duration, ~, ~, ~, ~, ~] = get_response_metrics(avg_bfr, ...
                        overall_psth_response, supra_i, bin_size, response_start);
                    %% Finds results of the receptive field analysis
                    if mixed_smoothing
                        psth = calc_psth(chan_rr);
                        baseline_psth = slice_rr(psth, bin_size, window_start, ...
                            window_end, baseline_start, baseline_end);
                        response_psth = slice_rr(psth, bin_size, window_start, ...
                            window_end, response_start, response_end);
                        %! smoothed threshold < unsmoothed threshold
                        %! May not be significant response with unsmoothed version

                        %% Verify that enough consec bins exist
                        supra_i = find(response_psth > threshold);
                        if ~check_consec_bins(supra_i, consec_bins)
                            is_sig = false;
                        end
                        supra_i = find(response_psth > threshold);
                        overall_psth_response = response_psth(supra_i(1):supra_i(end));
                    end
                    [~, ~, ~, pl, peak, corrected_peak, rm, ...
                        corrected_rm] = get_response_metrics(avg_bfr, ...
                        overall_psth_response, supra_i, bin_size, response_start);
                else
                    % Puts NaN for non significant neurons
                    cluster_data = num2cell(nan(1, 28));
                    fl = NaN; ll = NaN; duration = NaN; pl = NaN; peak = NaN;
                    corrected_peak = NaN; rm = NaN; corrected_rm = NaN;
                end
                %%Average response within the response window
                avg_response = mean(response_psth);
                response_window_rm = sum(response_psth); 
                % Add rec results
                rec_data = [{region}, {chan}, {event}, is_sig, avg_bfr, ...
                    bfr_std, avg_response, response_window_rm, threshold, p_val, fl, ll, ...
                    duration, pl, peak, corrected_peak, rm, corrected_rm];
                rec_table = concat_cell(rec_table, rec_data, rec_headers(:, 1));

                if is_sig && cluster_analysis
                    [neuron_cluster, tot_clusters] = find_clusters(...
                        response_psth, bin_gap, consec_bins, threshold);
                    %% Go through clusters and calc receptive field measures
                    cluster_names = fieldnames(neuron_cluster);
                    for cluster_i = 1:length(cluster_names)
                        curr_cluster = cluster_names{cluster_i};
                        supra_i = neuron_cluster.(curr_cluster).cluster_indices;
                        cluster_response = response_psth(supra_i(1):supra_i(end));
                        [fl, ll, duration, pl, peak, corrected_peak, rm, corrected_rm] = get_response_metrics(...
                            avg_bfr, cluster_response, supra_i, bin_size, response_start);
                        neuron_cluster.(curr_cluster).fl = fl;
                        neuron_cluster.(curr_cluster).ll = ll;
                        neuron_cluster.(curr_cluster).duration = duration;
                        neuron_cluster.(curr_cluster).pl = pl;
                        neuron_cluster.(curr_cluster).peak = peak;
                        neuron_cluster.(curr_cluster).corrected_peak = corrected_peak;
                        neuron_cluster.(curr_cluster).rm = rm;
                        neuron_cluster.(curr_cluster).corrected_rm = corrected_rm;
                        if contains(curr_cluster, 'first')
                            first_rm = rm;
                            first_data = [{tot_clusters}, {fl}, {ll}, ...
                                {duration}, {pl}, {peak}, {corrected_peak}, ...
                                {rm}, {corrected_rm}, {NaN}];
                        elseif contains(curr_cluster, 'primary')
                            primary_rm = rm;
                            primary_data = [{fl}, {ll}, ...
                                {duration}, {pl}, {peak}, {corrected_peak}, ...
                                {rm}, {corrected_rm}, {NaN}];
                        elseif contains(curr_cluster, 'last')
                            last_rm = rm;
                            last_data = [{fl}, {ll}, ...
                                {duration}, {pl}, {peak}, {corrected_peak}, ...
                                {rm}, {corrected_rm}, {NaN}];
                        end
                        neuron_cluster.response_psth = response_psth;
                        neuron_cluster.threshold = threshold;
                        cluster_struct.(region).(event).(neuron) = neuron_cluster;
                    end
                    first_data(end) = {first_rm / primary_rm};
                    primary_data(end) = {1};
                    last_data(end) = {last_rm / primary_rm};
                    cluster_data = [first_data, primary_data, last_data];
                else
                    cluster_data = num2cell(nan(1, 28));
                end

                %% Update channel counter
                chan_s = chan_s + tot_bins;
                chan_e = chan_e + tot_bins;
            end
        end
    end

    %% Convert cell arrays to tables for future data handeling
    % if ~isempty(sig_neurons)
    %     sig_neurons = cell2table(sig_neurons, 'VariableNames', column_names);
    %     %% Normalize response magnitude and find primary event for each neuron
    %     % Normalizes response magnitude on response magnitude, not response magnitude - background rate
    %     for neuron_i = 1:length(sig_neurons.sig_channels)
    %         neuron = sig_neurons.sig_channels{neuron_i};
    %         if ~isempty(sig_neurons.sig_channels(strcmpi(sig_neurons.sig_channels, neuron)))
    %                 sig_events = sig_neurons.event(strcmpi(sig_neurons.sig_channels, neuron));
    %                 sig_magnitudes = sig_neurons.response_magnitude(strcmpi(sig_neurons.sig_channels, neuron));
    %                 [max_magnitude, max_index] = max(sig_magnitudes);
    %                 norm_magnitude = sig_magnitudes ./ max_magnitude;
    %                 principal_event = sig_events(max_index);
    %                 total_sig_events = length(sig_magnitudes);
    %                 sig_neurons.total_sig_events(strcmpi(sig_neurons.sig_channels, neuron)) = ...
    %                     total_sig_events;
    %                 sig_neurons.principal_event(strcmpi(sig_neurons.sig_channels, neuron)) = ...
    %                     {principal_event};
    %                 sig_neurons.norm_response_magnitude(strcmpi(sig_neurons.sig_channels, neuron)) = ...
    %                     norm_magnitude;
    %         end
    %     end
    % end
end

function [is_sig, p_val] = check_significance(baseline_psth, response_psth, ...
        threshold, consec_bins, sig_check, sig_alpha)
    %% Determine if response psth is significant
    is_sig = false;
    reject_null = false;
    p_val = NaN;
    %% Find above threshold indices and check consecutive bin length
    suprathreshold_i = find(response_psth > threshold);
    is_consec = check_consec_bins(suprathreshold_i, consec_bins);
    if is_consec
        %% IF consecutive --> statistical testing on baseline and response
        if sig_check == 1
            % Unpaired ttest on pre and post windows
            [reject_null, p_val] = ttest2(baseline_psth, response_psth, ...
                'Alpha', sig_alpha);
        elseif sig_check == 2
            % ks test on pre and post windows
            [reject_null, p_val] = kstest2(baseline_psth, response_psth, ...
                'Alpha', sig_alpha);
        elseif sig_check ~= 0
            error('Invalid sig check. Valid checks = 0, 1, 2.');
        end
        % If the null hypothesis is rejected, then there is a significant response
        if isnan(reject_null)
            reject_null = false;
        end
        if reject_null || sig_check == 0
            is_sig = true;
        end
    end
end

function [is_consecutive] = check_consec_bins(suprathreshold_i, consec_bins)
    %% Checks for consecutive bins
    tot_consec = 1;
    is_consecutive = false;
    if length(suprathreshold_i) == 1 && consec_bins == 1
        is_consecutive = true;
        return
    elseif length(suprathreshold_i) == 1 && consec_bins ~= 1
        return
    elseif length(suprathreshold_i) >= consec_bins
        for i = 2:length(suprathreshold_i)
            index_gap = suprathreshold_i(i) - suprathreshold_i(i - 1);
            if index_gap == 1
                tot_consec = tot_consec + 1;
                if tot_consec >= consec_bins
                    is_consecutive = true;
                    return
                end
            else
                tot_consec = 1;
            end
        end
    end
end

function [threshold, avg_bfr, bfr_std] = get_threshold(baseline_psth, threshold_scale)
    avg_bfr = mean(baseline_psth);
    bfr_std = std(baseline_psth);
    threshold = avg_bfr + (threshold_scale * bfr_std);
end

function [fl, ll, duration, pl, peak, corrected_peak, rm, corrected_rm] = get_response_metrics(...
        bfr, sig_response_bins, suprathreshold_i, bin_size, response_start)
    %% Abbreviations: fl = first latency, ll = last latency, pl = peak latency
    %% rm = response magnitude
    %% Finds results of the receptive field analysis
    fl = ((suprathreshold_i(1)) * bin_size) + response_start;
    ll = ((suprathreshold_i(end)) * bin_size) + response_start + bin_size;
    peak = max(sig_response_bins);
    peak_index = find(peak == sig_response_bins);
    pl = (peak_index(1) * bin_size) + fl - bin_size;
    corrected_peak = peak - bfr;
    rm = sum(sig_response_bins);
    corrected_rm = rm - (bfr * (suprathreshold_i(end) - suprathreshold_i(1)));
    duration = ll - fl;
end

function [cluster_struct, tot_clusters] = find_clusters(response, bin_gap, consec_bins, threshold)
    cluster_struct = struct;
    suprathreshold_i = find(response > threshold);
    cluster_edges_i = find(diff(suprathreshold_i) >= bin_gap);
    cluster_edges_i(end + 1) = 0;
    cluster_edges_i = sort(cluster_edges_i);
    tot_clusters = 1;
    curr_cluster = 'cluster_1';
    if length(cluster_edges_i) == 1
        cluster_indices = suprathreshold_i;
        cluster_struct.primary_cluster.cluster_indices= cluster_indices;
        cluster_struct.first_cluster.cluster_indices= cluster_indices;
        cluster_struct.last_cluster.cluster_indices= cluster_indices;
        cluster_struct.(curr_cluster).cluster_indices= cluster_indices;
    else
        max_rm = 0;
        primary_cluster = curr_cluster;
        for cluster_i = 1:length(cluster_edges_i)
            cluster_start = cluster_edges_i(cluster_i) + 1;
            if cluster_i == length(cluster_edges_i)
                cluster_end = length(suprathreshold_i);
            else
                cluster_end = cluster_edges_i(cluster_i + 1);
            end
            cluster_indices = suprathreshold_i(cluster_start:cluster_end);
            if length(cluster_indices) < consec_bins || ~check_consec_bins(cluster_indices, consec_bins)
                continue
            end

            %% Compare current cluster to max response
            cluster_rm = sum(response(cluster_indices(1):cluster_indices(end)));
            if cluster_rm > max_rm
                max_rm = cluster_rm;
                primary_cluster = curr_cluster;
            end

            %% Store and update cluster info
            cluster_struct.(curr_cluster).cluster_indices = cluster_indices;
            if cluster_i ~= length(cluster_edges_i)
                tot_clusters = tot_clusters + 1;
                curr_cluster = ['cluster_', num2str(tot_clusters)];
            end
        end
        all_clusters = fieldnames(cluster_struct);
        cluster_struct.first_cluster = cluster_struct.(all_clusters{1});
        cluster_struct.last_cluster = cluster_struct.(all_clusters{end});
        cluster_struct.primary_cluster = cluster_struct.(primary_cluster);
    end
end