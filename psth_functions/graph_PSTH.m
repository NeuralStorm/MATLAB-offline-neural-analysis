function [] = graph_PSTH(save_path, psth_struct, label_log, sig_response, ...
        non_sig_response, config, orig_filename)

    bin_size = config.bin_size; window_start = config.window_start; 
    window_end = config.window_end; baseline_start = config.baseline_start;
    baseline_end = config.baseline_end; response_start = config.response_start; 
    response_end = config.response_end; rf_analysis = config.rf_analysis;
    make_region_subplot = config.make_region_subplot; sub_rows = config.sub_rows;
    make_unit_plot = config.make_unit_plot; sub_cols = config.sub_columns;
    if rf_analysis
        span = config.span; mixed_smoothing = config.mixed_smoothing;
        cluster_flag = config.cluster_flag; cluster_analysis = config.cluster_analysis;
    else
        span = NaN; mixed_smoothing = NaN;
        cluster_flag = 0; cluster_analysis = 0;
    end
    check_time(window_start, baseline_start, baseline_end, window_end, response_start, response_end, bin_size)

    event_strings = psth_struct.all_events(:,1)';
    event_window = window_start:bin_size:window_end;
    event_window(1) = [];

    region_names = fieldnames(label_log);

    parfor region = 1:length(region_names)
        current_region = region_names{region};
        region_neurons = label_log.(current_region).sig_channels;
        total_region_neurons = length(region_neurons);
        % Creates the region directory if it does not already exist
        region_path = [save_path, '/', current_region];
        if ~exist(region_path, 'dir')
            mkdir(save_path, current_region);
        end

        for event = 1:length(event_strings(1,:))
            current_event = event_strings{event};
            event_psth = psth_struct.(current_region).(current_event).psth;

            event_max = 1.1 * max(event_psth) + eps;
            if min(event_psth) >= 0
                event_min = 0;
            else
                event_min = 1.1 * min(event_psth);
            end

            %% Create the event directories
            event_path = [region_path, '/', current_event, '/'];
            if ~exist(event_path, 'dir')
                mkdir(region_path, current_event);
            end
            if make_region_subplot
                region_figure = figure('visible', 'off');
            else
                region_figure = NaN;
            end

            %% Creating the PSTH graphs
            for neuron_iter = 1:total_region_neurons
                neuron = find(label_log.(current_region).user_channels == neuron_iter);
                psth_name = region_neurons{neuron};
                psth = psth_struct.(current_region).(current_event).(psth_name).psth;
                if rf_analysis && ~mixed_smoothing
                    %! Not the same smoothing as in receptive field since it is on entire psth
                    %! rec field is split between baseline and response so they have different edges near 0
                    psth = smooth(psth, span);
                end
                if make_unit_plot
                    unit_figure = plot_PSTH(psth, psth_name, current_event, event_window, ...
                        baseline_start, baseline_end, response_start, response_end);
                end
                if rf_analysis
                    threshold = NaN;
                    first_bin_latency = NaN;
                    last_bin_latency = NaN;
                    %% Plot first & last bin latency and threshold for significant neurons
                    % otherwise plots threshold on non significant neurons
                    if ~isempty(sig_response)
                        if cluster_analysis
                            first = [cluster_flag, '_cluster_first_latency'];
                            last = [cluster_flag, '_cluster_last_latency'];
                        else
                            first = 'first_latency';
                            last = 'last_latency';
                        end
                        region_sig_neurons = sig_response(strcmpi(sig_response.region, current_region), :);
                        if ~isempty(region_sig_neurons) && ~isempty(region_sig_neurons.sig_channels(strcmpi(region_sig_neurons.sig_channels, psth_name) & ...
                                strcmpi(region_sig_neurons.event, current_event)))
                            threshold = region_sig_neurons.threshold(strcmpi(region_sig_neurons.sig_channels, psth_name) & ...
                                strcmpi(region_sig_neurons.event, current_event));
                            first_bin_latency = region_sig_neurons.(first)(strcmpi(region_sig_neurons.sig_channels, psth_name) & ...
                                strcmpi(region_sig_neurons.event, current_event));
                            last_bin_latency = region_sig_neurons.(last)(strcmpi(region_sig_neurons.sig_channels, psth_name) & ...
                                strcmpi(region_sig_neurons.event, current_event));
                        end
                    end
                    if ~isempty(non_sig_response) && ~isempty(non_sig_response.sig_channels( ...
                                strcmpi(non_sig_response.sig_channels, psth_name) & strcmpi(non_sig_response.event, current_event) ...
                                & strcmpi(non_sig_response.region, current_region)))
                            %% Find threshold
                            threshold = non_sig_response.threshold(strcmpi(non_sig_response.sig_channels, psth_name) & ...
                                strcmpi(non_sig_response.event, current_event) & ...
                                strcmpi(non_sig_response.region, current_region));
                    end
                    %% Plots elements from rec field analysis
                    if make_unit_plot
                        plot_recfield(psth, first_bin_latency, last_bin_latency, threshold, ...
                            unit_figure, bin_size, window_start, event_window);
                    end
                    if make_region_subplot
                        figure(region_figure);
                        scrollsubplot(sub_rows, sub_cols, neuron_iter);
                        hold on
                        region_handle = bar(event_window, psth,'BarWidth', 1);
                        set(region_handle, 'EdgeAlpha', 0);
                        ylim([event_min event_max]);
                        
                        plot_recfield(psth, first_bin_latency, last_bin_latency, threshold, ...
                            region_figure, bin_size, window_start, event_window);
                        line([baseline_start baseline_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                        line([baseline_end baseline_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                        line([response_start response_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                        line([response_end response_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                        title(psth_name);
                        hold off
                    end
                end
                if make_region_subplot && ~rf_analysis
                    figure(region_figure);
                    scrollsubplot(sub_rows, sub_cols, neuron_iter);
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
                end
                if make_unit_plot
                    figure(unit_figure);
                    filename = [psth_name, '_', current_event, '.png'];
                    saveas(gcf, fullfile(event_path, filename));
                    filename = [psth_name, '_', current_event, '.fig'];
                    set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
                    savefig(gcf, fullfile(event_path, filename));
                end
            end
            if make_region_subplot
                figure(region_figure);
                filename = [orig_filename, '.fig'];
                set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
                savefig(gcf, fullfile(event_path, filename));
            end
            close all
        end
    end
end