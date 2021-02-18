function [rr] = create_relative_response(neuron_ts, event_ts, bin_edges)
    %% Input parameters
    % neuron_ts - column 1: unit label column 2: spike time cell array for unit label on same row
    % event_ts - list of trial timestamps
    % bin_edges: defined by window_start and window_end, stepped by bin_size
    %% Output
    % rr: relative response matrix
    %     dimension: Trials (rows) x Neurons * Bins (columns)

    tot_bins = numel(bin_edges) - 1;
    tot_trials = numel(event_ts);
    [tot_neurons, ~] = size(neuron_ts);
    rr = nan(tot_trials, (tot_neurons * tot_bins));
    for trial_i = 1:length(event_ts)
        %% Iterate through trial timestamps
        neuron_start = 1;
        neuron_end = tot_bins;
        trial_ts = event_ts(trial_i);
        for neuron_i = 1:tot_neurons
            %% Iterate through neurons
            spike_ts = neuron_ts{neuron_i, 2};
            %% Offsets spike times and then bin spikes within window
            offset_ts = spike_ts -trial_ts;
            [binned_response, ~] = histcounts(offset_ts, bin_edges);
            % Transpose taken to make binned_response row major instead of column major
            rr(trial_i, neuron_start:neuron_end) = binned_response';
            %% Update index counters
            neuron_start = neuron_start + tot_bins;
            neuron_end = neuron_end + tot_bins;
        end
    end
end