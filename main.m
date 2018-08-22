function [] = main()
    start_time = tic;
    %% Initialize global variables
    bin_size = 0.002;
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
    % Give exact directory name of the animals you want skipped
    ignored_animals = [];
    total_bins = (length([-abs(pre_time):bin_size:abs(post_time)]) - 1);
    failed = {};
    % Boolean to control classification for population or single neurons
    % Default is set to single neuron
    unit_classification = true;
    % controls how many bootstrap iterations are done. Default is 1 (equivalent to single classification)
    boot_iterations = 5;
    spreadsheet_name = 'unit_20ms_spreadsheet.csv';
    append_spreadsheet = false;
    % Sets the coefficents used for smoothing the PSTHs for each neuron
    %TODO determine to use filter or smooth function
    % filter parameters
    n = 6;
    moving_coeff = ones(n, 1) / n;
    amplitude_coeff = 1;
    % smooth parameters
    span = 3;

    %% Receptive Field Analysis
    % threshold_scale determines how the threshold is scaled
    % avg background activity + threshold_scale * standard deviation(background activity)
    threshold_scale = 1.65;
    % sig_check determines the significance check used to determine if the response was significant
    % 1 = at least 1 greater than threshold; 2 = at least x bins have a firing rate higher than threshold;
    % 3 = at least x bins have a firing rate higher than threshold; 4 = two-sample t test on pre and post psth and 3;
    % 5 =  unpaired two-sample Kolmogorov-Smirnov test on pre and post psth and 3
    sig_check = 4;
    % sig_bins determines how many bins are needed for conditions 2 and 3 for of sig_check
    sig_bins = 5;
    % Sets the filter window to desired length

    
    % Get the directory with all animals and their respective .plx files
    original_path = uigetdir(pwd);
    animal_list = dir(original_path);
    % Starts at index 3 since dir returns '.' and '..'
    if length(animal_list) > 2
        first_iteration = true;
        unit_index = 1;
        for animal = 3: length(animal_list)
            animal_name = animal_list(animal).name;
            animal_path = [animal_list(animal).folder, '/', animal_name];
            % Skips animals we want to ignore
            if ~isempty(ignored_animals) && contains(ignored_animals, animal_name)
                continue;
            elseif isfolder(animal_path)
                %% Run if you want to parse .plx or comment out to skip
                % try
                %     parsed_path = parser(animal_path, animal_name, total_trials, total_events);
                % catch
                %     failed{end+1} = animal_list(animal).name;
                % end
                %% Use the code commented out below to skip parsing
                parsed_path = [animal_path, '/parsed_plx'];

                %% Run if you want to calculate the PSTH or comment it out to skip
                try
                    psth_path = format_PSTH(parsed_path, animal_name, total_bins, bin_size, pre_time, post_time, ...
                        wanted_neurons, wanted_events, trial_range, total_trials);
                    label_neurons(psth_path);
                catch
                    failed{end+1} = animal_list(animal).name;
                end
                %% Use code commeneted out below to skip PSTH calculations
                psth_path = [parsed_path, '/psth'];
                % receptive_field_analysis(psth_path, animal_name, pre_time, post_time, bin_size, total_bins, ...
                %     threshold_scale, sig_check, sig_bins, moving_coeff, amplitude_coeff);

                %% Run if you want to graph all of the PSTHs or comment it out to skip
                % try
                %     graph_PSTH(psth_path, animal_name, total_bins, total_trials, total_events, pre_time, post_time);
                % catch
                %     failed{end+1} = animal_list(animal).name;
                % end

                %% Run for bootstrapping
                % classified_path = crude_bootstrapper(psth_path, animal_name, boot_iterations, bin_size, pre_time, ...
                %     post_time, wanted_events, wanted_neurons, unit_classification);

                %% To skip bootstrapping
                classified_path = [psth_path, '/classifier'];

                % %% Run for synergy redundancy calculation
                % % Checks to make sure that both population and unit information exists
                % unit_path = [classified_path, '/unit'];
                % pop_path = [classified_path, '/population'];
                % if (exist(unit_path, 'dir') == 7) && (exist(pop_path, 'dir') == 7)
                %     synergy_redundancy(classified_path, animal_name);
                % end

                % % %% Write to spreadsheet
                % csv_export(classified_path, original_path, total_events, wanted_events, pre_time, post_time, bin_size, first_iteration, ...
                %     trial_range, boot_iterations, animal_name, total_trials, unit_classification, spreadsheet_name, append_spreadsheet);
                % first_iteration = false;
            end
        end
    end
    toc(start_time);
end