function [psth_struct, baseline_struct, response_struct] = reformat_mnts(label_log, component_struct, bin_size, ...
        window_start, window_end, baseline_start, baseline_end, response_start, response_end)

    psth_struct = struct;
    all_events = component_struct.all_events;
    psth_struct.all_events = all_events;

    unique_regions = fieldnames(label_log);
    tot_bins = length(-abs(window_start):bin_size:window_end) - 1;
    %% Convert weighted mnts into relative response
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        region_labels = label_log.(region).sig_channels;
        region_mnts = component_struct.(region).weighted_mnts;
        [tot_rows, tot_components] = size(region_mnts);
        tot_trials = tot_rows / tot_bins;
        relative_response = mnts_to_psth(region_mnts, tot_trials, tot_components, tot_bins);
        psth_struct.(region) = split_relative_response(relative_response, region_labels, ...
            all_events, tot_bins);
        psth_struct.(region).relative_response = relative_response;
    end

    %% Create the analysis windows for PSTH analysis
    [baseline_struct, response_struct] = create_analysis_windows(label_log, psth_struct, ...
        window_start, baseline_start, baseline_end, window_end, response_start, response_end, bin_size);

end