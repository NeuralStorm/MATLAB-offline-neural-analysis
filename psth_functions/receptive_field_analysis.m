function [sig_neurons, non_sig_neurons] = receptive_field_analysis(labeled_data, ...
        baseline_window, response_window, bin_size, post_start, threshold_scale, sig_check, sig_bins, span, analysis_column_names)

    event_strings = baseline_window.all_events(:,1)';
    sig_neurons = [];
    non_sig_neurons = [];
    region_names = fieldnames(labeled_data);
    for region = 1:length(region_names)
        current_region = region_names{region};
        region_table = labeled_data.(current_region);
        for event = 1:length(event_strings(1,:))
            current_event = event_strings{event};
            for neuron = 1:height(region_table)
                neuron_name = region_table.sig_channels{neuron};
                user_channels = region_table.user_channels(strcmpi(region_table.sig_channels, neuron_name));
                notes = region_table.recording_notes(strcmpi(region_table.sig_channels, neuron_name));
                baseline_psth = baseline_window.(current_region).(current_event).(neuron_name).psth;
                response_psth = response_window.(current_region).(current_event).(neuron_name).psth;
                %% Deal with pre window first
                  [smoothed_threshold, background_rate, background_std] = ...
                      pre_time_anlysis(baseline_psth, span, threshold_scale);

                %% Determine if given neuron has a significant response
                 [sig_response] = sig_response_check(baseline_psth, response_psth, ...
                    smoothed_threshold, span, sig_bins, sig_check);

                if sig_response
                    %% Finds results of the receptive field analysis
                     [first_latency, last_latency, duration, peak_latency, peak, corrected_peak,...
                         response_magnitude, corrected_response_magnitude] = ...
                         post_time_analysis(background_rate, response_psth, smoothed_threshold, bin_size, post_start);

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
            end
        end
    end

    %% Convert cell arrays to tables for future data handeling
    % They are in try blocks in case there are only sig or non sig neurons
    if ~isempty(sig_neurons)
        sig_neurons = cell2table(sig_neurons, 'VariableNames', analysis_column_names);
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
        non_sig_neurons = cell2table(non_sig_neurons, 'VariableNames', analysis_column_names);
    end
end