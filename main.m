function [] = main()
    %% Initialize global variables
    total_bins = 400;
    bin_size = 0.001;
    total_trials = 100;
    total_events = 4;
    pre_time = 0.2;
    post_time = 0.2;

    % Get the directory with all animals and their respective .plx files
    original_path = uigetdir(pwd);
    animal_list = dir(original_path);
    % Starts at index 3 since dir returns '.' and '..'
    if length(animal_list) > 2
        for animal = 3: length(animal_list)
            animal_name = animal_list(animal).name;
            animal_path = [animal_list(animal).folder, '/', animal_name];
            %% Run if you want to parse .plx or comment out to skip
            parsed_path = parser(animal_path, animal_name, total_trials);

            %% Use the code commented out below to skip parsing
            % parsed_path = [animal_path, '/parsed_plx'];

            %% Run if you want to calculate the PSTH or comment it out to skip
            psth_path = calculate_PSTH(parsed_path, animal_name, total_bins, bin_size, pre_time, post_time);

            %% Use code commeneted out below to skip PSTH calculations
            % psth_path = [parsed_path, '/psth'];

            %% Run if you want to graph all of the PSTHs or comment it out to skip
            graph_PSTH(psth_path, animal_name, total_bins, total_trials, total_events, pre_time, post_time);
        end
    end
end