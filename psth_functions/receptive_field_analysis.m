function [sig_neurons, non_sig_neurons] = receptive_field_analysis(...
        selected_data, baseline_struct, response_struct, bin_size, ...
        post_start, span, threshold_scale, sig_check, sig_alpha, ...
        consec_bins, unsmoothed_recfield_metrics, column_names)
    %% Abbreviations: fl = first latency, ll = last latency, pl = peak latency
    %% rm = response magnitude, bfr = background firing rate

    event_strings = baseline_struct.all_events(:,1)';
    sig_neurons = [];
    non_sig_neurons = [];
    region_names = fieldnames(selected_data);
    for region = 1:length(region_names)
        current_region = region_names{region};
        region_table = selected_data.(current_region);
        for event = 1:length(event_strings(1,:))
            current_event = event_strings{event};
            for neuron = 1:height(region_table)
                neuron_name = region_table.sig_channels{neuron};
                user_channels = region_table.user_channels(strcmpi(region_table.sig_channels, neuron_name));
                notes = region_table.recording_notes(strcmpi(region_table.sig_channels, neuron_name));
                if strcmpi(class(notes), 'double') && isnan(notes)
                    notes = 'n/a';
                end
                %% Get current PSTH and smooth it based on span
                baseline_psth = baseline_struct.(current_region).(current_event).(neuron_name).psth;
                response_psth = response_struct.(current_region).(current_event).(neuron_name).psth;
                baseline_psth = smooth(baseline_psth, span);
                response_psth = smooth(response_psth, span);

                %% Determine if psth is signficant
                [threshold, avg_bfr, bfr_std] = get_threshold(baseline_psth, threshold_scale);
                [is_sig, p_val] = check_significance(baseline_psth, ...
                    response_psth, threshold, consec_bins, sig_check, sig_alpha);

                if is_sig
                    %% Finds results of the receptive field analysis
                    if unsmoothed_recfield_metrics
                        baseline_psth = baseline_struct.(current_region).(current_event).(neuron_name).psth;
                        response_psth = response_struct.(current_region).(current_event).(neuron_name).psth;
                        %! smoothed threshold is lower, cannot use unsmoothed threshold since response may not be above
                        [~, avg_bfr, bfr_std] = get_threshold(baseline_psth, threshold_scale);
                    end
                    [fl, ll, duration, pl, peak, corrected_peak, rm, ...
                        corrected_rm] = get_response_metrics(avg_bfr, ...
                        response_psth, threshold, bin_size, post_start);

                    % Organizes data results into cell array
                    sig_neurons = [sig_neurons; {current_region}, {neuron_name}, ...
                        {user_channels}, {current_event}, {1}, {avg_bfr}, ...
                        {bfr_std}, {threshold}, {p_val}, {fl}, {ll}, ...
                        {duration}, {pl}, {peak}, {corrected_peak}, ...
                        {rm}, {corrected_rm}, {NaN}, {strings}, {NaN}, {notes}];
                else
                    % Puts NaN for non significant neurons
                    non_sig_neurons = [non_sig_neurons; {current_region}, ...
                        {neuron_name}, {user_channels}, {current_event}, {0}, ...
                        {avg_bfr}, {bfr_std}, {threshold}, {p_val}, {NaN}, ...
                        {NaN}, {NaN}, {NaN}, {NaN}, {NaN}, {NaN}, {NaN}, ...
                        {NaN}, {strings}, {NaN}, {notes}];
                end
            end
        end
    end

    %% Convert cell arrays to tables for future data handeling
    if ~isempty(sig_neurons)
        sig_neurons = cell2table(sig_neurons, 'VariableNames', column_names);
        %% Normalize response magnitude and find primary event for each neuron
        % Normalizes response magnitude on response magnitude, not response magnitude - background rate
        for neuron = 1:length(sig_neurons.sig_channels)
            neuron_name = sig_neurons.sig_channels{neuron};
            if ~isempty(sig_neurons.sig_channels(strcmpi(sig_neurons.sig_channels, neuron_name)))
                    sig_events = sig_neurons.event(strcmpi(sig_neurons.sig_channels, neuron_name));
                    sig_magnitudes = sig_neurons.response_magnitude(strcmpi(sig_neurons.sig_channels, neuron_name));
                    [max_magnitude, max_index] = max(sig_magnitudes);
                    norm_magnitude = sig_magnitudes ./ max_magnitude;
                    principal_event = sig_events(max_index);
                    total_sig_events = length(sig_magnitudes);
                    sig_neurons.total_sig_events(strcmpi(sig_neurons.sig_channels, neuron_name)) = ...
                        total_sig_events;
                    sig_neurons.principal_event(strcmpi(sig_neurons.sig_channels, neuron_name)) = ...
                        {principal_event};
                    sig_neurons.norm_magnitude(strcmpi(sig_neurons.sig_channels, neuron_name)) = ...
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
        bfr, response_psth, threshold, bin_size, post_start)
    %% Abbreviations: fl = first latency, ll = last latency, pl = peak latency
    %% rm = response magnitude
    %% Finds results of the receptive field analysis
    suprathreshold_i = find(response_psth > threshold);
    above_threshold = response_psth(suprathreshold_i);
    fl = ((suprathreshold_i(1)) * bin_size) + post_start - (bin_size / 2);
    ll = ((suprathreshold_i(end)) * bin_size) + post_start - (bin_size / 2);
    peak = max(above_threshold);
    peak_index = find(peak == response_psth);
    pl = (peak_index(1) * bin_size) + post_start - (bin_size / 2);
    corrected_peak = peak - bfr;
    rm = sum(response_psth(suprathreshold_i(1):suprathreshold_i(end)));
    corrected_rm = rm - bfr;
    duration = ll - fl;
end