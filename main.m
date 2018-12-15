function [] = main()
    start_time = tic;
    %% Initialize global variables
    bin_size = 0.020;
    total_trials = 100;
    total_events = 4;
    pre_time = 0.2;
    post_time = 0.2;
    total_bins = (length([-abs(pre_time):bin_size:abs(post_time)]) - 1);
    % Requires for all events to be in array. IF empty it will skip all events
    wanted_events = [1, 3, 4, 6];
        % Creates a cell array of strings with the names of all the desired events
    event_strings = {};
    for i = 1: length(wanted_events)
        event_strings{end+1} = ['event_', num2str(wanted_events(i))];
    end
    % Inclusive Range
    trial_range = [1, 300];
    % Give exact directory name of the animals you want skipped
    ignored_animals = [];
    % Boolean to control classification for population or single neurons
    % Default is set to single neuron
    unit_classification = true;
    % controls how many bootstrap iterations are done. Default is 1 (equivalent to single classification)
    boot_iterations = 1;
    spreadsheet_name = 'unit_20ms_spreadsheet.csv';
    append_spreadsheet = false;

    %% Receptive Field Analysis
    rf_analysis = false;
    % Span is the number of bins, centered on the current bin the moving average filter will be applied to
    span = 3;
    % threshold_scale determines how the threshold is scaled
    % avg background activity + threshold_scale * standard deviation(background activity)
    threshold_scale = 1.65;
    % Significant response first checks if there are enough consecutive bins and then applies one of the two tests below
    % 1 = two-sample t test on pre and post psth; 2 =  unpaired two-sample Kolmogorov-Smirnov test on pre and post psth
    sig_check = 1;
    % sig_bins determines how many consecutive bins are needed for significant response
    sig_bins = 5;


    %% Normalized variance (nv) Analysis
    epsilon = 0.01;
    norm_var_scaling = (span * bin_size);
    % List of where all the nv analysis result files are stored for population analysis at the end
    nv_list = [];

    %% gpfa
    optimize_state_dimension = false;
    state_dimension = 2;
    prediction_error_dimensions = [3 6 9];
    % Max number of trials plotted on trajectory
    plot_trials = 10;
    % How many dimensions should be used to plot trajectories (2 or 3 dimensions)
    plot_dimensions = 2;
    %% Controls which factors are used in the plot
    dimsToPlot = 1:2;

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
                %    parsed_path = parser(animal_path, animal_name, total_trials, total_events);
                % end
                %% Use the code commented out below to skip parsing
                parsed_path = [animal_path, '/parsed_plx'];

                %% Creates labeled neurons
                % label_neurons(animal_path, animal_name, parsed_path);

                %% Run if you want to calculate the PSTH or comment it out to skip
                try
                    % psth_path = format_PSTH(parsed_path, animal_name, total_bins, bin_size, pre_time, post_time, ...
                    %     wanted_events, trial_range, total_trials);
                end
                %% Use code commeneted out below to skip PSTH calculations
                psth_path = [parsed_path, '/psth'];
                %% Euclidian function call
                euclidian_path = unit_euclidian_psth(original_path, psth_path, animal_name, first_iteration);
                %% Trajectory analysis
                % neural_trajectory_analysis(original_path, animal_name, psth_path, bin_size, total_trials, total_bins, pre_time, post_time, ...
                %     event_strings, optimize_state_dimension, state_dimension, prediction_error_dimensions, plot_trials, plot_dimensions, dimsToPlot);

                %% Use to run receptive field analysis
                % if rf_analysis
                %     try
                        % rf_path = receptive_field_analysis(psth_path, animal_name, pre_time, post_time, bin_size, total_bins, ...
                        %     threshold_scale, sig_check, sig_bins, span, wanted_events);
                %     end
                % end

                %% Use code commeneted out below to skip RF analysis calculations
                rf_path = [psth_path, '/receptive_field_analysis'];

                % [nv_calc_path, region_channels, event_strings] = nv_calculation(psth_path, animal_name, pre_time, post_time, bin_size, span, epsilon, norm_var_scaling);

                % nv_path = normalized_variance_analysis(nv_calc_path, animal_name, wanted_events, region_channels, event_strings);
                % nv_calc_path = [psth_path, '/normalized_variance_analysis'];
                % nv_path = [nv_calc_path, '/nv_results'];
                % nv_list = [nv_list; {nv_path}];

                %% Run if you want to graph all of the PSTHs or comment it out to skip
                % try
                %    graph_PSTH(psth_path, animal_name, total_bins, total_trials, total_events, bin_size, pre_time, post_time, rf_analysis, rf_path, span);
                % end

                %% Run for bootstrapping
                % classified_path = crude_bootstrapper(psth_path, animal_name, boot_iterations, bin_size, pre_time, ...
                %     post_time, wanted_events, unit_classification);

                %% To skip bootstrapping
                classified_path = [psth_path, '/classifier'];
                % neural_trajectory_analysis(original_path, animal_name, psth_path, spreadsheet_name, bin_size, total_trials, total_bins, pre_time, post_time, event_strings);
                %% Run for synergy redundancy calculation
                % Checks to make sure that both population and unit information exists
                % unit_path = [classified_path, '/unit'];
                % pop_path = [classified_path, '/population'];
                % if (exist(unit_path, 'dir') == 7) && (exist(pop_path, 'dir') == 7)
                %     synergy_redundancy(classified_path, animal_name);
                % end

                % % %% Write to spreadsheet
                % csv_export(classified_path, original_path, total_events, wanted_events, pre_time, post_time, bin_size, first_iteration, ...
                %     trial_range, boot_iterations, animal_name, total_trials, unit_classification, spreadsheet_name, append_spreadsheet);
                first_iteration = false;
            end
        end
    end
    % group_nv_path = graph_nv(nv_list, event_strings, original_path);
    % graph_z_score_nv(group_nv_path);
    % graph_euclidian_psth(original_path, euclidian_path);
    toc(start_time);
end