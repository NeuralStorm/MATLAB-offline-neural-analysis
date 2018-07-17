function [] = graph_PSTH(psth_path, edge, total_bins, total_trials, total_events)
    %% Uses graphPSTH to create a single PSTH for a neuron given an event
    %Uses graphtestPSTH to create a PSTH which represents every trial except one, so that the left out trial can be used to test a decoder.
    
    % TODO go through each psth file and output graphs for both left and
    % right hemispheres. Save the graphs as Right_Neuron_# and Left_Neuron_#
    % where # is continous and matches up with the channel. Save as .fig for
    % now -> look into saving as .png or .jpeg
    % make the file grab specifically grab psth formatted files (although
    % this is not as important because this would only matter when the file
    % the file system is not being used properly)
    
    %neuronnum= input('Enter Neuron Number(1-#neurons):');
    %graphPSTH(neuronnum,reltotalspikes,edge);
    tic;
    psth_mat_path = strcat(psth_path, '/*.mat');
    psth_files = dir([psth_mat_path]);
    
    graph_path = strcat(psth_path, '/psth_graphs');
    if ~exist(graph_path, 'dir')
       mkdir(psth_path, 'psth_graphs');
    end
    %% Iterates through all the psth formated files to create graphs for each neuron
    for h = 1: length(psth_files)
        %% Creating all nec directories and paths to save graphs to
        % Creates file with absolute path to file location
        file = strcat(psth_path, '/');
        file = strcat(file, psth_files(h).name);
        [pathstr,namestr,extstr] = fileparts(file);
        % Creates day directory if it does not already exist
        % Since the name format is consistent I use the direct index in
        % split_name for the directory name to speed up this portion of the
        % code instead of searching for the day string in the cell array.
        % This can be changed though if it turns out to be a problem
        split_name = strsplit(namestr, '.');
        day_path = strcat(graph_path, '/');
        day_path = strcat(day_path, split_name{4});
        % Checks if graph directory for the given say exists already
        if ~exist(day_path, 'dir')
            mkdir(graph_path, split_name{4});
        end
        % checks if a hemisphere path exists and if not, creates right and
        % left directory
        right_hemi_path = strcat(day_path, '/right/');
        left_hemi_path = strcat(day_path, '/left/');

        if ~exist(right_hemi_path, 'dir')
            mkdir(right_hemi_path, 'right');
        end

        if ~exist(left_hemi_path, 'dir')
            mkdir(left_hemi_path, 'left');
        end

        %% Creating the PSTH graphs       
        load(file);

        first = edge(1);
        last = edge(end);
        xedge=linspace(first,last,6);

        % Graphs the right hemisphere
        for event = 1: total_events
           for neuron = 1: total_right_neurons
               % For this case I need to grab the first 100 rows of trials
               % and the first 400 cols of bins for each neuron.
                if mod(event,4) == 1
                    graph = right_total_rel_spikes(((1:total_trials)+((event-1)*total_trials)), ...
                        ((1:total_bins)+((neuron-1)*total_bins)));
                    stim = 1;
                elseif mod(event,4) == 2
                    graph = right_total_rel_spikes(((1:total_trials)+((event-1)*total_trials)), ...
                        ((1:total_bins)+((neuron-1)*total_bins)));
                    stim = 3;
                elseif mod(event,4) == 3
                    graph = right_total_rel_spikes(((1:total_trials)+((event-1)*total_trials)), ...
                        ((1:total_bins)+((neuron-1)*total_bins)));
                    stim = 4;
                else
                    graph = right_total_rel_spikes(((1:total_trials)+((event-1)*total_trials)), ...
                        ((1:total_bins)+((neuron-1)*total_bins)));
                    stim = 6;
                end                
           end
            figure;
            graph = sum(graph);
            bar(graph);
            text=['Histogram of Neuron for event ',num2str(stim)];
            title(text);
            xlabel('Time(seconds)');
            ylabel('Count');
            xlim([0 401]);
            xticklabels(xedge);
        end
        
        
%         for event = 1: total_events
%            for trial = 1: total_trials
%               for bin = 1: total_bins
%                   
%               end
%            end
%         end
        
%         for row = 1: right_hemi_rows
%             length = 100;
%             if mod(row,4) == 1
%                 graph = right_total_rel_spikes(((1:length)+((row-1)*100)),((1:240)+((neuronnum-1)*240)));
%                 stim = 1;
%             elseif mod(row,4) == 2
%                 graph = right_total_rel_spikes(((1:length)+((row-1)*100)),((1:240)+((neuronnum-1)*240)));
%                 stim = 3;
%             elseif mod(row,4) == 3
%                 graph = right_total_rel_spikes(((1:length)+((row-1)*100)),((1:240)+((neuronnum-1)*240)));
%                 stim = 4;
%             else
%                 graph = right_total_rel_spikes(((1:length)+((row-1)*100)),((1:240)+((neuronnum-1)*240)));
%                 stim = 6;
%             end
%             figure;
%             graph = sum(graph);
%             bar(graph);
%             text=['Histogram of Neuron for event ',num2str(stim)];
%             title(text);
%             xlabel('Time(seconds)');
%             ylabel('Count');
%             xlim([0 401]);
%             xticklabels(xedge);
%         end
        
    end
    toc;
end