function [] = graph_PSTH(psth_path, animal_name, total_bins, bin_size, ...
                pre_time, post_time, rf_analysis, rf_path, make_region_subplot, sub_columns)
    %% Graphs each PSTH for every Neuron for every event
    tic;
    % Grabs all the psth formatted files
    psth_mat_path = strcat(psth_path, '/*.mat');
    psth_files = dir(psth_mat_path);
    
    % Checks if a psth graph directory exists and if not it creates it
    graph_path = strcat(psth_path, '/psth_graphs');
    if ~exist(graph_path, 'dir')
       mkdir(psth_path, 'psth_graphs');
    end
    
    pre_time_bins = (length([-abs(pre_time): bin_size: 0])) - 1;
    post_time_bins = (length([0:bin_size:post_time])) - 1;
    %% Iterates through all the psth formated files to create graphs for each neuron
    for h = 1: length(psth_files)
        %% Creating all nec directories and paths to save graphs to
        % Creates file with absolute path to file location
        file = [psth_path, '/', psth_files(h).name];
        [~, name_str, ~] = fileparts(file);
        % Creates day directory if it does not already exist
        % Since the name format is consistent I use the direct index in
        % split_name for the directory name to speed up this portion of the
        % code instead of searching for the day string in the cell array.
        % This can be changed though if it turns out to be a problem
        split_name = strsplit(name_str, '.');
        current_day = split_name{6};
        day_path = [graph_path, '/', current_day];
        fprintf('Graphing PSTH for %s on %s\n', animal_name, current_day);
        % Creates the day directory if it does not already exist
        if ~exist(day_path, 'dir')
            mkdir(graph_path, current_day);
        end

        load(file);

        if rf_analysis
            %% Load receptive field data
            rf_file = [rf_path, '/', psth_files(h).name];
            [rf_path, rf_filename, ~] = fileparts(rf_file);
            rf_filename = strrep(rf_filename, 'PSTH', 'REC');
            rf_filename = strrep(rf_filename, 'format', 'FIELD');
            rf_matfile = fullfile(rf_path, [rf_filename, '.mat']);
            load(rf_matfile, 'sig_neurons', 'non_sig_neurons');
        end

        struct_names = fieldnames(event_struct);
        for i = 1: length(struct_names)
            if isstruct(event_struct.([struct_names{i}]))
                current_region = struct_names{i};
                region_neurons = [labeled_neurons.(current_region)(:,1)];
                total_region_neurons = length(region_neurons);
                % Creates the region directory if it does not already exist
                region_path = [day_path, '/', current_region];
                if ~exist(region_path, 'dir')
                    mkdir(day_path, current_region);
                end

                region_struct_names = fieldnames(event_struct.(current_region));
                for region_field = 1:length(region_struct_names)
                    if contains(region_struct_names{region_field}, '_normalized_raster')
                        % Getting the current event we are graphing (format: event_#_raster)
                        split_raster = strsplit(region_struct_names{region_field}, '_');
                        current_event = split_raster{2};
                        % Get the raster matrix
                        raster = getfield(event_struct.(current_region), region_struct_names{region_field});
                        %% Create the event directories
                        event_path = [region_path, '/event_', current_event, '/'];
                        event_name = ['event_', current_event];
                        if ~exist(event_path, 'dir')
                            mkdir(region_path, event_name);
                        end

                        if make_region_subplot
                            region_figure = figure('visible', 'off');
                            sub_rows = ceil(total_region_neurons / sub_columns);
                            if sub_columns > total_region_neurons
                                sub_cols = total_region_neurons;
                            else
                                sub_cols = sub_columns;
                            end
                        end
                        %% Creating the PSTH graphs
                        for neuron = 1:total_region_neurons
                            current_neuron = raster(((1:total_bins) + ((neuron-1) * total_bins)));
                            current_neuron_name = region_neurons{neuron};
                            unit_figure = figure('visible','off');
                            bar(current_neuron,'BarWidth', 1);
                            if rf_analysis
                                %% Plot first & last bin latency and threshold for significant neurons
                                % otherwise plots threshold on non significant neurons
                                if ~isempty(sig_neurons) && ~isempty(sig_neurons.channel(strcmpi(sig_neurons.channel, current_neuron_name) & ...
                                    strcmpi(sig_neurons.event, event_name)))
                                        event_threshold = sig_neurons.threshold(strcmpi(sig_neurons.channel, current_neuron_name) & ...
                                            strcmpi(sig_neurons.event, event_name));
                                        event_first = sig_neurons.first_latency(strcmpi(sig_neurons.channel, current_neuron_name) & ...
                                            strcmpi(sig_neurons.event, event_name));
                                        event_last = sig_neurons.last_latency(strcmpi(sig_neurons.channel, current_neuron_name) & ...
                                            strcmpi(sig_neurons.event, event_name));
                                    %% Converts time to bin
                                    event_first = ((event_first + abs(pre_time)) / bin_size);
                                    event_last = ((event_last + abs(pre_time)) / bin_size);
                                    %% Plots elements from rec field analysis
                                    figure(unit_figure)
                                    hold on
                                    plot(xlim,[event_threshold event_threshold], 'r', 'LineWidth', 0.75);
                                    line([event_first event_first], ylim, 'Color', 'red', 'LineWidth', 0.75);
                                    line([event_last event_last], ylim, 'Color', 'red', 'LineWidth', 0.75);
                                    line([pre_time_bins pre_time_bins], ylim, 'Color', 'black', 'LineWidth', 0.75);
                                    hold off
                                    if make_region_subplot
                                        figure(region_figure);
                                        scrollsubplot(sub_rows, sub_cols, neuron);
                                        hold on
                                        bar(current_neuron,'BarWidth', 1);
                                        plot(xlim,[event_threshold event_threshold], 'r', 'LineWidth', 0.75);
                                        line([event_first event_first], ylim, 'Color', 'red', 'LineWidth', 0.75);
                                        line([event_last event_last], ylim, 'Color', 'red', 'LineWidth', 0.75);
                                        line([pre_time_bins pre_time_bins], ylim, 'Color', 'black', 'LineWidth', 0.75);
                                        title(current_neuron_name);
                                        hold off
                                    end
                                elseif ~isempty(non_sig_neurons)
                                    figure(unit_figure);
                                    hold on
                                    event_threshold = non_sig_neurons.threshold(strcmpi(non_sig_neurons.channel, current_neuron_name) & ...
                                        strcmpi(non_sig_neurons.event, event_name));
                                    plot(xlim,[event_threshold event_threshold], 'r', 'LineWidth', 0.75);
                                    line([pre_time_bins pre_time_bins], ylim, 'Color', 'black', 'LineWidth', 0.75);
                                    hold off
                                    if make_region_subplot
                                        figure(region_figure)
                                        scrollsubplot(sub_rows, sub_cols, neuron);
                                        hold on
                                        bar(current_neuron,'BarWidth', 1);
                                        plot(xlim,[event_threshold event_threshold], 'r', 'LineWidth', 0.75);
                                        line([pre_time_bins pre_time_bins], ylim, 'Color', 'black', 'LineWidth', 0.75);
                                        title(current_neuron_name);
                                        hold off
                                    end
                                end
                            end
                            figure(unit_figure);
                            x_values = get(gca, 'XTick');
                            xtickformat('%.2f')
                            set(gca, 'XTick', x_values, 'XTickLabel', (x_values * bin_size - abs(pre_time)));
                            text=[current_neuron_name, ' Normalized Histogram for Event ', current_event ' on ', current_day, ' for ', animal_name];
                            title(text);
                            xlabel('Time (s)');
                            ylabel('Count');
                            filename = [current_neuron_name, '_event_', current_event, '.png'];
                            saveas(gcf, fullfile(event_path, filename));
                            filename = [current_neuron_name, '_event_', current_event, '.fig'];
                            savefig(gcf, fullfile(event_path, filename));
                        end
                        if make_region_subplot
                            figure(region_figure);
                            filename = ['region_units_event_', current_event, '.fig'];
                            savefig(gcf, fullfile(event_path, filename));
                        end
                    end
                end
            end
        end
        fprintf('Finished graphing for %s\n', current_day);
        close all
    end
    toc;
end