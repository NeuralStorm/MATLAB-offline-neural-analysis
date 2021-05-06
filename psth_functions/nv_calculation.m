function res = nv_calculation(psth_struct, event_info, window_start, window_end, ...
        baseline_start, baseline_end, bin_size, epsilon, norm_var_scaling)

    %% Create normalized variance table
    headers = [["chan_group", "string"]; ["channel", "string"]; ...
            ["event", "string"]; ["bfr_s", "double"]; ...
            ["bfr_var", "double"]; ["fano", "double"]; ["norm_var", "double"]];
    res = prealloc_table(headers, [0, size(headers, 1)]);

    [~, tot_bins] = get_bins(window_start, window_end, bin_size);
    [~, tot_baseline_bins] = get_bins(baseline_start, baseline_end, bin_size);
    duration = tot_baseline_bins * bin_size;

    unique_ch_groups = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        tot_chans = numel(psth_struct.(ch_group).chan_order);
        chan_s = 1;
        chan_e = tot_bins;
        for chan_i = 1:tot_chans
            chan = psth_struct.(ch_group).chan_order{chan_i};
            for event_i = 1:length(unique_events)
                event = unique_events{event_i};
                event_indices = event_info.event_indices(strcmpi(event_info.event_labels, event), :);
                chan_rr = psth_struct.(ch_group).relative_response(event_indices, chan_s:chan_e);
                baseline_response = slice_rr(chan_rr, bin_size, window_start, ...
                    window_end, baseline_start, baseline_end);

                %% Calculate NV for single bin size
                % bfr / duration because sum makes rr into 1 bin
                % Note: conversion with multiple bins would be either bfr/bin_size or (bfr*tot_bins)/bin_size
                bfr = sum(baseline_response, 2) / duration;
                avg_bfr = mean(bfr);
                bfr_var = var(bfr);
                norm_var = norm_var_scaling * (epsilon + bfr_var)/(norm_var_scaling * epsilon + avg_bfr);
                fano = avg_bfr / bfr_var;

                a = [{ch_group}, {chan}, {event}, avg_bfr, bfr_var, norm_var, fano];
                %% Store results in table
                res = vertcat_cell(res, a, headers(:, 1), "after");
            end
            %% Update channel counter
            chan_s = chan_s + tot_bins;
            chan_e = chan_e + tot_bins;
        end
    end
end