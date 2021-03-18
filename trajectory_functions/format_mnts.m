function [mnts_struct, event_info, selected_data, label_log] = format_mnts(...
    event_info, selected_data, bin_size, window_start, window_end, include_events, ...
    trial_range)

    mnts_struct = struct;
    [bin_edges, tot_bins] = get_bins(window_start, window_end, bin_size);

    %% Filter events
    event_info = filter_events(event_info, include_events, trial_range);

    tot_trials = height(event_info);

    unique_regions = fieldnames(selected_data);
    label_log = struct;
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        region_neurons = [selected_data.(region).sig_channels, ...
            selected_data.(region).channel_data];
        [tot_neurons, ~] = size(region_neurons);
        mnts = nan((tot_bins * tot_trials), tot_neurons);

        for neuron_i = 1:tot_neurons
            spike_ts = region_neurons{neuron_i, 2};
            trial_s = 1;
            trial_e = tot_bins;
            for trial_i = 1:tot_trials
                trial_ts = event_info.event_ts(trial_i);
                %% Offsets spike times and then bin spikes within window
                offset_ts = spike_ts -trial_ts;
                [binned_response, ~] = histcounts(offset_ts, bin_edges);
                mnts(trial_s:trial_e, neuron_i) = binned_response';
                %% Update index counters
                trial_s = trial_s + tot_bins;
                trial_e = trial_e + tot_bins;
            end
        end

        %% Find responses with no spikes and removes them to prevent NAN when z scored
        [~, mnts_cols] = size(mnts);
        remove_units = [];
        for col = 1:mnts_cols
            unique_response = unique(mnts(:, col));
            if length(unique_response) == 1
                remove_units = [remove_units; col];
            end
        end
        selected_data.(region)(remove_units, :) = [];
        mnts(:, remove_units) = [];

        %% Take z score of mnts and store both in mnts struct
        z_mnts = zscore(mnts);
        mnts_struct.(region).mnts = mnts;
        mnts_struct.(region).z_mnts = z_mnts;

        %% Create label log
        region_table = selected_data.(region);
        region_log = region_table(:, ~strcmpi(region_table.Properties.VariableNames, 'channel_data'));
        label_log.(region) = region_log;
    end
end