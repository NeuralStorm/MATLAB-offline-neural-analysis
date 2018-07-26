function [] = main()
    %% Initialize global variables
    bin_size = 0.001;
    total_trials = 100;
    total_events = 4;
    pre_time = 0.2;
    post_time = 0.2;
    % Requires for all events to be in array. IF empty it will skip all events
    wanted_events = [1, 3, 4, 6];
    % If wanted_neurons is left empty, it will do all neurons
    wanted_neurons = [];
    % Inclusive Range
    trial_range = [1, 400];
    % Give exact match to directory you want skipped
    ignored_animals = [];
    total_bins = (length([-abs(pre_time):bin_size:abs(post_time)]) - 1);

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
                parsed_path = parser(animal_path, animal_name, total_trials, total_events);

                %% Use the code commented out below to skip parsing
                % parsed_path = [animal_path, '/parsed_plx'];

                %% Run if you want to calculate the PSTH or comment it out to skip
                psth_path = calculate_PSTH(parsed_path, animal_name, total_bins, bin_size, pre_time, post_time, ...
                    wanted_neurons, wanted_events, trial_range);

                %% Use code commeneted out below to skip PSTH calculations
                % psth_path = [parsed_path, '/psth'];

                %% Run if you want to graph all of the PSTHs or comment it out to skip
                graph_PSTH(psth_path, animal_name, total_bins, total_trials, total_events, pre_time, post_time);
            end
        end
    end
end