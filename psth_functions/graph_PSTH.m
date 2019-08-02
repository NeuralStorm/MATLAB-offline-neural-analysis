function [] = graph_PSTH(save_path, event_struct, labeled_neurons, sig_neurons, non_sig_neurons, bin_size, ...
                pre_time, post_time, rf_analysis, make_region_subplot, sub_cols, sub_rows)

    event_strings = event_struct.all_events(:,1)';
    event_window = -(abs(pre_time) - bin_size):bin_size:(abs(post_time));
    total_bins = length(event_window);
    event_onset = 0;

    region_names = fieldnames(labeled_neurons);
    parfor region = 1:length(region_names)
        current_region = region_names{region};
        region_neurons = labeled_neurons.(current_region)(:,1);
        total_region_neurons = length(region_neurons);
        % Creates the region directory if it does not already exist
        region_path = [save_path, '/', current_region];
        if ~exist(region_path, 'dir')
            mkdir(save_path, current_region);
        end

        for event = 1:length(event_strings(1,:))
            current_event = event_strings{event};
            psth = event_struct.(current_region).(current_event).psth;
            %% Create the event directories
            event_path = [region_path, '/', current_event, '/'];
            if ~exist(event_path, 'dir')
                mkdir(region_path, current_event);
            end

            if make_region_subplot
                region_figure = figure('visible', 'off');
            end
            %% Creating the PSTH graphs
            for neuron = 1:total_region_neurons
                current_neuron = psth(((1:total_bins) + ((neuron-1) * total_bins)));
                current_neuron_name = region_neurons{neuron};
                %{
                unit_figure = figure('visible','off');
                unit_handle = bar(event_window, current_neuron,'BarWidth', 1);
                set(unit_handle, 'EdgeAlpha', 0);
                %}
                 [unit_figure] = plot_PSTH(current_neuron,current_neuron_name,current_event,event_window)

                
                if rf_analysis
                    %% Plot first & last bin latency and threshold for significant neurons
                    % otherwise plots threshold on non significant neurons
                    if ~isempty(sig_neurons)
                        region_sig_neurons = sig_neurons(strcmpi(sig_neurons.region, current_region), :);
                        if ~isempty(region_sig_neurons) && ~isempty(region_sig_neurons.channel(strcmpi(region_sig_neurons.channel, current_neuron_name) & ...
                                strcmpi(region_sig_neurons.event, current_event)))
                            event_threshold = region_sig_neurons.threshold(strcmpi(region_sig_neurons.channel, current_neuron_name) & ...
                                strcmpi(region_sig_neurons.event, current_event));
                            first_bin_latency = region_sig_neurons.first_latency(strcmpi(region_sig_neurons.channel, current_neuron_name) & ...
                                strcmpi(region_sig_neurons.event, current_event));
                            last_bin_latency = region_sig_neurons.last_latency(strcmpi(region_sig_neurons.channel, current_neuron_name) & ...
                                strcmpi(region_sig_neurons.event, current_event));
                            %% Plots elements from rec field analysis
                            %plot_recfield
                            %{
                            figure(unit_figure)
                            hold on
                            plot(xlim,[event_threshold event_threshold], 'r', 'LineWidth', 0.75);
                            line([event_first event_first], ylim, 'Color', 'red', 'LineWidth', 0.75);
                            line([event_last event_last], ylim, 'Color', 'red', 'LineWidth', 0.75);
                            line([event_onset event_onset], ylim, 'Color', 'black', 'LineWidth', 0.75);
                            hold off
                            %}
                            if make_region_subplot
                                figure(region_figure);
                                scrollsubplot(sub_rows, sub_cols, neuron);
                                hold on
                                region_handle = bar(event_window, current_neuron,'BarWidth', 1);
                                set(region_handle, 'EdgeAlpha', 0);
                                plot(xlim,[event_threshold event_threshold], 'r', 'LineWidth', 0.75);
                                line([first_bin_latency first_bin_latency], ylim, 'Color', 'red', 'LineWidth', 0.75);
                                line([last_bin_latency last_bin_latency], ylim, 'Color', 'red', 'LineWidth', 0.75);
                                line([event_onset event_onset], ylim, 'Color', 'black', 'LineWidth', 0.75);
                                title(current_neuron_name);
                                hold off
                            end
                        end
                    end
                    if ~isempty(non_sig_neurons) && ~isempty(non_sig_neurons.channel(strcmpi(non_sig_neurons.channel, current_neuron_name) & ...
                            strcmpi(non_sig_neurons.event, current_event) & strcmpi(non_sig_neurons.region, current_region)))
                        %{
                        figure(unit_figure);
                        hold on
                        %}
                        event_threshold = non_sig_neurons.threshold(strcmpi(non_sig_neurons.channel, current_neuron_name) & ...
                            strcmpi(non_sig_neurons.event, current_event) & strcmpi(non_sig_neurons.region, current_region));
                        first_bin_latency = NaN;
                        last_bin_latency = NaN;

                       % plot_recfield
                        %{
                        plot(xlim,[event_threshold event_threshold], 'r', 'LineWidth', 0.75);
                        line([event_onset event_onset], ylim, 'Color', 'black', 'LineWidth', 0.75);
                        hold off
                        %}
                        if make_region_subplot
                            figure(region_figure)
                            scrollsubplot(sub_rows, sub_cols, neuron);
                            hold on
                            region_handle = bar(event_window, current_neuron,'BarWidth', 1);
                            set(region_handle, 'EdgeAlpha', 0);
                            plot(xlim,[event_threshold event_threshold], 'r', 'LineWidth', 0.75);
                            line([event_onset event_onset], ylim, 'Color', 'black', 'LineWidth', 0.75);
                            title(current_neuron_name);
                            hold off
                        end
                    end
                    
                    plot_recfield(first_bin_latency,last_bin_latency,event_threshold,event_onset,unit_figure,bin_size)
                    
                end
                if make_region_subplot && ~rf_analysis
                    figure(region_figure);
                    scrollsubplot(sub_rows, sub_cols, neuron);
                    hold on
                    region_handle = bar(event_window, current_neuron,'BarWidth', 1);
                    set(region_handle, 'EdgeAlpha', 0);
                    line([event_onset event_onset], ylim, 'Color', 'black', 'LineWidth', 0.75);
                    title(current_neuron_name);
                    hold off
                end
                 
                figure(unit_figure);
                %{
                xtickformat('%.2f')
                text=['Normalized Histogram: ', current_neuron_name, ' event: ', current_event];
                title(text);
                xlabel('Time (s)');
                ylabel('Count');
                %}
                
                filename = [current_neuron_name, '_', current_event, '.png'];
                saveas(gcf, fullfile(event_path, filename));
                filename = [current_neuron_name, '_', current_event, '.fig'];
                savefig(gcf, fullfile(event_path, filename));
            end
            if make_region_subplot
                figure(region_figure);
                filename = ['region_units_', current_event, '.fig'];
                savefig(gcf, fullfile(event_path, filename));
            end
            close all
        end
    end
end