function [relative_response, labels] = mnts_to_psth(mnts, tot_trials, tot_cols, tot_bins, label_modifier)
    %% MNTS = multineuron timeseries is the data format used to run PCA and ICA
    % MNTS: (T * B) X N (or ovservation X features)
    % See Laubach et al. 1999 Fig 3. for visualization and description
    relative_response = nan(tot_trials, tot_cols);
    labels = cell(tot_cols, 1);
    for bin_index = 1:tot_cols
        bin_start = (tot_bins * bin_index - tot_bins + 1);
        bin_end = tot_bins * bin_index;
        for trial = 1:tot_trials
            start_index = (tot_bins * trial - tot_bins + 1);
            end_index = tot_bins * trial;
            relative_response(trial, bin_start:bin_end) = mnts(start_index:end_index, bin_index);
        end
        labels{bin_index} = [label_modifier, '_', num2str(bin_index)];
    end
end