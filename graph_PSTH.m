function [] = graph_PSTH(psth_path, animal_name, total_bins, total_trials, total_events, bin_size, ...
                pre_time, post_time, rf_analysis, rf_path, span)
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
        struct_names = fieldnames(event_struct);
        for i = 1: length(struct_names)
            if contains(struct_names{i}, '_normalized_raster')
                % Getting the current event we are graphing (format: event_#_raster)
                split_raster = strsplit(struct_names{i}, '_');
                current_event = split_raster{2};
                % Get the raster matrix
                raster = getfield(event_struct, struct_names{i});
                %% Create the event directories
                event_path = [day_path, '/event_', current_event, '/'];
                event_name = ['event_', current_event];
                if ~exist(event_path, 'dir')
                    mkdir(day_path, event_name);
                end
                %% Creating the PSTH graphs
                for neuron = 1: total_neurons
                    current_neuron = raster(((1:total_bins) + ((neuron-1) * total_bins)));
                    figure('visible','off');                 
                    %% Graphs determined threshold from receptive field analysis
                    if rf_analysis
                        hold on;
                        bar(smooth(current_neuron, span));
                        rf_file = [rf_path, '/', psth_files(h).name];
                        [rf_path, rf_filename, ~] = fileparts(rf_file);
                        rf_filename = strrep(rf_filename, 'PSTH', 'REC');
                        rf_filename = strrep(rf_filename, 'format', 'FIELD');
                        rf_matfile = fullfile(rf_path, [rf_filename, '.mat']);
                        load(rf_matfile, 'receptive_analysis');
                        try
                            %% Get the receptive field struct fields
                            event_thresholds = getfield(receptive_analysis, [neuron_map{neuron}, '_threshold']);
                            event_first = getfield(receptive_analysis, [neuron_map{neuron}, '_first_latency']);
                            event_last = getfield(receptive_analysis, [neuron_map{neuron}, '_last_latency']);
                            %% Gets info from cell array
                            current_threshold = find(strcmp(event_name, event_thresholds(:,1)));
                            current_threshold = event_thresholds{current_threshold, 2};
                            current_first = find(strcmp(event_name, event_first(:,1)));
                            current_first = (event_first{current_first, 2}/bin_size) + pre_time_bins;
                            current_last = find(strcmp(event_name, event_last(:,1)));
                            current_last = (event_last{current_last, 2}/bin_size) + pre_time_bins;
                            %% Plots elements from rec field analysis
                            plot(xlim,[current_threshold current_threshold], 'r', 'LineWidth', 0.75);
                            line([current_first current_first], ylim, 'Color', 'red', 'LineWidth', 0.75);
                            line([current_last current_last], ylim, 'Color', 'red', 'LineWidth', 0.75);
                            line([pre_time_bins pre_time_bins], ylim, 'Color', 'black', 'LineWidth', 0.75);
                        % catch ME
                        %     warning('Error: %s\n', ME.message);
                        end
                    else
                        bar(current_neuron,'BarWidth', 1);
                    end
                    x_values = get(gca, 'XTick');
                    set(gca, 'XTick', x_values, 'XTickLabel', ((x_values*2)/1000) - pre_time);
                    text=[neuron_map{neuron}, ' Normalized Histogram for Event ', current_event ' on ', current_day, ' for ', animal_name];
                    title(text);
                    xlabel('Time (s)');
                    ylabel('Count');
                    filename = [neuron_map{neuron}, '_event_', current_event, '.png'];
                    saveas(gcf, fullfile(event_path, filename));
                end
            end
        end       
        fprintf('Finished graphing for %s\n', current_day);
    end
    toc;
end