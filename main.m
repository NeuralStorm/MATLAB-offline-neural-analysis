function [] = main()
    start_time = tic;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%                              START OF PARAMETERS                                     %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%      Global Variables      %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % bin_size - sets the bin size for the PSTH
    % pre_time - time window before the event, pre and post times do not have to be equal
    % post_time - time window after event, pre and post times do not have to be equal
    % ignored_animals - Give exact name of directory inside of data directory that you want skipped
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%           Parser           %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % total_trials - How many times an event was repeated 
    %              --> going to be depricated (still used in neural_trajectories)
    % total_events - Tells the code how many events to look for
    % trial_lower_bound - Acts as a lower bound when finding events in the parser --> event channels
    %                     with less than the lower bound will be skipped
    % is_non_strobed_and_strobed - Used to tell the parser if there is both strobed and non strobed animals in the animal set
    %                              If animal set is only strobed -> will use strobed event values
    %                              If animal set is only non-strobed -> will use event channel to label events
    % event_map - Used to map non strobbed animal events to strobed event values -> assumes event channels are in categorical order

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%        Format PSTH         %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % wanted_events - If left empty, wanted_events will default to all events above lower threshold.
    %                 To select specific events, you must know the specific channel the event happened in
    % trial_range - Inclusive Range, if left empty it will use all available events
    %               Cuts all trials in given session afterwards
    %               ex: [1 300] would look at trials 1 through 300 and ignore any trials afterwards

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%  Receptive Field Analysis  %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % rf_analysis - Controls if receptive field analysis is ran
    % span - number of bins, centered on the current bin the moving average filter will be applied to
    % threshold_scale - avg background activity + threshold_scale * standard deviation(background activity)
    % sig_bins - determines how many consecutive bins are needed for significant response
    % sig_check - Significant response first checks if there are enough consecutive bins and then applies one of the two tests below
    %          - 0 = no statistical testing;
    %          - 1 = two-sample t test on pre and post psth;
    %          - 2 = unpaired two-sample Kolmogorov-Smirnov test on pre and post psth

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%         Graph PSTH         %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % make_psth_graphs - Controls if PSTH plots are made. 
    %                  - rf_analysis = true: plot the PSTH with event start and
    %                       - Significant neurons: event start, threshold, first, and last bin latency
    %                       - Nonsignificant neurons: event start and threshold
    %                  - rf_analysis = false: plot PSTH with event start
    % make_region_subplot - Controls if a .fig image is made with all the PSTHs from a given region is created
    %                     - True: will make the region subplots, but requires scrollsubplot as a dependency.
    %                     - the dependency can be found here: https://www.mathworks.com/matlabcentral/fileexchange/7730-scrollsubplot
    % sub_columns - determines how many columns are in the subplot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%     Normalized Variance    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % See Churchland et al. 2006: "Neural Variability in Premotor Cortex Provides a Signature ofMotor Preparation"
    % For more details about how to choose epsilon and norm_var_scaling (or c in equatioon 2)
    % epsilon - Used to prevent accidental division by 0
    % norm_var_scaling - Used to scale the normalized variance depending on filter
    % separate_events - Determines whether or not the event sets are combined or not for the normalized variance
    %                 - typically you will want to keep events separated

    %%%%%%%%%%%%%%%%%%%%%%%
    %%   NOT READY YET   %%
    %%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%    Information Analysis    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % unit_classification - Controls population or single unit classification
    %                     - True: unit classification
    %                     - False: population classification
    % boot_iterations - Sets how many bootstrap iterations are done (1 = classification only)
    % spreadsheet_name - sets the spreadsheet name
    % append_spreadhsheet - controls if previous data set is appended overwritten if same file exists
    %                     - True: Appends new data to existing spreadsheet
    %                     - False: Overwrites existing spreadsheet

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%            GPFA            %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % optimize_state_dimension - Boolean for determining if it should find optimal state dimension
    %                          - True: Optimizes for state dimension using the prediction_error_dimensions
    %                          - False: Skips optimizing for state dimensionality
    % prediction_error_dimensions - 1XN matrix with a list of dimensions you want to test
    % state_dimension - The dimension you want to run GPFA on
    % plot_trials - Determines how many trials are plotted on a given GPFA plot
    % dimsToPlot - Coontrols which factors are plotted

    %% Nate's tilt project parameters
    %%  Global
    % bin_size = 0.002;
    % pre_time = 0.2;
    % post_time = 0.2;
    % ignored_animals = [];
    % %% Parser
    % total_trials = 100;
    % trial_lower_bound = 80;
    % total_events = 4;
    % is_non_strobed_and_strobed = true;
    % event_map = [1, 3, 4, 6];
    % %% Format PSTH
    % trial_range = [1 300];
    % wanted_events = [];
    % %% Receptive Field Analysis
    % rf_analysis = true;
    % span = 3;
    % threshold_scale = 1.65;
    % sig_bins = 3;
    % sig_check = 1;
    % %% Graph PSTH
    % make_psth_graphs = false;
    % make_region_subplot = true;
    % sub_columns = 4;
    % %% Normalized Variance
    % epsilon = 0.01;
    % norm_var_scaling = .2;
    % separate_events = true;
    %%%%%%%%%%%%%%%%%%%%%%%
    %%   NOT READY YET   %%
    %%%%%%%%%%%%%%%%%%%%%%%
    % %% Information Analysis
    % unit_classification = true;
    % boot_iterations = 1;
    % spreadsheet_name = 'unit_20ms_spreadsheet.csv';
    % append_spreadsheet = false;
    % optimize_state_dimension = true;
    % prediction_error_dimensions = [3 6 9];
    % state_dimension = 2;
    % plot_trials = 10;
    % dimsToPlot = 1:2;


    %% Pain Project parameters
    bin_size = 0.005;
    pre_time = 0.2;
    post_time = 0.1;
    total_events = 2;
    wanted_events = [];
    total_trials = 100;
    trial_lower_bound = 50;
    trial_range = [];
    ignored_animals = [];
    is_non_strobed_and_strobed = false;
    event_map = [];
    %% Receptive Field Analysis
    rf_analysis = true;
    span = 1;
    threshold_scale = 3;
    sig_bins = 1;
    sig_check = 0;
    %% Graph PSTH
    make_psth_graphs = true;
    make_region_subplot = true;
    sub_columns = 3;
    % %% Normalized Variance
    % epsilon = 0.01;
    % norm_var_scaling = .2;
    % separate_events = true;
    %%%%%%%%%%%%%%%%%%%%%%%
    %%   NOT READY YET   %%
    %%%%%%%%%%%%%%%%%%%%%%%
    % %% Information Analysis
    % unit_classification = true;
    % boot_iterations = 1;
    % spreadsheet_name = 'unit_20ms_spreadsheet.csv';
    % append_spreadsheet = false;
    % optimize_state_dimension = true;
    % prediction_error_dimensions = [3 6 9];
    % state_dimension = 2;
    % plot_trials = 10;
    % dimsToPlot = 1:2;


    %% Francois
    % bin_size = 0.005;
    % pre_time = 0.2;
    % post_time = 0.1;
    % total_events = 2;
    % wanted_events = [193, 194, 195, 196];
    % total_trials = 100;
    % trial_lower_bound = 50;
    % trial_range = [];
    % ignored_animals = [];
    % is_non_strobed_and_strobed = false;
    % event_map = [];
    % %% Receptive Field Analysis
    % rf_analysis = true;
    % span = 1;
    % threshold_scale = 3;
    % sig_bins = 1;
    % sig_check = 0;
    % %% Graph PSTH
    % make_psth_graphs = true;
    % make_region_subplot = true;
    % sub_columns = 3;
    % %% Normalized Variance
    % epsilon = 0.01;
    % norm_var_scaling = .2;
    % separate_events = true;
    %%%%%%%%%%%%%%%%%%%%%%%
    %%   NOT READY YET   %%
    %%%%%%%%%%%%%%%%%%%%%%%
    % %% Information Analysis
    % unit_classification = true;
    % boot_iterations = 1;
    % spreadsheet_name = 'unit_20ms_spreadsheet.csv';
    % append_spreadsheet = false;
    % optimize_state_dimension = true;
    % prediction_error_dimensions = [3 6 9];
    % state_dimension = 2;
    % plot_trials = 10;
    % dimsToPlot = 1:2;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%                                START OF CODE                                         %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Automatic Variable Creation DO NOT CHANGE
    total_bins = (length([-abs(pre_time):bin_size:abs(post_time)]) - 1);
    % Get the directory with all animals and their respective .plx files
    original_path = uigetdir(pwd);
    animal_list = dir(original_path);   
    % Starts at index 3 since dir returns '.' and '..'
    if length(animal_list) > 2
        first_iteration = true;
        unit_index = 1;
        for animal = 3:length(animal_list)
            animal_name = animal_list(animal).name;
            animal_path = [animal_list(animal).folder, '/', animal_name];
            % Skips animals we want to ignore
            if ~isempty(ignored_animals) && contains(ignored_animals, animal_name)
                continue;
            elseif isfolder(animal_path)
                %% Run if you want to parse .plx or comment out to skip
                % parsed_path = parser(animal_path, animal_name, total_trials, total_events, trial_lower_bound, ...
                %     is_non_strobed_and_strobed, event_map);
                %% Use the code commented out below to skip parsing
                parsed_path = [animal_path, '/parsed_plx'];
                
                %% Creates labeled neurons
                % label_neurons(animal_path, animal_name, parsed_path);
                
                %% Run if you want to calculate the PSTH or comment it out to skip
                psth_path = format_PSTH(parsed_path, animal_name, total_bins, bin_size, pre_time, post_time, ...
                    wanted_events, trial_range);
                %% Use code commeneted out below to skip PSTH calculations
                psth_path = [parsed_path, '/psth'];

                %% Use to run receptive field analysis
                if rf_analysis
                    rf_path = receptive_field_analysis(original_path, psth_path, animal_name, pre_time, post_time, bin_size, ...
                        threshold_scale, sig_check, sig_bins, span, first_iteration);
                end
                rf_path = [psth_path, '/receptive_field_analysis'];
                
                %% Run if you want to graph all of the PSTHs or comment it out to skip
                if make_psth_graphs
                    graph_PSTH(psth_path, animal_name, total_bins, bin_size, ...
                        pre_time, post_time, rf_analysis, rf_path, make_region_subplot, sub_columns)
                end
                
                %% Information Analysis
                %% Run for bootstrapping
                % classified_path = crude_bootstrapper(psth_path, animal_name, boot_iterations, bin_size, pre_time, ...
                %     post_time, wanted_events, unit_classification);
                
                %% To skip bootstrapping
                classified_path = [psth_path, '/classifier'];
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
                
                
                %% NV analysis
                nv_csv_path = fullfile(original_path, 'single_unit_nv.csv');
                [nv_calc_path, nv_csv_path] = nv_calculation(original_path, psth_path, animal_name, pre_time, post_time, ...
                    bin_size, epsilon, norm_var_scaling, first_iteration, separate_events);

                %% Misc Functions
                % intertrial_anlysis(original_path, animal_name, psth_path, bin_size, pre_time, post_time, first_iteration)
                %% Euclidian function call
                % euclidian_path = unit_euclidian_psth(original_path, psth_path, animal_name, pre_time, post_time, total_bins, first_iteration);
                %% Trajectory analysis
                %TODO remove event strings parameter
                % neural_trajectory_analysis(original_path, animal_name, psth_path, bin_size, total_trials, total_bins, pre_time, post_time, ...
                %     optimize_state_dimension, state_dimension, prediction_error_dimensions, plot_trials, dimsToPlot);
                
                first_iteration = false;
            end
        end
    end
    z_nv_path = z_score_nv(nv_csv_path, pre_time, post_time, bin_size, epsilon, norm_var_scaling);
    graph_z_nv(z_nv_path);
    % euclidian_path = fullfile(original_path, 'euclidian.csv');
    % graph_euclidian_psth(original_path, euclidian_path);
    toc(start_time);
end