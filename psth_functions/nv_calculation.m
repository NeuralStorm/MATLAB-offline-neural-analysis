function nv_data = ...
    nv_calculation(labeled_data, psth_struct, pre_time, post_time, ...
        bin_size, epsilon, norm_var_scaling, separate_events, analysis_column_names)

    pre_time_bins = (length(-abs(pre_time): bin_size: 0)) - 1;
    post_time_bins = (length(0:bin_size:post_time)) - 1;

    nv_data = [];
    event_strings = psth_struct.all_events(:,1);

    all_events = psth_struct.all_events(:,2);
    event_end_indeces = [];
    for event = 1:length(all_events(:,1))
        event_end_indeces = [event_end_indeces, length(all_events{event})];
    end
    event_end_indeces = cumsum(event_end_indeces);
    unique_regions = fieldnames(labeled_data);
    for region = 1:length(unique_regions)
        current_region = unique_regions{region};
        region_neurons = labeled_data.(current_region)(:, 1);
        relative_response = psth_struct.(current_region).relative_response;
        if separate_events
            %% Handles events as different datasets
            last_trial_index = 1;
            for event = 1:length(event_strings)
                current_event = event_strings{event};
                pre_index = pre_time_bins;
                for neuron = 1:length(region_neurons)
                    current_neuron = region_neurons{neuron};
                    notes = labeled_data.(current_region)(strcmpi(labeled_data.(current_region)(:,1), ...
                        current_neuron), end);
                    current_pre = relative_response(last_trial_index:event_end_indeces(event), ...
                        (pre_index - pre_time_bins + 1 ):pre_index);
                    pre_index = pre_index + post_time_bins + pre_time_bins;
                    %% Calculate NV for each event for each trial for each neuron
                    bfr = sum(current_pre, 2) / (abs(pre_time) * 1000);
                    avg_bfr = mean(bfr);
                    bfr_var = var(bfr);
                    norm_var = norm_var_scaling * (epsilon + bfr_var)/(norm_var_scaling * epsilon + avg_bfr);
                    fano = avg_bfr / bfr_var;
                    nv_data = [nv_data; {current_event}, {current_region}, {current_neuron}, ...
                        {avg_bfr}, {bfr_var}, {norm_var}, {fano}, {notes}];
                end
                last_trial_index = event_end_indeces(event) + 1;
            end
        else
            %% Handles all trials from all events as one dataset
            pre_index = pre_time_bins;
            for neuron = 1:length(region_neurons)
                current_neuron = region_neurons{neuron};
                notes = labeled_data.(current_region)(strcmpi(labeled_data.(current_region)(:,1), ...
                    current_neuron), end);
                %% Grabs all trials for given neuron
                neuron_pre_activity = relative_response(:, (pre_index - pre_time_bins + 1 ):pre_index);
                %% Calculate NV for each trial for each neuron
                bfr = sum(neuron_pre_activity, 2) / (abs(pre_time) * 1000);
                avg_bfr = mean(bfr);
                bfr_var = var(bfr);
                norm_var = norm_var_scaling * (epsilon + bfr_var)/(norm_var_scaling * epsilon + avg_bfr);
                fano = avg_bfr / bfr_var;
                nv_data = [nv_data; {'all_events'}, {current_region}, {current_neuron}, ...
                    {avg_bfr}, {bfr_var}, {norm_var}, {fano}, {notes}];
                pre_index = pre_index + post_time_bins + pre_time_bins;
            end
        end
    end
    %% Convert results to table
    nv_data = cell2table(nv_data, 'VariableNames', analysis_column_names);
end