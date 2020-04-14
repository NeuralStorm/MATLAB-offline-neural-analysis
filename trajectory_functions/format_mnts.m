function [mnts_struct, event_ts, selected_data, label_log] = format_mnts(...
    event_ts, selected_data, bin_size, pre_time, post_time, wanted_events, ...
    trial_range, trial_lower_bound)

    mnts_struct = struct;
    event_window = -(abs(pre_time)):bin_size:(abs(post_time));
    tot_bins = length(event_window) - 1;

    %% Organize and group timestamps
    [~, all_events, event_ts] = organize_events(event_ts, ...
        trial_lower_bound, trial_range, wanted_events);
    mnts_struct.all_events = all_events;

    %% Organize event_ts to be in chronological order by event label
    event_ts = sortrows(event_ts);
    tot_trials = length(event_ts(:, 1));

    unique_regions = fieldnames(selected_data);
    label_log = struct;
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        region_neurons = [selected_data.(region).sig_channels, ...
            selected_data.(region).channel_data];
        [tot_region_neurons, ~] = size(region_neurons);
        mnts = nan((tot_bins * tot_trials), tot_region_neurons);
        for neuron_index = 1:tot_region_neurons
            neuron_ts = region_neurons{neuron_index, 2};
            neuron_response = nan((tot_bins * tot_trials), 1);
            trial_start = 1;
            trial_end = tot_bins;
            for trial_index = 1:tot_trials
                trial_ts = event_ts(trial_index, 2);
                offset_ts = neuron_ts - trial_ts * ones(size(neuron_ts));
                [offset_response, ~] = histcounts(offset_ts, event_window);
                neuron_response(trial_start:trial_end) = offset_response;
                trial_start = trial_start + tot_bins;
                trial_end = trial_end + tot_bins;
            end
            mnts(:, neuron_index) = neuron_response;
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