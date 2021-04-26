function [] = graph_PSTH(save_path, psth_struct, event_info, bin_size, ...
        window_start, window_end, baseline_start, baseline_end, response_start, ...
        response_end, sub_rows, sub_cols, plot_rf, rf_res)

    %TODO add back in smoothing of psth

    unique_regions = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    tot_events = numel(unique_events);

    %% Offsetting start and end by half a bin so that edges on histogram are plotted accurately
    edge_s = window_start - (bin_size/2);
    edge_e = window_end + (bin_size/2);
    [event_window, ~] = get_bins(edge_s, edge_e, bin_size);
    event_window(1) = [];
    event_window(end) = [];
    tot_bins = numel(event_window);

    for reg_i = 1:length(unique_regions)
        region = unique_regions{reg_i};
        chan_order = psth_struct.(region).label_order;
        for event_i = 1:tot_events
            % main_plot = figure('visible', 'off');
            main_plot = figure;
            event = unique_events{event_i};
            event_indices = event_info.event_indices(strcmpi(event_info.event_labels, event), :);

            %% Determine y lim of event psth
            event_rr = psth_struct.(region).relative_response(event_indices, :);
            event_psth = calc_psth(event_rr);
            event_max = 1.1 * max(event_psth) + eps;
            event_min = 1.1 * min(event_psth);
            y_lim = [event_min, event_max];

            %% Plot all channels composing PSTH
            chan_s = 1;
            chan_e = tot_bins;
            for chan_i = 1:numel(chan_order)
                chan = chan_order{chan_i};
                chan_rr = psth_struct.(region).relative_response(event_indices, chan_s:chan_e);
                psth = calc_psth(chan_rr);
                hold on
                scrollsubplot(sub_rows, sub_cols, chan_i)
                chan_handle = bar(event_window, psth,'BarWidth', 1);
                set(chan_handle, 'EdgeAlpha', 0);
                ylim(y_lim);
                line([baseline_start baseline_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([baseline_end baseline_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([response_start response_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([response_end response_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                xtickformat('%.2f')
                xlabel('Time');
                ylabel('Magnitude');
                title(chan);
                if plot_rf
                    %% Get rf measures for region, event, and channel
                    threshold = rf_res.threshold(strcmpi(rf_res.region, region) ...
                        & strcmpi(rf_res.event, event) & strcmpi(rf_res.channel, chan));
                    fbl = rf_res.first_latency(strcmpi(rf_res.region, region) ...
                        & strcmpi(rf_res.event, event) & strcmpi(rf_res.channel, chan));
                    lbl = rf_res.last_latency(strcmpi(rf_res.region, region) ...
                        & strcmpi(rf_res.event, event) & strcmpi(rf_res.channel, chan));
                    plot_recfield(main_plot, event_window, psth, fbl, lbl, threshold, bin_size, window_start)
                end
                hold off
                %% Update chan counter
                chan_s = chan_s + tot_bins;
                chan_e = chan_e + tot_bins;
            end
            %TODO add recording session to filename
            filename = [region, '_', event, '.fig'];
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
            savefig(gcf, fullfile(save_path, filename));
        end
    end
end