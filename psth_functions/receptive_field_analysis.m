function [rec_res] = receptive_field_analysis(rr_data, event_info, ...
        bin_size, window_start, window_end, baseline_start, baseline_end, ...
        response_start, response_end, span, threshold_scale, sig_check, ...
        sig_alpha, consec_bins, mixed_smoothing)
    %% Abbreviations: fl = first latency, ll = last latency, pl = peak latency
    %% rm = response magnitude, bfr = background firing rate

    %% Create population table
    headers = [["chan_group", "string"]; ["channel", "string"]; ...
                   ["event", "string"]; ["significant", "double"]; ...
                   ["background_rate", "double"]; ["background_std", "double"]; ...
                   ["response_window_firing_rate", "double"]; ...
                   ["response_window_tot_spikes", "double"]; ...
                   ["threshold", "double"]; ["p_val", "double"]; ...
                   ["first_latency", "double"]; ["last_latency", "double"]; ...
                   ["duration", "double"]; ["peak_latency", "double"]; ...
                   ["peak_response", "double"]; ["corrected_peak", "double"]; ...
                   ["response_magnitude", "double"]; ["corrected_response_magnitude", "double"]; ...
                   ["tot_sig_events", "double"]; ["principal_event", "cell"]; ...
                   ["norm_response_magnitude", "double"]];
    rec_res = prealloc_table(headers, [0, size(headers, 1)]);

    assert(span > 0, "Cannot smooth if span is not set to 1 or greater")
    if mixed_smoothing
        assert(span >= 3, ...
            'span >= 3 if mixed smoothing is true. Span < 3 does not smooth.')
    end

    unique_ch_groups = fieldnames(rr_data);
    unique_events = unique(event_info.event_labels);
    tot_events = numel(unique_events);
    [~, tot_bins] = get_bins(window_start, window_end, bin_size);
    [response_edges, ~] = get_bins(response_start, response_end, bin_size);
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        tot_chans = numel(rr_data.(ch_group).chan_order);

        chan_s = 1;
        chan_e = tot_bins;
        for chan_i = 1:tot_chans
            chan = rr_data.(ch_group).chan_order{chan_i};
            %% Initalize variables to find principal event per channel
            chan_res = []; max_rm = 0; principal_event = cell(tot_events, 1);
            tot_sig_events = 0; norm_rm = nan(tot_events, 1);
            for event_i = 1:tot_events
                event = unique_events{event_i};
                event_indices = event_info.event_indices(strcmpi(event_info.event_labels, event), :);
                chan_rr = rr_data.(ch_group).relative_response(event_indices, chan_s:chan_e);

                %% Get current PSTH and smooth it based on span
                psth = calc_psth(chan_rr);
                psth = smooth(psth, span)'; % smooth returns column vector, but we need to maintain the row dimension
                baseline_psth = slice_rr(psth, bin_size, window_start, ...
                    window_end, baseline_start, baseline_end);
                response_psth = slice_rr(psth, bin_size, window_start, ...
                    window_end, response_start, response_end);

                %% Determine if psth is signficant
                [threshold, avg_bfr, bfr_std] = get_threshold(baseline_psth, threshold_scale);
                [is_sig, p_val] = check_significance(baseline_psth, ...
                    response_psth, threshold, consec_bins, sig_check, sig_alpha);

                if is_sig
                    %% Get first and last bin indices
                    supra_i = find(response_psth > threshold);
                    fl_i = supra_i(1); ll_i = supra_i(end);
                    [fl, ll, duration] = get_response_latencies(response_edges, fl_i, ll_i);
                    [sig_edges, ~] = get_bins(fl, ll, bin_size);
                    if mixed_smoothing
                        psth = calc_psth(chan_rr);
                        response_psth = slice_rr(psth, bin_size, window_start, ...
                            window_end, response_start, response_end);
                    end
                    sig_psth = response_psth(fl_i:ll_i);
                    [pl, peak, corrected_peak, rm, corrected_rm] = calc_response_rf(...
                        avg_bfr, sig_psth, duration, sig_edges);
                    %% Update normalized event findings
                    if rm > max_rm
                        max_rm = rm; principal_event = repmat({event}, [tot_events, 1]);
                    end
                    norm_rm(event_i) = rm;
                    tot_sig_events = tot_sig_events + 1;
                else
                    if mixed_smoothing
                        psth = calc_psth(chan_rr);
                        response_psth = slice_rr(psth, bin_size, window_start, ...
                            window_end, response_start, response_end);
                    end
                    % Puts NaN for non significant chans
                    fl = NaN; ll = NaN; duration = NaN; pl = NaN; peak = NaN;
                    corrected_peak = NaN; rm = NaN; corrected_rm = NaN;
                end
                %%Average response within the response window
                response_window_firing_rate = mean(response_psth);
                response_window_tot_spikes = sum(response_psth); 
                % Add rec results
                chan_res = [chan_res; {ch_group}, {chan}, {event}, is_sig, avg_bfr, ...
                    bfr_std, response_window_firing_rate, response_window_tot_spikes, ...
                    threshold, p_val, fl, ll, duration, pl, peak, corrected_peak, rm, corrected_rm];
            end
            %% Convert normalized events to cell arrays and append to channel results
            tot_sig_events = num2cell(tot_sig_events * ones(tot_events, 1));
            norm_rm = num2cell(norm_rm ./ max(norm_rm));
            chan_res = [chan_res, tot_sig_events, principal_event, norm_rm];
            %% Store results in table
            rec_res = vertcat_cell(rec_res, chan_res, headers(:, 1), "after");
            %% Update channel counter
            chan_s = chan_s + tot_bins;
            chan_e = chan_e + tot_bins;
        end
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

function [threshold, avg_bfr, bfr_std] = get_threshold(baseline_psth, threshold_scale)
    avg_bfr = mean(baseline_psth);
    bfr_std = std(baseline_psth);
    threshold = avg_bfr + (threshold_scale * bfr_std);
end