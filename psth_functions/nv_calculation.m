function nv_data = nv_calculation(selected_data, baseline_window, pre_start, pre_end, ...
        bin_size, epsilon, norm_var_scaling, separate_events, analysis_column_names)

    tot_bins = length(-abs(pre_start):bin_size:-abs(pre_end)) - 1;
    tot_time = abs(abs(pre_start) - abs(pre_end));

    nv_data = [];
    event_strings = baseline_window.all_events(:,1);

    unique_regions = fieldnames(selected_data);
    for region = 1:length(unique_regions)
        current_region = unique_regions{region};
        region_table = selected_data.(current_region);
        if separate_events
            %% Handles events as different datasets
            for event = 1:length(event_strings)
                current_event = event_strings{event};
                for neuron = 1:height(region_table)
                    current_neuron = region_table.sig_channels{neuron};
                    user_channels = region_table.user_channels(strcmpi(region_table.sig_channels, current_neuron));
                    notes = region_table.recording_notes(strcmpi(region_table.sig_channels, current_neuron));
                    baseline_response = baseline_window.(current_region).(current_event).(current_neuron).relative_response;
                    %% Calculate NV for each event for each trial for each neuron
                    bfr = sum(baseline_response, 2) / (tot_time);
                    avg_bfr = mean(bfr);
                    bfr_var = var(bfr);
                    norm_var = norm_var_scaling * (epsilon + bfr_var)/(norm_var_scaling * epsilon + avg_bfr);
                    fano = avg_bfr / bfr_var;
                    nv_data = [nv_data; {current_event}, {current_region}, {current_neuron}, {user_channels}, ...
                        {avg_bfr}, {bfr_var}, {norm_var}, {fano}, {notes}];
                end
            end
        else
            %% Handles all trials from all events as one dataset
            unit_index = tot_bins;
            for neuron = 1:height(region_table)
                current_neuron = region_table.sig_channels{neuron};
                user_channels = region_table.user_channels(strcmpi(region_table.sig_channels, current_neuron));
                notes = region_table.recording_notes(strcmpi(region_table.sig_channels, current_neuron));
                %% Grabs all trials for given neuron
                baseline_response = baseline_window.(current_region).relative_response(:, (unit_index - tot_bins + 1):unit_index);
                %% Calculate NV for each trial for each neuron
                bfr = sum(baseline_response, 2) / (tot_time);
                avg_bfr = mean(bfr);
                bfr_var = var(bfr);
                norm_var = norm_var_scaling * (epsilon + bfr_var)/(norm_var_scaling * epsilon + avg_bfr);
                fano = avg_bfr / bfr_var;
                nv_data = [nv_data; {'all_events'}, {current_region}, {current_neuron}, {user_channels}, ...
                    {avg_bfr}, {bfr_var}, {norm_var}, {fano}, {notes}];
                unit_index = unit_index + tot_bins;
            end
        end
    end
    %% Convert results to table
    nv_data = cell2table(nv_data, 'VariableNames', analysis_column_names);
end