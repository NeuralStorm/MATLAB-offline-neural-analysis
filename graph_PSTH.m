function [] = graph_PSTH(psth_path, animal_name, total_bins, total_trials, total_events, pre_time, post_time)
    %% Graphs each PSTH for every Neuron for every event
    tic;
    fprintf('Graphing PSTH for %s\n', animal_name);
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
        day_path = [graph_path, '/', split_name{6}];
        % Checks if graph directory for the given day exists already and
        % creates the day directory and the events directories if it doesnt
        event_1_path = [day_path, '/event_1/']; 
        event_3_path = [day_path, '/event_3/'];
        event_4_path = [day_path, '/event_4/'];
        event_6_path = [day_path, '/event_6/'];
        if ~exist(day_path, 'dir')
            mkdir(graph_path, split_name{6});
            mkdir(event_1_path);
            mkdir(event_3_path);
            mkdir(event_4_path);
            mkdir(event_6_path);
        end

        %% Creating the PSTH graphs       
        load(file);

        % Graphs each neuron
        for neuron = 1: total_neurons
            % Graph for event 1
            figure('visible','off');
            bar(raster_1(((1:total_bins) + ((neuron-1) * total_bins))));
            text=['Histogram of Neuron ', num2str(neuron), ' for event 1'];
            title(text);
            xlabel('Time (ms)');
            ylabel('Count');
            % Pre and post times are converted to seconds (hence why
            % they are multiplied by 1000)
            xlim([0 400]);
            raster_1_name = ['Neuron_', num2str(neuron), '_event_1.png'];
            saveas(gcf, fullfile(event_1_path, raster_1_name));
            % Graph for event 3
            figure('visible','off');
            bar(raster_3(((1:total_bins) + ((neuron-1) * total_bins))));
            text=['Histogram of Neuron ', num2str(neuron), ' for event 3'];
            title(text);
            xlabel('Time (ms)');
            ylabel('Count');
            xlim([0 400]);
            raster_3_name = ['Neuron_', num2str(neuron), '_event_3.png'];
            saveas(gcf, fullfile(event_3_path, raster_3_name));
            % Graph for event 4
            figure('visible','off');
            bar(raster_4(((1:total_bins) + ((neuron-1) * total_bins))));
            text=['Histogram of Neuron ', num2str(neuron), ' for event 4'];
            title(text);
            xlabel('Time (ms)');
            ylabel('Count');
            xlim([0 400]);
            raster_4_name = ['Neuron_', num2str(neuron), '_event_4.png'];
            saveas(gcf, fullfile(event_4_path, raster_4_name));
            % Graph for event 6
            figure('visible','off');
            bar(raster_6(((1:total_bins) + ((neuron-1) * total_bins))));
            text=['Histogram of Neuron ', num2str(neuron), ' for event 6'];
            title(text);
            xlabel('Time (ms)');
            ylabel('Count');
            xlim([0 400]);
            raster_6_name = ['Neuron_', num2str(neuron), '_event_6.png'];
            saveas(gcf, fullfile(event_6_path, raster_6_name));
        end                 
    end
    toc;
end