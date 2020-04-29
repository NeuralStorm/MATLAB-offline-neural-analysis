function [sig_neurons, non_sig_neurons, cluster_struct] = receptive_field_analysis(...
        label_log, psth_struct, bin_size, window_start, baseline_start, baseline_end, ...
        response_start, response_end, span, threshold_scale, sig_check, sig_alpha, ...
        consec_bins, unsmoothed_recfield_metrics, cluster_analysis, bin_gap, ...
        column_names)
    %% Abbreviations: fl = first latency, ll = last latency, pl = peak latency
    %% rm = response magnitude, bfr = background firing rate
    %% Establish baseline and response indices
    pre_event_bins = (length(-abs(window_start):bin_size:0)) - 1;
    baseline_start_i = round(((abs(window_start) - abs(baseline_start)) / bin_size)) + 1;
    baseline_end_i = round(((abs(window_start) - abs(baseline_end)) / bin_size));
    response_start_i = round((response_start / bin_size)) + 1;
    response_end_i = round(response_end / bin_size);

    event_strings = psth_struct.all_events(:,1)';
    cluster_struct = struct;
    sig_neurons = [];
    non_sig_neurons = [];
    unique_regions = fieldnames(label_log);
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        region_table = label_log.(region);
        for event_i = 1:length(event_strings(1,:))
            event = event_strings{event_i};
            for neuron_i = 1:height(region_table)
                neuron = region_table.sig_channels{neuron_i};
                user_channels = region_table.user_channels(strcmpi(region_table.sig_channels, neuron));
                notes = region_table.recording_notes(strcmpi(region_table.sig_channels, neuron));
                if strcmpi(class(notes), 'double') && isnan(notes)
                    notes = 'n/a';
                end
                %% Get current PSTH and smooth it based on span
                psth = psth_struct.(region).(event).(neuron).psth;
                psth = smooth(psth, span);
                pre_psth = psth(1:pre_event_bins);
                post_psth = psth((pre_event_bins + 1):end);
                baseline_psth = pre_psth(baseline_start_i:baseline_end_i);
                response_psth = post_psth(response_start_i:response_end_i);

                %% Determine if psth is signficant
                [threshold, avg_bfr, bfr_std] = get_threshold(baseline_psth, threshold_scale);
                [is_sig, p_val] = check_significance(baseline_psth, ...
                    response_psth, threshold, consec_bins, sig_check, sig_alpha);

                if is_sig
                    %% Finds results of the receptive field analysis
                    if unsmoothed_recfield_metrics
                        psth = psth_struct.(region).(event).(neuron).psth;
                        pre_psth = psth(1:pre_event_bins);
                        post_psth = psth((pre_event_bins + 1):end);
                        baseline_psth = pre_psth(baseline_start_i:baseline_end_i);
                        response_psth = post_psth(response_start_i:response_end_i);
                        %! smoothed threshold < unsmoothed threshold
                        %! May not be significant response with unsmoothed version
                        [~, avg_bfr, bfr_std] = get_threshold(baseline_psth, threshold_scale);

                        %% Verify that enough consec bins exist
                        supra_i = find(response_psth > threshold);
                        if ~check_consec_bins(supra_i, consec_bins)
                            cluster_data = num2cell(nan(1, 28));
                            non_sig_neurons = [non_sig_neurons; {region}, ...
                                {neuron}, {user_channels}, {event}, {0}, ...
                                {avg_bfr}, {bfr_std}, {threshold}, {p_val}, {NaN}, ...
                                {NaN}, {NaN}, {NaN}, {NaN}, {NaN}, {NaN}, {NaN}, ...
                                {NaN}, {strings}, {NaN}, {notes}, cluster_data];
                            continue
                        end
                    end
                    supra_i = find(response_psth > threshold);
                    overall_psth_response = response_psth(supra_i(1):supra_i(end));
                    [fl, ll, duration, pl, peak, corrected_peak, rm, ...
                        corrected_rm] = get_response_metrics(avg_bfr, ...
                        overall_psth_response, supra_i, bin_size, response_start);

                    % Organizes data results into cell array
                    rec_data = [{region}, {neuron}, ...
                        {user_channels}, {event}, {1}, {avg_bfr}, ...
                        {bfr_std}, {threshold}, {p_val}, {fl}, {ll}, ...
                        {duration}, {pl}, {peak}, {corrected_peak}, ...
                        {rm}, {corrected_rm}, {NaN}, {strings}, {NaN}, ...
                        {notes}];
                    if cluster_analysis
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
                    sig_neurons = [sig_neurons; rec_data, cluster_data];
                else
                    % Puts NaN for non significant neurons
                    cluster_data = num2cell(nan(1, 28));
                    non_sig_neurons = [non_sig_neurons; {region}, ...
                        {neuron}, {user_channels}, {event}, {0}, ...
                        {avg_bfr}, {bfr_std}, {threshold}, {p_val}, {NaN}, ...
                        {NaN}, {NaN}, {NaN}, {NaN}, {NaN}, {NaN}, {NaN}, ...
                        {NaN}, {strings}, {NaN}, {notes}, cluster_data];
                end
            end
        end
    end

    %% Convert cell arrays to tables for future data handeling
    if ~isempty(sig_neurons)
        sig_neurons = cell2table(sig_neurons, 'VariableNames', column_names);
        %% Normalize response magnitude and find primary event for each neuron
        % Normalizes response magnitude on response magnitude, not response magnitude - background rate
        for neuron_i = 1:length(sig_neurons.sig_channels)
            neuron = sig_neurons.sig_channels{neuron_i};
            if ~isempty(sig_neurons.sig_channels(strcmpi(sig_neurons.sig_channels, neuron)))
                    sig_events = sig_neurons.event(strcmpi(sig_neurons.sig_channels, neuron));
                    sig_magnitudes = sig_neurons.response_magnitude(strcmpi(sig_neurons.sig_channels, neuron));
                    [max_magnitude, max_index] = max(sig_magnitudes);
                    norm_magnitude = sig_magnitudes ./ max_magnitude;
                    principal_event = sig_events(max_index);
                    total_sig_events = length(sig_magnitudes);
                    sig_neurons.total_sig_events(strcmpi(sig_neurons.sig_channels, neuron)) = ...
                        total_sig_events;
                    sig_neurons.principal_event(strcmpi(sig_neurons.sig_channels, neuron)) = ...
                        {principal_event};
                    sig_neurons.norm_response_magnitude(strcmpi(sig_neurons.sig_channels, neuron)) = ...
                        norm_magnitude;
            end
        end
    end

    if ~isempty(non_sig_neurons)
        non_sig_neurons = cell2table(non_sig_neurons, 'VariableNames', column_names);
    end
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
        bfr, above_threshold, suprathreshold_i, bin_size, response_start)
    %% Abbreviations: fl = first latency, ll = last latency, pl = peak latency
    %% rm = response magnitude
    %% Finds results of the receptive field analysis
    % suprathreshold_i = find(response_psth > threshold);
    % above_threshold = response_psth(suprathreshold_i);
    fl = ((suprathreshold_i(1)) * bin_size) + response_start + (bin_size / 2);
    ll = ((suprathreshold_i(end)) * bin_size) + response_start + (bin_size / 2);
    peak = max(above_threshold);
    peak_index = find(peak == above_threshold);
    pl = (peak_index(1) * bin_size) + response_start - (bin_size / 2);
    corrected_peak = peak - bfr;
    rm = sum(above_threshold);
    corrected_rm = rm - bfr;
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