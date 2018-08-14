function [] = graph_PSTH(psth_path, animal_name, total_bins, total_trials, total_events, ...
                pre_time, post_time)
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
            if contains(struct_names{i}, '_raster')
                % Getting the current event we are graphing (format: event_#_raster)
                split_raster = strsplit(struct_names{i}, '_');
                current_event = split_raster{2};
                % Get the raster matrix
                raster = getfield(event_struct, struct_names{i});
                %% Create the event directories
                event_path = [day_path, '/event_', current_event, '/'];
                if ~exist(event_path, 'dir')
                    mkdir(day_path, ['event_', current_event]);
                end
                %% Creating the PSTH graphs
                for neuron = 1: total_neurons
                    figure('visible','off');
                    bar(raster(((1:total_bins) + ((neuron-1) * total_bins))));
                    text=[neuron_map{neuron}, ' Histogram for Event ', current_event ' on ', current_day, ' for ', animal_name];
                    title(text);
                    xlabel('Time (ms)');
                    ylabel('Count');
                    xlim([0 total_bins]);
                    filename = [neuron_map{neuron}, '_event_', current_event, '.png'];
                    saveas(gcf, fullfile(event_path, filename));
                end
            end
        end       
        fprintf('Finished graphing for %s\n', current_day);
    end
    toc;
end