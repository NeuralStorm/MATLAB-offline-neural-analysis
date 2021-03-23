function [psth_struct] = reformat_mnts(label_log, component_results, tot_bins)
    psth_struct = struct;
    unique_regions = unique(label_log.label);
    %% Convert weighted mnts into relative response
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        region_mnts = component_results.(region).weighted_mnts;
        [tot_rows, tot_components] = size(region_mnts);
        tot_trials = tot_rows / tot_bins;
        relative_response = mnts_to_psth(region_mnts, tot_trials, tot_components, tot_bins);
        psth_struct.(region).relative_response = relative_response;
        psth_struct.(region).label_order = component_results.(region).label_order;
        psth_struct.(region).chan_order = component_results.(region).chan_order;
    end
end