function [unit_index] = label_neurons(psth_path, neuron_labels, unit_index)
    % Grabs all the psth formatted files
    psth_mat_path = strcat(psth_path, '/*.mat');
    psth_files = dir(psth_mat_path);

    for h = 1: length(psth_files)
        % PSTH.format.TNC.25.ClosedLoop.Day26.111416
        file = [psth_path, '/', psth_files(h).name];
        [~, name_str, ~] = fileparts(file);
        split_name = strsplit(name_str, '.');
        current_animal = split_name{3};
        current_animal_num = split_name{4};
        current_day = split_name{6};
        load(file);
        direct_neurons = {};
        indirect_neurons = {};
        for neuron = 1: total_neurons
            % if (neuron_labels.animal_study(neuron) == current_animal) && (neuron_labels.animal_number(neuron) == current_animal_num) && (neuron_labels.experiment_day(neuron) == current_day) && (neuron_labels.neuron_label(neuron) == 'Direct')
            if neuron_labels(unit_index) == 'Direct'
                direct_neurons(end + 1, 1) = neuron_map(neuron, 1);
                direct_neurons(end, 2) = neuron_map(neuron, 2);
            % elseif (neuron_labels.animal_study(neuron) == current_animal) && (neuron_labels.animal_number(neuron) == current_animal_num) && (neuron_labels.experiment_day(neuron) == current_day) && (neuron_labels.neuron_label(neuron) == 'Indirect')
            else
                indirect_neurons(end + 1, 1) = neuron_map(neuron, 1);
                indirect_neurons(end, 2) = neuron_map(neuron, 2);
            end
            unit_index = unit_index + 1;
        end
        matfile = fullfile(psth_path, [name_str, '.mat']);
        direct_neurons(~cellfun('isempty', direct_neurons));
        indirect_neurons(~cellfun('isempty', indirect_neurons));
        save(matfile, 'event_struct', 'total_neurons', 'neuron_map', 'events', 'event_strings', 'direct_neurons', 'indirect_neurons', 'neuron_labels');
        disp(unit_index);
    end
end