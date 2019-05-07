function [labeled_neurons, unique_regions, region_channels] = label_neurons(animal_path, animal_name, parsed_path)

    %% Grabs label file and creates labels
    animal_csv_path = [animal_path, '/*.csv'];
    csv_files = dir(animal_csv_path);
    for csv = 1:length(csv_files)
        csv_file = fullfile(animal_path, csv_files(csv).name);
        if contains(csv_files(csv).name, 'labels.csv')
            labels = readtable(csv_file);
        end
    end
    
    % Grabs all .mat files in the parsed plx directory
    parsed_mat_path = strcat(parsed_path, '/*.mat');
    parsed_files = dir(parsed_mat_path);
    
    for h = 1:length(parsed_files)
        file = [parsed_path, '/', parsed_files(h).name];
        [file_path, file_name, file_extension] = fileparts(file);
        seperated_file_name = strsplit(file_name, '.');
        current_session = seperated_file_name{4};
        session_num = regexp(current_session,'\d*','Match');
        session_num = str2num(session_num{1});
        fprintf('Labeling neurons for %s on %s\n', animal_name, current_session);
        try
            load(file, 'tscounts', 'evcounts', 'events', 'total_neurons', ...
            'neuron_map');
            event_ts = events;
        catch
            load(file);
        end
        
        % Used to update the neuron map to remove any overlapping neurons
        new_neuron_map = [];
        unique_regions = unique(labels.(2));
        %% Creates the label struct for each file
        for region = 1:length(unique_regions)
            % Seperate out specific region index in table. IE: only indeces for left neurons in the .csv
            region_name_indeces = strcmpi(labels.(2), unique_regions{region});
            %% Finds all the indeces in the table that matches 
            % current region and current recording session
            region_indeces = (strcmpi(labels.(2), unique_regions{region}) & labels.(4) == session_num);
            %% Collect labels from .csv
            region_names = labels.(2)(region_indeces);
            region_values = num2cell(labels.(3)(region_indeces));
            region_sessions = num2cell(labels.(4)(region_indeces));
            region_notes = labels.(6)(region_indeces);
            channels = labels.(1)(region_indeces);
            region_channels.(unique_regions{region}) = channels;
            % Find the channels that overlap with the neuron map (with actual data)
            % and the listed neurons in the .csv
            [shared_channels, map_indeces, ~] = intersect(neuron_map(:,1), channels);
            %% Appends everything together in single matrix with all the label information
            % and data
            neuron_data = neuron_map(map_indeces,2);
            labeled_neurons.(unique_regions{region}) = horzcat(shared_channels, ...
                region_names(1:length(shared_channels)), region_values(1:length(shared_channels)), ...
                neuron_map(map_indeces,2), region_sessions(1:length(shared_channels)), ...
                region_notes(1:length(shared_channels)));
            %% Update neuron map to only include neurons from intersection
            new_neuron_map = [new_neuron_map; shared_channels, neuron_data];
        end
        original_neuron_map = neuron_map;
        neuron_map = new_neuron_map;
        struct_names = fieldnames(labeled_neurons);
        empty = cellfun(@(x) isempty(labeled_neurons.(x)), struct_names);
        labeled_neurons = rmfield(labeled_neurons, struct_names(empty));
        unique_regions = fieldnames(labeled_neurons);
        total_neurons = length(neuron_map);
        save(file, 'tscounts', 'evcounts', 'event_ts', 'total_neurons', ...
            'neuron_map', 'labeled_neurons', 'unique_regions', ...
            'region_channels', 'original_neuron_map');
    end
end