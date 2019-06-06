function [sig_neurons, non_sig_neurons] = receptive_field_analysis(labeled_neurons, ...
        event_struct, bin_size, threshold_scale, sig_check, sig_bins, span, analysis_column_names)

    event_strings = event_struct.all_events(:,1)';
    sig_neurons = [];
    non_sig_neurons = [];
    region_names = fieldnames(labeled_neurons);
    for region = 1:length(region_names)
        current_region = region_names{region};
        region_neurons = labeled_neurons.(current_region)(:,1);

        for event = 1:length(event_strings(1,:))
            current_event = event_strings{event};
            norm_pre_window = event_struct.(current_region).(current_event).norm_pre_time_activity;
            norm_post_window = event_struct.(current_region).(current_event).norm_post_time_activity;
            for neuron = 1:length(region_neurons)
                neuron_name = region_neurons{neuron};
                notes = labeled_neurons.(current_region)(contains(labeled_neurons.(current_region)(:,1), ...
                    neuron_name), end);
                %% Deal with pre window first
                smoothed_pre_window = smooth(norm_pre_window(neuron, :), span);
                smoothed_avg_background = mean(smoothed_pre_window);
                smoothed_std_background = std(smoothed_pre_window);
                smoothed_threshold = smoothed_avg_background + (threshold_scale * smoothed_std_background);

                %% Post window analysis
                smoothed_response = smooth(norm_post_window(neuron, :), span);
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
                        reject_null = ttest2(norm_pre_window(neuron, :), norm_post_window(neuron, :));
                    elseif sig_check == 2
                        % ks test on pre and post windows
                        reject_null = kstest2(norm_pre_window(neuron, :), norm_post_window(neuron, :));
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
                %% Receptive field analysis if significant response
                % Finds first, last, and peak latency as well as the peak magnitude, 
                % response magnitude, background rate, and threshold
                background_rate = mean(norm_pre_window(neuron, :));
                background_std = std(norm_pre_window(neuron,:));
                if sig_response
                    %% Finds results of the receptive field analysis
                    response = norm_post_window(neuron, :);
                    above_threshold_indeces = find(response > smoothed_threshold);
                    above_threshold = response(above_threshold_indeces);
                    peak = max(above_threshold);
                    peak_index = find(peak == response);
                    peak_latency = peak_index(1) * bin_size;
                    corrected_peak = peak - background_rate;
                    response_magnitude = sum(...
                        response(above_threshold_indeces(1):above_threshold_indeces(end)));
                    corrected_response_magnitude = response_magnitude - background_rate;
                    first_latency = (above_threshold_indeces(1)) * bin_size;
                    last_latency = (above_threshold_indeces(end)) * bin_size;
                    duration = last_latency - first_latency;

                    % Organizes data results into cell array
                    sig_neurons = [sig_neurons; {current_region}, {neuron_name}, {current_event}, ...
                        {1}, {background_rate}, {background_std}, {smoothed_threshold}, {first_latency}, ...
                        {last_latency}, {duration}, {peak_latency}, {peak}, {corrected_peak}, ...
                        {response_magnitude}, {corrected_response_magnitude}, {NaN}, {strings}, {NaN}, {notes}];
                else
                    % Puts NaN for non significant neurons
                    non_sig_neurons = [non_sig_neurons; {current_region}, {neuron_name}, {current_event}, {0}, ...
                        {background_rate}, {background_std}, {smoothed_threshold}, {NaN}, {NaN}, {NaN}, {NaN}, {NaN}, ...
                        {NaN}, {NaN}, {NaN}, {NaN}, {strings}, {NaN}, {notes}];
                end
            end
        end
    end

    %% Convert cell arrays to tables for future data handeling
    % They are in try blocks in case there are only sig or non sig neurons
    if ~isempty(sig_neurons)
        sig_neurons = cell2table(sig_neurons, 'VariableNames', analysis_column_names);
        %% Normalize response magnitude and find primary event for each neuron
        % Normalizes response magnitude on response magnitude, not response magnitude - background rate  
        for neuron = 1:length(sig_neurons.channel)
            neuron_name = sig_neurons.channel{neuron};
            if ~isempty(sig_neurons.channel(strcmpi(sig_neurons.channel, neuron_name)))
                    sig_events = sig_neurons.event(strcmpi(sig_neurons.channel, neuron_name));
                    sig_magnitudes = sig_neurons.response_magnitude(strcmpi(sig_neurons.channel, neuron_name));
                    [max_magnitude, max_index] = max(sig_magnitudes);
                    norm_magnitude = sig_magnitudes ./ max_magnitude;
                    principal_event = sig_events(max_index);
                    total_sig_events = length(sig_magnitudes);
                    sig_neurons.total_sig_events(strcmpi(sig_neurons.channel, neuron_name)) = ...
                        total_sig_events;
                    sig_neurons.principal_event(strcmpi(sig_neurons.channel, neuron_name)) = ...
                        {principal_event};
                    sig_neurons.norm_magnitude(strcmpi(sig_neurons.channel, neuron_name)) = ...
                        norm_magnitude;
            end
        end
    end

    if ~isempty(non_sig_neurons)
        non_sig_neurons = cell2table(non_sig_neurons, 'VariableNames', analysis_column_names);
    end
end