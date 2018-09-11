function [] = label_neurons(animal_path, psth_path)
    %% Grabs all the psth formatted files
    psth_mat_path = strcat(psth_path, '/*.mat');
    psth_files = dir(psth_mat_path);
    %% Grabs label file
    animal_csv_path = [animal_path, '/*.csv'];
    csv_files = dir(animal_csv_path);
    for csv = 1:length(csv_files)
        csv_file = fullfile(animal_path, csv_files(csv).name);
        if contains(csv_files(csv).name, 'labels.csv')
            labels = readtable(csv_file);
            unique_regions = unique(labels.(2));
        end
    end

    for h = 1: length(psth_files)
        %% Load psth formatted data
        file = [psth_path, '/', psth_files(h).name];
        [~, name_str, ~] = fileparts(file);
        split_name = strsplit(name_str, '.');
        current_animal = split_name{3};
        current_animal_num = split_name{4};
        current_day = split_name{6};
        load(file);
        %% Creates the label struct for each file
        for region = 1:length(unique_regions)
            % Seperate out specific region index in table. IE: only indeces for left neurons in the .csv
            region_name_indeces = strcmpi(labels.(2), unique_regions{region});
            region_names = labels.(2)(region_name_indeces);
            region_values = num2cell(labels.(3)(region_name_indeces));
            channels = labels.(1)(region_name_indeces);
            % Find the channels in the neuron_map that actually have data
            [shared_channels, map_indeces, ~] = intersect(neuron_map(:,1), channels);
            labeled_neurons.(unique_regions{region}) = horzcat(shared_channels, region_names(1:length(shared_channels)), region_values(1:length(shared_channels)), neuron_map(map_indeces,2));
        end

        save(file, 'event_struct', 'total_neurons', 'neuron_map', 'events', 'event_strings', 'labeled_neurons');
    end
end