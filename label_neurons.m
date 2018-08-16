function [] = label_neurons(psth_path)
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
        right_neurons = {};
        left_neurons = {};
        for neuron = 1: total_neurons
            channel_name = neuron_map{neuron, 1};
            channel_num = str2num(channel_name(4:6));
            if channel_num > 16
                % Assigns to left neurons
                left_neurons(end + 1, 1) = neuron_map(neuron, 1);
                left_neurons(end, 2) = neuron_map(neuron, 2);
            else
                % Assigns to right neurons
                right_neurons(end + 1, 1) = neuron_map(neuron, 1);
                right_neurons(end, 2) = neuron_map(neuron, 2);
            end
        end
        save(file, 'event_struct', 'total_neurons', 'neuron_map', 'events', 'event_strings', 'right_neurons', 'left_neurons');
    end
end