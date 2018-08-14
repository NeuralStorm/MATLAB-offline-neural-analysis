function [unit_index] = label_neurons(psth_path, neuron_labels, unit_index)
    % Grabs all the psth formatted files
    psth_mat_path = strcat(psth_path, '/*.mat');
    psth_files = dir(psth_mat_path);

    for h = 1: length(psth_files)
        file = [psth_path, '/', psth_files(h).name];
        [~, name_str, ~] = fileparts(file);
        split_name = strsplit(name_str, '.');
        current_day = split_name{6};
        load(file);
        direct_neurons = {};
        indirect_neurons = {};
        for neuron = 1: total_neurons
            if neuron_labels(neuron) == 'Direct'
                direct_neurons(end + 1) = neuron_map(neuron, 1);
                direct_neurons(end + 1) = neuron_map(neuron, 2);
            else
                indirect_neurons(end + 1) = neuron_map(neuron, 1);
                indirect_neurons(end + 1) = neuron_map(neuron, 2);
            end
            unit_index = unit_index + 1;
        end
        matfile = fullfile(psth_path, [name_str, '.mat']);
        save(matfile, 'event_struct', 'total_neurons', 'neuron_map', 'events', 'event_strings', 'direct_neurons', 'indirect_neurons');
        disp(unit_index);
    end
end