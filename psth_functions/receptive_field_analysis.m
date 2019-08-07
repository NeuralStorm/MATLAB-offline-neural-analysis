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
            pre_psth = event_struct.(current_region).(current_event).norm_pre_time_activity;
            post_psth = event_struct.(current_region).(current_event).norm_post_time_activity;
            for neuron = 1:length(region_neurons)
                neuron_name = region_neurons{neuron};
                notes = labeled_neurons.(current_region)(strcmpi(labeled_neurons.(current_region)(:,1), ...
                    neuron_name), end);
                %% Deal with pre window first
                  [smoothed_threshold,background_rate,background_std] = ...
                      pre_time_anlysis(pre_psth(neuron, :),span,threshold_scale);

                %% Determine if given neuron has a significant response
                 [sig_response] = sig_response_check(pre_psth(neuron, :), post_psth(neuron, :), ...
                    smoothed_threshold, span, sig_bins, sig_check);

                if sig_response
                    %% Finds results of the receptive field analysis
                     [first_latency, last_latency, duration, peak_latency, peak, corrected_peak,...
                         response_magnitude, corrected_response_magnitude] = ...
                         post_time_analysis(background_rate, post_psth(neuron,:), smoothed_threshold,bin_size);

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