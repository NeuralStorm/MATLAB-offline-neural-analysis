function [labeled_neurons, unique_regions, region_channels] = label_neurons(animal_path, labels, neuron_map, unique_regions)
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
end