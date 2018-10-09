function [labeled_neurons, unique_regions, region_channels] = label_neurons(animal_path, animal_name, parsed_path)

    %% Grabs label file and creates labels
    animal_csv_path = [animal_path, '/*.csv'];
    csv_files = dir(animal_csv_path);
    for csv = 1:length(csv_files)
        csv_file = fullfile(animal_path, csv_files(csv).name);
        if contains(csv_files(csv).name, 'labels.csv')
            labels = readtable(csv_file);
            unique_regions = unique(labels.(2));
        else
            error('%s labels file is missing.', animal_name);
        end
    end

    % Grabs all .mat files in the parsed plx directory
    parsed_mat_path = strcat(parsed_path, '/*.mat');
    parsed_files = dir(parsed_mat_path);

    for h = 1:length(parsed_files)
        file = [parsed_path, '/', parsed_files(h).name];
        [file_path, file_name, file_extension] = fileparts(file);
        seperated_file_name = strsplit(file_name, '.');
        current_day = seperated_file_name{4};
        fprintf('Calculating PSTH for %s on %s\n', animal_name, current_day);
        load(file);

        %% Creates the label struct for each file
        for region = 1:length(unique_regions)
            % Seperate out specific region index in table. IE: only indeces for left neurons in the .csv
            region_name_indeces = strcmpi(labels.(2), unique_regions{region});
            region_names = labels.(2)(region_name_indeces);
            region_values = num2cell(labels.(3)(region_name_indeces));
            channels = labels.(1)(region_name_indeces);
            region_channels.(unique_regions{region}) = channels;
            % Find the channels in the neuron_map that actually have data
            [shared_channels, map_indeces, ~] = intersect(neuron_map(:,1), channels);
            labeled_neurons.(unique_regions{region}) = horzcat(shared_channels, region_names(1:length(shared_channels)), region_values(1:length(shared_channels)), neuron_map(map_indeces,2));
        end

        save(file, 'tscounts', 'evcounts', 'tsevs', 'events',  ...
        'total_neurons', 'all_spike_times', 'neuron_map', 'labeled_neurons', 'unique_regions', 'region_channels');
    end
end