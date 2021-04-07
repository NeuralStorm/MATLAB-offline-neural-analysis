function [cluster_struct, res] = do_cluster_analysis(rec_results, psth_struct, event_info, ...
        window_start, window_end, response_start, response_end, bin_size, span, consec_bins, bin_gap)

    %% Create cluster results table
    headers = [["region", "string"]; ["channel", "string"]; ...
               ["event", "string"]; ["tot_clusters", "double"]; ["first_first_latency", "double"]; ...
               ["first_last_latency", "double"]; ["first_duration", "double"]; ...
               ["first_peak_latency", "double"]; ["first_peak_response", "double"]; ...
               ["first_corrected_peak", "double"]; ["first_response_magnitude", "double"]; ...
               ["first_corrected_response_magnitude", "double"]; ["first_norm_response_magnitude", "double"]; ...
               ["primary_first_latency", "double"]; ["primary_last_latency", "double"]; ...
               ["primary_duration", "double"]; ["primary_peak_latency", "double"]; ...
               ["primary_peak_response", "double"]; ["primary_corrected_peak", "double"]; ...
               ["primary_response_magnitude", "double"]; ["primary_corrected_response_magnitude", "double"]; ...
               ["primary_norm_response_magnitude", "double"]; ["last_first_latency", "double"]; ...
               ["last_last_latency", "double"]; ["last_duration", "double"]; ["last_peak_latency", "double"]; ...
               ["last_peak_response", "double"]; ["last_corrected_peak", "double"]; ...
               ["last_response_magnitude", "double"]; ["last_corrected_response_magnitude", "double"]; ...
               ["last_norm_response_magnitude", "double"]];
    res = prealloc_table(headers, [0, size(headers, 1)]);
    cluster_struct = struct;

    %% Get info on regions, events, and bins
    [~, tot_bins] = get_bins(window_start, window_end, bin_size);
    [response_edges, ~] = get_bins(response_start, response_end, bin_size);
    unique_regions = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    for reg_i = 1:numel(unique_regions)
        region = unique_regions{reg_i};
        chan_order = psth_struct.(region).label_order;
        for event_i = 1:numel(unique_events)
            event = unique_events{event_i};
            sig_chans = rec_results.channel(strcmpi(rec_results.region, region) ...
                & strcmpi(rec_results.event, event) & rec_results.significant == 1, :);
            [~, sig_chan_i, ~] = intersect(chan_order, sig_chans);
            if isempty(sig_chan_i)
                %% Skips event if there are not significant channels
                continue
            end
            event_indices = event_info.event_indices(strcmpi(event_info.event_labels, event), :);
            for sig_i = 1:numel(sig_chan_i)
                %TODO come up with better variable names
                chan_i = sig_chan_i(sig_i);
                chan = chan_order{chan_i};
                threshold = rec_results.threshold(strcmpi(rec_results.region, region) ...
                    & strcmpi(rec_results.event, event) & strcmpi(rec_results.channel, chan), :);
                bfr = rec_results.background_rate(strcmpi(rec_results.region, region) ...
                    & strcmpi(rec_results.event, event) & strcmpi(rec_results.channel, chan), :);
                %% Get channel relative response
                chan_e = chan_i * tot_bins; % 1: 80 2: 160 24: 1920 25: 2000 26: 2080
                chan_s = chan_e - tot_bins + 1; % 1: 1 2: 81 24: 1841 25: 1921 26: 2001
                chan_rr = psth_struct.(region).relative_response(event_indices, chan_s:chan_e);
                psth = calc_psth(chan_rr);
                % psth = smooth(psth, span)'; % comment out to match master branch cluster analysis
                response_psth = slice_rr(psth, bin_size, window_start, ...
                    window_end, response_start, response_end);
                [chan_clusters, cluster_res] = find_clusters(...
                    response_psth, response_edges, bin_size, bin_gap, consec_bins, bfr, threshold);
                %% Append on other results to array
                if ~isempty(cluster_res)
                    cluster_struct.([region, '_', event, '_', chan]) = chan_clusters;
                    a = [{region}, {chan}, {event}, num2cell(cluster_res)];
                    res = concat_cell(res, a, headers(:, 1));
                end
            end
        end
    end
end

function [res, res_array] = find_clusters(response, response_edges, bin_size, bin_gap, consec_bins, bfr, threshold)
    %TODO mixed smoothing causes issues with finding clusters
    res = struct;
    res_array = [];
    supra_i = find(response > threshold);
    %% Explanation of dark magic below
    % diff takes all the indices in supra_i (points where bins cross threshold) and calculates difference
    % find then looks at the diff array and find the indices in supra_i that are larger than the bin gap
    % 0 is appended so that the first cluster starts at the beginning of the response
    % numel(supra_i) is appended to end the last cluster 
    cluster_edges_i = [0, find(diff(supra_i) >= bin_gap), numel(supra_i)];

    if length(cluster_edges_i) <= 2
        %% No clusters and returns
        return
    end
    curr_cluster = 'cluster_1'; tot_clusters = 1;
    max_rm = 0; primary_cluster = curr_cluster;
    res.(curr_cluster) = struct;
    for cluster_i = 1:length(cluster_edges_i) - 1
        cluster_start = cluster_edges_i(cluster_i) + 1; % +1 because matlab is 1 based
        cluster_end = cluster_edges_i(cluster_i + 1); % +1 to grab the next index in the array
        cluster_indices = supra_i(cluster_start:cluster_end); % use edges to grab all indices for cluster

        if length(cluster_indices) < consec_bins || ~check_consec_bins(cluster_indices, consec_bins)
            %% if cluster does not meet definition of a significant response, skip to next cluster
            continue
        end

        %% Compare current cluster to max response
        fl_i = cluster_indices(1); ll_i = cluster_indices(end);
        [fl, ll, duration] = get_response_latencies(response_edges, fl_i, ll_i);
        [sig_edges, ~] = get_bins(fl, ll, bin_size);
        sig_psth = response(fl_i:ll_i);
        [pl, peak, corrected_peak, rm, corrected_rm] = calc_response_rf(...
            bfr, sig_psth, duration, sig_edges);
        if rm > max_rm
            max_rm = rm;
            primary_cluster = curr_cluster;
        end
        cluster_res = [fl, ll, duration, pl, peak, corrected_peak, rm, corrected_rm, rm];

        %% Store and update cluster info
        res.(curr_cluster).cluster_indices = cluster_indices;
        res.(curr_cluster).res = cluster_res;
        if cluster_i < length(cluster_edges_i)
            tot_clusters = tot_clusters + 1;
            curr_cluster = ['cluster_', num2str(tot_clusters)];
        end
    end
    all_clusters = fieldnames(res);
    if length(all_clusters) == 1
        return
    end
    %% Grab cluster results
    first_res = res.(all_clusters{1}).res;
    primary_res = res.(primary_cluster).res;
    last_res = res.(all_clusters{end}).res;
    %% Normalize rm across clusters
    first_res(end) = first_res(end) / max_rm;
    last_res(end) = last_res(end) / max_rm;
    primary_res(end) = primary_res(end) / max_rm;
    %% Put into array
    res_array = [tot_clusters, first_res, primary_res, last_res];
    res.first_cluster = res.(all_clusters{1});
    res.last_cluster = res.(all_clusters{end});
    res.primary_cluster = res.(primary_cluster);
    res.supra_i = supra_i;
    res.cluster_edges_i = cluster_edges_i;
end