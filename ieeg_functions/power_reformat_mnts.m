function [psth_struct, baseline_struct, response_struct] = power_reformat_mnts(label_log, component_results, ...
        bin_size, window_start, window_end, baseline_start, baseline_end, ...
        response_start, response_end, window_shift_time)

    psth_struct = struct;
    all_events = component_results.all_events;
    psth_struct.all_events = all_events;

    unique_regions = fieldnames(label_log);
    tot_bins = length(-abs(window_start):bin_size:window_end) - 1;
    %% Convert weighted mnts into relative response
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        region_labels = label_log.(region).sig_channels;
        region_mnts = component_results.(region).weighted_mnts;
        [tot_rows, tot_components] = size(region_mnts);
        tot_trials = tot_rows / tot_bins;
        relative_response = mnts_to_psth(region_mnts, tot_trials, tot_components, tot_bins);
        psth_struct.(region) = split_relative_response(relative_response, region_labels, ...
            all_events(1, :), tot_bins);
        psth_struct.(region).relative_response = relative_response;


        gamble_relative = relative_response(all_events{2,2}, :);
        [tot_gambles, ~] = size(gamble_relative);
        event_struct = split_relative_response(gamble_relative, region_labels, ...
            [{'event_2'}, {ones(tot_gambles, 1)}], tot_bins);
        psth_struct.(region).event_2 = event_struct.event_2;

        safe_relative = relative_response(all_events{3,2}, :);
        [tot_safe, ~] = size(safe_relative);
        event_struct = split_relative_response(safe_relative, region_labels, ...
            [{'event_3'}, {ones(tot_safe, 1)}], tot_bins);
        psth_struct.(region).event_3 = event_struct.event_3;
        relative_response = [relative_response; gamble_relative; safe_relative];
        psth_struct.(region).relative_response = relative_response;
    end

    %% Create the analysis windows for PSTH analysis
    [baseline_struct, response_struct] = create_analysis_windows(label_log, psth_struct, ...
    window_start, baseline_start, baseline_end, window_end, response_start, response_end, bin_size, window_shift_time);
end