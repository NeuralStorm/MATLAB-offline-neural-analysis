function [sig_neurons, non_sig_neurons] = receptive_field_analysis(...
        selected_data, baseline_window, response_window, bin_size, ...
        post_start, threshold_scale, sig_check, sig_bins, span, column_names)

    %! Move to config when done
    cluster_analysis = false;
    bin_gap = 3;

    event_strings = baseline_window.all_events(:,1)';
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
                baseline_psth = baseline_window.(current_region).(current_event).(neuron_name).psth;
                response_psth = response_window.(current_region).(current_event).(neuron_name).psth;
                %% Deal with pre window first
                  [smoothed_threshold, background_rate, background_std] = ...
                      pre_time_anlysis(baseline_psth, span, threshold_scale);

                %% Determine if given neuron has a significant response
                 [sig_response] = sig_response_check(baseline_psth, response_psth, ...
                    smoothed_threshold, span, sig_bins, sig_check);

                if ~cluster_analysis
                    if sig_response
                        %% Finds results of the receptive field analysis
                        [first_latency, last_latency, duration, peak_latency, peak, corrected_peak,...
                            response_magnitude, corrected_response_magnitude] = ...
                            post_time_analysis(background_rate, response_psth, smoothed_threshold, bin_size, post_start, span);

                        % Organizes data results into cell array
                        sig_neurons = [sig_neurons; {current_region}, {neuron_name}, {user_channels}, {current_event}, ...
                            {1}, {background_rate}, {background_std}, {smoothed_threshold}, {first_latency}, ...
                            {last_latency}, {duration}, {peak_latency}, {peak}, {corrected_peak}, ...
                            {response_magnitude}, {corrected_response_magnitude}, {NaN}, {strings}, {NaN}, {notes}];
                    else
                        % Puts NaN for non significant neurons
                        non_sig_neurons = [non_sig_neurons; {current_region}, {neuron_name}, {user_channels}, {current_event}, {0}, ...
                            {background_rate}, {background_std}, {smoothed_threshold}, {NaN}, {NaN}, {NaN}, {NaN}, {NaN}, ...
                            {NaN}, {NaN}, {NaN}, {NaN}, {strings}, {NaN}, {notes}];
                    end
                else
                    smoothed_response = smooth(post_psth, span);
                    smooth_above_threshold_indeces = find(smoothed_response > smoothed_threshold);
                    [~, bin_indeces] = is_consecutive(smooth_above_threshold_indeces, sig_bins);
                    clusters = [];
                    for bin_i = 2:length(bin_indeces)
                        index_gap = bin_indeces(bin_i) - bin_indeces(bin_i - 1);
                        if index_gap == 1
                            %TODO add indeces to cluster set
                        elseif index_gap > bin_gap
                            %TODO create new cluster
                        elseif index_gap < bin_gap
                            %TODO determine case
                        end
                    end
                end
            end
        end
    end

    %% Convert cell arrays to tables for future data handeling
    % They are in try blocks in case there are only sig or non sig neurons
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

function [sig_response] = sig_response_check(pre_psth,post_psth,smoothed_threshold,span,sig_bins,sig_check)
    %% Determines significant response based on settings
    smoothed_response = smooth(post_psth, span);
    %% Determine if given neuron has a significant response 
    sig_response = false;
    reject_null = false;
    smooth_above_threshold_indeces = find(smoothed_response > smoothed_threshold);
    %% Determines if there was a significant response
    %! Check to see if consecutive bin check is with smoothed or non smoothed post time
    [consecutive, ~] = is_consecutive(smooth_above_threshold_indeces, sig_bins);
    if consecutive
        if sig_check == 1
            % Unpaired ttest on pre and post windows
            reject_null = ttest2(pre_psth, post_psth);
        elseif sig_check == 2
            % ks test on pre and post windows
            reject_null = kstest2(pre_psth, post_psth);
        elseif sig_check ~= 0
            error('Invalid sig check. sig_check can be 0, 1 or 2, please see main documentation for more details');
        end
        % If the null hypothesis is rejected, then there is a significant response
        if isnan(reject_null)
            reject_null = false;
        end
        if reject_null || sig_check == 0
            sig_response = true;
        end
    end
end

function [consecutive, bin_indeces] = is_consecutive(above_threshold_indeces, sig_bins)
    %% Checks for consecutive bins
    consecutive_bins = 0;
    consecutive = false;
    bin_indeces = [];
    if length(above_threshold_indeces) >= sig_bins
        difference = diff(above_threshold_indeces);
        for i = 1:length(difference)
            if difference(i) == 1
                consecutive_bins = consecutive_bins + 1;
                bin_indeces = [bin_indeces; above_threshold_indeces(i)];
                if consecutive_bins >= sig_bins
                    consecutive = true;
                end
            else
                consecutive_bins = 0;
                bin_indeces = [];
            end
        end
    end
end

function [smoothed_threshold,background_rate,background_std] = pre_time_anlysis(pre_psth,span,threshold_scale)
    %% Deal with pre window first
    smoothed_pre_window = smooth(pre_psth, span);
    smoothed_avg_background = mean(smoothed_pre_window);
    smoothed_std_background = std(smoothed_pre_window);
    smoothed_threshold = smoothed_avg_background + (threshold_scale * smoothed_std_background);
    background_rate = mean(pre_psth);
    background_std = std(pre_psth);
end

function [fl, ll, duration, pl, peak, corrected_peak, rm, corrected_rm] = post_time_analysis(...
    background_rate, post_response, smoothed_threshold, bin_size, post_start, span)
    %% Abbreviations: fl = first latency, ll = last latency, pl = peak latency
    %% rm = response magnitude
    %% Finds results of the receptive field analysis
    above_threshold_indeces = find(post_response > smoothed_threshold);
    above_threshold = post_response(above_threshold_indeces);
    peak = max(above_threshold);
    peak_index = find(peak == post_response);
    pl = (peak_index(1) * bin_size) + post_start;
    corrected_peak = peak - background_rate;
    rm = sum(...
        post_response(above_threshold_indeces(1):above_threshold_indeces(end)));
    corrected_rm = rm - background_rate;
    smoothed_response = smooth(post_response, span);
    above_threshold_indeces = find(smoothed_response > smoothed_threshold);
    fl = ((above_threshold_indeces(1)) * bin_size) + post_start;
    ll = ((above_threshold_indeces(end)) * bin_size) + post_start;
    duration = ll - fl;
end