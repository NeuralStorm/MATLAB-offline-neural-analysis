function [] = graph_PSTH(save_path, filename, psth_struct, event_info, bin_size, ...
        window_start, window_end, baseline_start, baseline_end, response_start, ...
        response_end, sub_rows, sub_cols, plot_rf, rf_res, mixed_smoothing, span)

    unique_ch_groups = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    tot_events = numel(unique_events);

    %% Offsetting start and end by half a bin so that edges on histogram are plotted accurately
    edge_s = window_start - (bin_size/2);
    edge_e = window_end + (bin_size/2);
    [event_window, ~] = get_bins(edge_s, edge_e, bin_size);
    event_window(1) = [];
    event_window(end) = [];
    tot_bins = numel(event_window);

    parfor reg_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{reg_i};
        chan_order = psth_struct.(ch_group).chan_order;
        for event_i = 1:tot_events
            main_plot = figure;
            event = unique_events{event_i};
            event_indices = event_info.event_indices(strcmpi(event_info.event_labels, event), :);

            %% Determine y lim of event psth
            event_rr = psth_struct.(ch_group).relative_response(event_indices, :);
            event_psth = calc_psth(event_rr);

            if plot_rf && ~mixed_smoothing && span >= 3
                % Smooth psth if ploting rf and there was not mixed smoothing
                % No smoothing occurs if span is less than 3
                event_psth = smooth(event_psth, span)';
            end

            event_max = 1.1 * max(event_psth) + eps;
            event_min = 1.1 * min(event_psth);
            y_lim = [event_min, event_max];

            %% Plot all channels composing PSTH
            chan_s = 1;
            chan_e = tot_bins;
            for chan_i = 1:numel(chan_order)
                chan = chan_order{chan_i};
                chan_rr = psth_struct.(ch_group).relative_response(event_indices, chan_s:chan_e);
                psth = calc_psth(chan_rr);

                if plot_rf && ~mixed_smoothing && span >= 3
                    % Smooth psth if ploting rf and there was not mixed smoothing
                    % No smoothing occurs if span is less than 3
                    psth = smooth(psth, span)';
                end

                hold on
                scrollsubplot(sub_rows, sub_cols, chan_i)
                %% plot histogram
                chan_handle = bar(event_window, psth,'BarWidth', 1);
                set(chan_handle, 'EdgeAlpha', 0);
                ylim(y_lim);
                %% Plot lines to mark windows of interest
                line([baseline_start baseline_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([baseline_end baseline_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([response_start response_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([response_end response_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                xtickformat('%.2f')
                xlabel('Time');
                ylabel('Magnitude');
                title(chan);
                if plot_rf
                    %% Get rf measures for chan_group, event, and channel
                    threshold = rf_res.threshold(strcmpi(rf_res.chan_group, ch_group) ...
                        & strcmpi(rf_res.event, event) & strcmpi(rf_res.channel, chan));
                    fbl = rf_res.first_latency(strcmpi(rf_res.chan_group, ch_group) ...
                        & strcmpi(rf_res.event, event) & strcmpi(rf_res.channel, chan));
                    lbl = rf_res.last_latency(strcmpi(rf_res.chan_group, ch_group) ...
                        & strcmpi(rf_res.event, event) & strcmpi(rf_res.channel, chan));
                    %% Plot measures over chan psth
                    plot_recfield(main_plot, event_window, psth, fbl, lbl, threshold, bin_size, window_start)
                end
                hold off
                %% Update chan counter
                chan_s = chan_s + tot_bins;
                chan_e = chan_e + tot_bins;
            end
            %% Save figure
            fig_filename = [filename, '_', ch_group, '_', event, '.fig'];
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
            savefig(gcf, fullfile(save_path, fig_filename));
            close gcf
        end
    end
end