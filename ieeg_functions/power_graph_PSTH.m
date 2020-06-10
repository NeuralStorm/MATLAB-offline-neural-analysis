function [] = power_graph_PSTH(save_path, psth_struct, label_log, config)
    %TODO add subplot title

    bin_size = config.bin_size; window_start = config.window_start;
    window_end = config.window_end; baseline_start = config.baseline_start;
    baseline_end = config.baseline_end; response_start = config.response_start;
    response_end = config.response_end;
    sub_rows = config.sub_rows;
    make_unit_plot = config.make_unit_plot; sub_cols = config.sub_columns;
    check_time(window_start, baseline_start, baseline_end, window_end, response_start, response_end, bin_size)

    event_strings = psth_struct.all_events(:,1)';
    event_window = window_start:bin_size:window_end;
    event_window(1) = [];
    region_names = fieldnames(label_log);
    parfor region = 1:length(region_names)
        current_region = region_names{region};
        region_neurons = label_log.(current_region).sig_channels;
        total_region_neurons = length(region_neurons);

        for event_i = 1:length(event_strings(1,:))
            event = event_strings{event_i};
            if strcmpi(event, 'event_1')
                event_type = 'all_trials';
            elseif strcmpi(event, 'event_2')
                event_type = 'gamble';
            elseif strcmpi(event, 'event_3')
                event_type = 'safebet';
            else
                error('Unexpected event: %s', event);
            end
            event_psth = psth_struct.(current_region).(event).psth;

            event_max = 1.1 * max(event_psth) + eps;
            if min(event_psth) >= 0
                event_min = 0;
            else
                event_min = 1.1 * min(event_psth);
            end

            region_figure = figure('visible', 'off');
            %% Creating the PSTH graphs
            for neuron = 1:total_region_neurons
                psth_name = region_neurons{neuron};
                psth = psth_struct.(current_region).(event).(psth_name).psth;
                if make_unit_plot
                    unit_figure = plot_PSTH(psth, psth_name, event, event_window, ...
                        baseline_start, baseline_end, response_start, response_end);
                end
                figure(region_figure);
                scrollsubplot(sub_rows, sub_cols, neuron);
                hold on
                region_handle = bar(event_window, psth,'BarWidth', 1);
                set(region_handle, 'EdgeAlpha', 0);
                ylim([event_min event_max]);
                line([baseline_start baseline_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([baseline_end baseline_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([response_start response_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                line([response_end response_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                title(psth_name);
                hold off
                if make_unit_plot
                    figure(unit_figure);
                    filename = [current_region, '_', event_type, '.png'];
                    saveas(gcf, fullfile(save_path, filename));
                    filename = [current_region, '_', event_type, '.fig'];
                    set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
                    savefig(gcf, fullfile(save_path, filename));
                end
            end
            figure(region_figure);
            filename = [current_region, '_', event_type, '.fig'];
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
            savefig(gcf, fullfile(save_path, filename));
            close all
        end
    end
end