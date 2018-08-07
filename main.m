function [] = main()
    start_time = tic;
    %% Initialize global variables
    bin_size = 0.020;
    total_trials = 100;
    total_events = 4;
    pre_time = 0.2;
    post_time = 0.2;
    % Requires for all events to be in array. IF empty it will skip all events
    wanted_events = [1, 3, 4, 6];
    % If wanted_neurons is left empty, it will do all neurons
    wanted_neurons = [];
    % Inclusive Range
    trial_range = [1, 300];
    % Give exact match to directory you want skipped
    ignored_animals = ['TNC25'];
    total_bins = (length([-abs(pre_time):bin_size:abs(post_time)]) - 1);
    failed = {};
    % Boolean to control classification for population or single neurons
    % Default is set to single neuron
    unit_classification = true;
    % controls how many bootstrap iterations are done. Default is 1 (equivalent to single classification)
    boot_iterations = 50;

    % Get the directory with all animals and their respective .plx files
    original_path = uigetdir(pwd);
    animal_list = dir(original_path);
    % Starts at index 3 since dir returns '.' and '..'
    if length(animal_list) > 2
        for animal = 3: length(animal_list)
            animal_name = animal_list(animal).name;
            animal_path = [animal_list(animal).folder, '/', animal_name];
            % Skips animals we want to ignore
            if ~isempty(ignored_animals) && contains(ignored_animals, animal_name)
                continue;
            else
                %% Run if you want to parse .plx or comment out to skip
                try
                    parsed_path = parser(animal_path, animal_name, total_trials, total_events);
                catch
                    failed{end+1} = animal_list(animal).name;
                end
                %% Use the code commented out below to skip parsing
                % parsed_path = [animal_path, '/parsed_plx'];

                %% Run if you want to calculate the PSTH or comment it out to skip
                try
                    psth_path = calculate_PSTH(parsed_path, animal_name, total_bins, bin_size, pre_time, post_time, ...
                        wanted_neurons, wanted_events, trial_range, total_trials);
                catch
                    failed{end+1} = animal_list(animal).name;
                end
                %% Use code commeneted out below to skip PSTH calculations
                % psth_path = [parsed_path, '/psth'];

                %% Run if you want to graph all of the PSTHs or comment it out to skip
                % try
                %     graph_PSTH(psth_path, animal_name, total_bins, total_trials, total_events, pre_time, post_time);
                % catch
                %     failed{end+1} = animal_list(animal).name;
                % end

                %% Run for bootstrapping
                classified_path = crude_bootstrapper(psth_path, animal_name, boot_iterations, bin_size, pre_time, ...
                    post_time, wanted_events, unit_classification);
            end
        end
    end
    toc(start_time);
end