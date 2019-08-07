function [labeled_data, unique_regions, region_channels] = label_neurons(animal_path, animal_name, parsed_path)
    label_start = tic;
    %% Grabs label file and creates labels
    animal_csv_path = [animal_path, '/*.csv'];
    csv_files = dir(animal_csv_path);
    for csv = 1:length(csv_files)
        csv_file = fullfile(animal_path, csv_files(csv).name);
        if contains(csv_files(csv).name, 'labels.csv')
            labels = readtable(csv_file);
            labels = sortrows(labels, [4,1]);
        end
    end
    
    % Grabs all .mat files in the parsed plx directory
    parsed_mat_path = strcat(parsed_path, '/*.mat');
    parsed_files = dir(parsed_mat_path);
    
    fprintf('Labeling neurons for %s\n', animal_name);
    for h = 1:length(parsed_files)
        file = [parsed_path, '/', parsed_files(h).name];
        [~, file_name, ~] = fileparts(file);
        [~, ~, ~, session_num, ~, ~] = get_filename_info(file_name);
        load(file);

        % Used to update the neuron map to remove any overlapping neurons
        new_neuron_map = [];
        unique_regions = unique(labels.(2));
        %% Creates the label struct for each file
        for region = 1:length(unique_regions)
            region_name = unique_regions{region};
            %% Finds all the indeces in the table that matches 
            % current region and current recording session
            region_indeces = (strcmpi(labels.(2), region_name) & labels.(4) == session_num);
            %% Collect labels from .csv
            region_names = labels.(2)(region_indeces);
            region_values = num2cell(labels.(3)(region_indeces));
            region_sessions = num2cell(labels.(4)(region_indeces));
            region_notes = labels.(6)(region_indeces);
            channels = labels.(1)(region_indeces);
            region_channels.(region_name) = channels;
            % Find the channels that overlap with the neuron map (with actual data)
            % and the listed neurons in the .csv
            [shared_channels, map_indeces, labels_indeces] = intersect(channel_map(:,1), channels);
            %% Appends everything together in single matrix with all the label information
            % and data
            neuron_data = channel_map(map_indeces,2);
            labeled_data.(region_name) = horzcat(shared_channels, ...
                region_names(labels_indeces), region_values(labels_indeces), ...
                channel_map(map_indeces,2), region_sessions(labels_indeces), ...
                region_notes(labels_indeces));
            %% Update neuron map to only include neurons from intersection
            new_neuron_map = [new_neuron_map; shared_channels, neuron_data];
        end
        original_channel_map = channel_map;
        channel_map = new_neuron_map;
        struct_names = fieldnames(labeled_data);
        empty = cellfun(@(x) isempty(labeled_data.(x)), struct_names);
        labeled_data = rmfield(labeled_data, struct_names(empty));
        unique_regions = fieldnames(labeled_data);
        total_neurons = length(channel_map);
        save(file, 'tscounts', 'evcounts', 'event_ts', 'total_neurons', ...
            'channel_map', 'labeled_data', 'unique_regions', ...
            'region_channels', 'original_channel_map');
    end
    fprintf('Finished labeling for %s. It took %s\n', ...
        animal_name, num2str(toc(label_start)));
end