function [labeled_ics, event_struct] = calc_ica(labeled_neurons, ...
        mnts_struct, pre_time, post_time, bin_size)
    %TODO add option to go straight from relative response to ica with no PCA middleman
    %TODO dont forget to z score raw input
    % TODO add check to make sure ica input has enough data
    event_struct = struct;
    event_struct.all_events = mnts_struct.all_events;
    event_window = -(abs(pre_time)):bin_size:(abs(post_time));
    tot_bins = length(event_window) - 1;
    labeled_ics = labeled_neurons;
    region_names = fieldnames(labeled_neurons);
    tot_regions = length(region_names);
    for region_index = 1:tot_regions
        region = region_names{region_index};
        % Multineuron timeseries is transposed to match expected dimensionality of runica from EEGLabs
        [tot_rows, tot_units] = size(mnts_struct.(region).mnts);
        tot_trials = tot_rows / tot_bins;

        if tot_units < 2
            labeled_ics = rmfield(labeled_ics, region);
            continue
        end


        ica_input = mnts_struct.(region).z_mnts';
        [tot_channels, ~] = size(ica_input);
        [ica_weights, ica_sphere] = runica(ica_input, 'verbose', 'off');
        %%TODO add flags to ica
        % pca flag -> # of pcs from 1 up to tot_channels - 1 -> check and make sure pc # doesnt exceed tot_channels - 1
        % [ica_weights, ica_sphere] = runica(ica_input, 'pca', (tot_channels - 1), 'verbose', 'off');
        % labeled_ics.(region)(end, :) = [];
        coeff = (ica_weights * ica_sphere)'; % Double transpose should properly line up data?
        weighted_mnts = ica_input' * coeff;
        [~, tot_cols] = size(weighted_mnts);

        [ica_relative_response, ic_names] = mnts_to_psth(weighted_mnts, tot_trials, tot_cols, tot_bins, 'ic');
        labeled_ics.(region)(:, 1) = ic_names;
        event_struct.(region) = split_relative_response(ica_relative_response, ic_names, ...
            mnts_struct.all_events, bin_size, pre_time, post_time);
        event_struct.(region).relative_response = ica_relative_response;
        event_struct.(region).psth = sum(ica_relative_response, 1) / tot_trials;
        event_struct.(region).mnts = weighted_mnts;
    end
end