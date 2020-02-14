function [] = graph_PSTH(save_path, psth_struct, labeled_data, sig_response, ...
        non_sig_response, config, orig_filename)

    bin_size = config.bin_size; pre_time = config.pre_time; 
    post_time = config.post_time; pre_start = config.pre_start;
    pre_end = config.pre_end; post_start = config.post_start; 
    post_end = config.post_end; rf_analysis = config.rf_analysis;
    make_region_subplot = config.make_region_subplot; sub_rows = config.sub_rows;
    make_unit_plot = config.make_unit_plot; sub_cols = config.sub_columns;

    check_time(pre_time, pre_start, pre_end, post_time, post_start, post_end, bin_size)

    event_strings = psth_struct.all_events(:,1)';
    event_window = -(abs(pre_time) - bin_size):bin_size:(abs(post_time));
    total_bins = length(event_window);

    region_names = fieldnames(labeled_data);
    parfor region = 1:length(region_names)
        current_region = region_names{region};
        region_neurons = labeled_data.(current_region).sig_channels;
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
            for neuron = 1:total_region_neurons
                psth = event_psth(((1:total_bins) + ((neuron-1) * total_bins)));
                psth_name = region_neurons{neuron};
                if make_unit_plot
                    unit_figure = plot_PSTH(psth, psth_name, current_event, event_window, ...
                        pre_start, pre_end, post_start, post_end);
                end
                if rf_analysis
                    threshold = NaN;
                    first_bin_latency = NaN;
                    last_bin_latency = NaN;
                    %% Plot first & last bin latency and threshold for significant neurons
                    % otherwise plots threshold on non significant neurons
                    if ~isempty(sig_response)
                        region_sig_neurons = sig_response(strcmpi(sig_response.region, current_region), :);
                        if ~isempty(region_sig_neurons) && ~isempty(region_sig_neurons.sig_channels(strcmpi(region_sig_neurons.sig_channels, psth_name) & ...
                                strcmpi(region_sig_neurons.event, current_event)))
                            threshold = region_sig_neurons.threshold(strcmpi(region_sig_neurons.sig_channels, psth_name) & ...
                                strcmpi(region_sig_neurons.event, current_event));
                            first_bin_latency = region_sig_neurons.first_latency(strcmpi(region_sig_neurons.sig_channels, psth_name) & ...
                                strcmpi(region_sig_neurons.event, current_event));
                            last_bin_latency = region_sig_neurons.last_latency(strcmpi(region_sig_neurons.sig_channels, psth_name) & ...
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
                            unit_figure, bin_size, pre_time);
                    end
                    if make_region_subplot
                        figure(region_figure);
                        scrollsubplot(sub_rows, sub_cols, neuron);
                        hold on
                        region_handle = bar(event_window, psth,'BarWidth', 1);
                        set(region_handle, 'EdgeAlpha', 0);
                        ylim([event_min event_max]);
                        
                        plot_recfield(psth, first_bin_latency, last_bin_latency, threshold, ...
                            region_figure, bin_size, pre_time);
                        line([pre_start pre_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                        line([pre_end pre_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                        line([post_start post_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                        line([post_end post_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                        title(psth_name);
                        hold off
                    end
                end
                if make_region_subplot && ~rf_analysis
                    figure(region_figure);
                    scrollsubplot(sub_rows, sub_cols, neuron);
                    hold on
                    region_handle = bar(event_window, psth,'BarWidth', 1);
                    set(region_handle, 'EdgeAlpha', 0);
                    ylim([event_min event_max]);
                    line([pre_start pre_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                    line([pre_end pre_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                    line([post_start post_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                    line([post_end post_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
                    title(psth_name);
                    hold off
                end
                if make_unit_plot
                    figure(unit_figure);
                    filename = [psth_name, '_', current_event, '.png'];
                    saveas(gcf, fullfile(event_path, filename));
                    filename = [psth_name, '_', current_event, '.fig'];
                    savefig(gcf, fullfile(event_path, filename));
                end
            end
            if make_region_subplot
                figure(region_figure);
                filename = [orig_filename, '.fig'];
                savefig(gcf, fullfile(event_path, filename));
            end
            close all
        end
    end
end