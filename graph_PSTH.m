function [] = graph_PSTH(psth_path, total_bins, total_trials, total_events, pre_time, post_time)
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
        for event = 1: total_events
           for neuron = 1: total_neurons
               % For this case I need to grab the first 100 rows of trials
               % and the first 400 cols of bins for each neuron.
                if mod(event, 4) == 1
                    graph = all_total_rel_spikes(((1:total_trials) + ((event-1) * total_trials)), ...
                        ((1:total_bins) + ((neuron - 1) * total_bins)));
                    save_path = event_1_path;
                    stim = 1;
                elseif mod(event, 4) == 2
                    graph = all_total_rel_spikes(((1:total_trials) + ((event - 1) * total_trials)), ...
                        ((1:total_bins) + ((neuron - 1) * total_bins)));
                    save_path = event_3_path;
                    stim = 3;
                elseif mod(event, 4) == 3
                    graph = all_total_rel_spikes(((1:total_trials) + ((event-1) * total_trials)), ...
                        ((1:total_bins) + ((neuron-1) * total_bins)));
                    save_path = event_4_path;
                    stim = 4;
                else
                    graph = all_total_rel_spikes(((1:total_trials) + ((event - 1) * total_trials)), ...
                        ((1:total_bins) + ((neuron - 1) * total_bins)));
                    save_path = event_6_path;
                    stim = 6;
                end
                figure('visible','off');
                graph = sum(graph);
                bar(graph);
                text=['Histogram of Neuron ', num2str(neuron), ' for event ',num2str(stim)];
                title(text);
                xlabel('Time (ms)');
                ylabel('Count');
                % Pre and post times are converted to seconds (hence why
                % they are multiplied by 1000)
                xlim([0 400]);
                graph_name = ['Neuron_', num2str(neuron), '_event_', num2str(stim), '.png'];
                saveas(gcf, fullfile(save_path, graph_name));
           end           
        end        
    end
    toc;
end