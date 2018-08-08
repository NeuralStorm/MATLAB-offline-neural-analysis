function [] = csv_export(classified_path, original_path, total_events, wanted_events, pre_time, post_time, bin_size, first_iteration, ...
        trial_range, boot_iterations, animal_name, total_trials, unit_classification, spreadsheet_name, append_spreadsheet)
    tic;   
    classified_mat_path = strcat(classified_path, '/*.mat');
    classified_files = dir(classified_mat_path);

    matfile = fullfile(original_path, spreadsheet_name);
    % TODO find a better way to control flow
    if exist(matfile, 'file') == 2 && first_iteration && ~append_spreadsheet
        delete(matfile);
        pause(5);
        spreadsheet_table = table([], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], 'VariableNames', ... 
            {'animal_study', 'animal_number', 'experiment_date', 'experiment_day', 'tot_events', 'selected_events', ...
            'tot_neurons', 'event_pre_time', 'event_post_time', 'selected_bin_size', 'tot_trials', 'inclusive_trial_range', 'total_bootstrap', ...
            'classification_type', 'neuron_name', 'classification_accuracy', 'neuron_info', 'neuron_boot_info', 'neuron_corrected_info'});
    elseif exist(matfile, 'file') == 2
        spreadsheet_table = readtable(matfile);
    else
        spreadsheet_table = table([], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], 'VariableNames', ... 
            {'animal_study', 'animal_number', 'experiment_date', 'experiment_day', 'tot_events', 'selected_events', ...
            'tot_neurons', 'event_pre_time', 'event_post_time', 'selected_bin_size', 'tot_trials', 'inclusive_trial_range', 'total_bootstrap', ...
            'classification_type', 'neuron_name', 'classification_accuracy', 'neuron_info', 'neuron_boot_info', 'neuron_corrected_info'});
    end



    % Initialize dynamic variables
    animal_study = [];
    animal_number = [];
    experiment_date = [];
    experiment_day = [];
    tot_events = [];
    selected_events = [];
    tot_neurons = [];
    event_pre_time = [];
    event_post_time = [];
    selected_bin_size = [];
    tot_trials = [];
    inclusive_trial_range = [];
    total_bootstrap = [];
    classification_type = [];
    neuron_name = [];
    classification_accuracy = [];
    neuron_info = [];
    neuron_boot_info = [];
    neuron_corrected_info = [];
    % new_spreadsheet_table = table;
    % Reformat variables so they appear in an array format when saved to table
    string_events = cellstr(num2str(wanted_events));
    string_trial_range = cellstr(num2str(trial_range));
    total_possible_trials = (total_trials * total_events);
    for h = 1: length(classified_files)
        % file name: CLASSIFIED.PSTH.format.PRAC.03.ClosedLoop.Day25.111715
        file = [classified_path, '/', classified_files(h).name];
        [file_path, file_name, file_extension] = fileparts(file);
        animal_info = strsplit(file_name, '.');
        current_study = animal_info(4);
        current_animal_number = str2num(animal_info{5});
        current_day = animal_info(7);
        current_date = str2num(animal_info{end});
        fprintf('Spreadsheet: On %s on %s\n', animal_name, current_day{1});

        load(file);
        if unit_classification
            animal_study = [animal_study; repmat(current_study, [total_neurons, 1])];
            animal_number = [animal_number; repmat(current_animal_number, [total_neurons, 1])];
            experiment_date = [experiment_date; repmat(current_date, [total_neurons, 1])];
            experiment_day = [experiment_day; repmat(current_day, [total_neurons, 1])];
            tot_events = [tot_events; repmat(total_events, [total_neurons, 1])];
            selected_events = [selected_events; repmat(string_events, [total_neurons, 1])];
            tot_neurons = [tot_neurons; repmat(total_neurons, [total_neurons, 1])];
            event_pre_time = [event_pre_time; repmat(pre_time, [total_neurons, 1])];
            event_post_time = [event_post_time; repmat(post_time, [total_neurons, 1])];
            selected_bin_size = [selected_bin_size; repmat(bin_size, [total_neurons, 1])];
            tot_trials = [tot_trials; repmat(total_possible_trials, [total_neurons, 1])];
            inclusive_trial_range = [inclusive_trial_range; repmat(string_trial_range, [total_neurons, 1])];
            total_bootstrap = [total_bootstrap; repmat(boot_iterations, [total_neurons, 1])];
            % TODO event_distribution, z-score
            classification = {'unit'};
            classification_type = [classification_type; repmat(classification, [total_neurons, 1])];
            unit_names = [];
            unit_accuracy = [];
            unit_info = [];
            unit_boot_info = [];
            unit_corrected_info = [];
            for unit = 1: length(neuron_map)
                %% Channel name
                channel_name = neuron_map(unit);
                unit_names = [unit_names; channel_name];
                %% Classification accuracy
                channel_name = neuron_map{unit};
                accuracy = classified_struct.([channel_name, '_accuracy']);
                unit_accuracy = [unit_accuracy; accuracy];
                %% Initial classified info
                raw_information = classified_struct.([channel_name, '_information']);
                unit_info = [unit_info; raw_information];
                %% Bootstrapped info
                boot_info = classified_struct.([channel_name, '_bootstrapped_info']);
                unit_boot_info = [unit_boot_info; boot_info];
                %% Corrected info
                corrected_info = classified_struct.([channel_name, '_corrected_info']);
                unit_corrected_info = [unit_corrected_info; corrected_info];
            end
            neuron_name = [neuron_name; unit_names];
            classification_accuracy = [classification_accuracy; unit_accuracy];
            neuron_info = [neuron_info; unit_info];
            neuron_boot_info = [neuron_boot_info; unit_boot_info];
            neuron_corrected_info = [neuron_corrected_info; unit_corrected_info];
        else
            classification = 'population';
            classification_type = [classification];
            animal_study = [current_study];
            animal_number = [current_animal_number];
            experiment_date = [current_date];
            experiment_day = [current_day];
            tot_events = [total_events];
            selected_events = [string_events];
            tot_neurons = [total_neurons];
            event_pre_time = [pre_time];
            event_post_time = [post_time];
            selected_bin_size = [bin_size];
            tot_trials = [total_possible_trials];
            inclusive_trial_range = [string_trial_range];
            total_bootstrap = [boot_iterations];
        end

    end
    new_spreadsheet_table = table(animal_study, animal_number, experiment_date, experiment_day, tot_events, selected_events, ...
        event_pre_time, event_post_time, selected_bin_size, tot_trials, inclusive_trial_range, total_bootstrap, tot_neurons, ...
        classification_type, neuron_name, classification_accuracy, neuron_info, neuron_boot_info, neuron_corrected_info, 'VariableNames', ... 
        {'animal_study', 'animal_number', 'experiment_date', 'experiment_day', 'tot_events', 'selected_events', ...
        'tot_neurons', 'event_pre_time', 'event_post_time', 'selected_bin_size', 'tot_trials', 'inclusive_trial_range', 'total_bootstrap', ...
        'classification_type', 'neuron_name', 'classification_accuracy', 'neuron_info', 'neuron_boot_info', 'neuron_corrected_info'});
    spreadsheet_table = [spreadsheet_table; new_spreadsheet_table];
    writetable(spreadsheet_table, matfile, 'Delimiter', ',');
    toc;
end