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

    % label_channels - labels channels after files are finished being parsed. If the parser is ran, 
    %                  then this must also be true, but this can be ran to relabel the channels
    %                  as long as the parsed files exist
    %                  - label_channels = true: labels channels according to labels csv (must also be true
    %                                           if parse_files is true)
    %                  - label_channels = false: does not label channels
    % bin_size - sets the bin size for the PSTH
    % pre_time - time window before the event, pre and post times do not have to be equal
    % post_time - time window after event, pre and post times do not have to be equal
    % ignored_animals - Give exact name of directory inside of data directory that you want skipped
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%           Parser           %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % parse_files - Controls if the raw .plx files are parsed -> should only need to parse files once
    %                  - parse_files = true: parses .plx files (label_channels MUST also be true)
    %                  - parse_files = false: skips parsing
    % total_trials - How many times an event was repeated 
    %                going to be depricated (still used in neural_trajectories)
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

    % create_psth - Controls if format_PSTH is ran 
    %                  - create_psth = true: creates PSTH
    %                  - create_psth = false: does not create the PSTH
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

    % nv_analysis - Controls if normalized variance is calculated
    %                  - nv_analysis = true: calculates the normalized variance
    %                  - nv_analysis = false: does not do calculate the normalized variance
    % epsilon - Used to prevent accidental division by 0
    % norm_var_scaling - Used to scale the normalized variance depending on filter
    % separate_events - Determines whether or not the event sets are combined or not for the normalized variance
    %                   typically you will want to keep events separated

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%    Information Analysis    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % info_analysis - Controls if bootstrapping and other forms of information analysis is ran
    %                  - info_analysis = true: bootstraps data
    %                  - info_analysis = false: does not do the information analysis
    % unit_classification - Controls population or single unit classification
    %                     - True: unit classification
    %                     - False: population classification
    % boot_iterations - Sets how many bootstrap iterations are done (1 = classification only)

    %%%%%%%%%%%%%%%%%%%%%%%
    %%   NOT READY YET   %%
    %%%%%%%%%%%%%%%%%%%%%%%

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
    % label_channels = false;
    % bin_size = 0.02;
    % pre_time = 0;
    % post_time = 0.2;
    % ignored_animals = [];
    % %% Parser
    % parse_files = false;
    % total_trials = 100;
    % trial_lower_bound = 80;
    % is_non_strobed_and_strobed = true;
    % total_events = 4;
    % event_map = [1, 3, 4, 6];
    % %% Format PSTH
    % create_psth = false;
    % trial_range = [1 300];
    % wanted_events = [1, 3, 4, 6];
    % %% Receptive Field Analysis
    % rf_analysis = false;
    % span = 3;
    % threshold_scale = 1.65;
    % sig_bins = 3;
    % sig_check = 1;
    % %% Graph PSTH
    % make_psth_graphs = false;
    % make_region_subplot = true;
    % sub_columns = 4;
    % %% Normalized Variance
    % nv_analysis = false;
    % epsilon = 0.01;
    % norm_var_scaling = .2;
    % separate_events = true;
    % %% Information Analysis
    % info_analysis = true;
    % unit_classification = false;
    % boot_iterations = 5;
    % %%%%%%%%%%%%%%%%%%%%%%%
    % %%   NOT READY YET   %%
    % %%%%%%%%%%%%%%%%%%%%%%%
    % %% GPFA
    % optimize_state_dimension = true;
    % prediction_error_dimensions = [3 6 9];
    % state_dimension = 2;
    % plot_trials = 10;
    % dimsToPlot = 1:2;


    %% Pain Project parameters
    %% Global
    label_channels = true;
    bin_size = 0.005;
    pre_time = 0.2;
    post_time = 0.1;
    ignored_animals = [];
    %% Parser
    parse_files = true;
    total_trials = 100;
    trial_lower_bound = 50;
    total_events = 2;
    is_non_strobed_and_strobed = false;
    event_map = [];
    %% Format PSTH
    create_psth = true;
    trial_range = [];
    wanted_events = [];
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
    %% Normalized Variance
    nv_analysis = false;
    epsilon = 0.01;
    norm_var_scaling = .2;
    separate_events = true;
    %%%%%%%%%%%%%%%%%%%%%%%
    %%   NOT READY YET   %%
    %%%%%%%%%%%%%%%%%%%%%%%
    % %% Information Analysis
    % info_analysis = false;
    % unit_classification = true;
    % boot_iterations = 1;
    % optimize_state_dimension = true;
    % prediction_error_dimensions = [3 6 9];
    % state_dimension = 2;
    % plot_trials = 10;
    % dimsToPlot = 1:2;


    %% Francois
    % Global
    % label_channels = true;
    % bin_size = 0.005;
    % pre_time = 0.2;
    % post_time = 0.1;
    % ignored_animals = [];
    % Parser
    % parse_files = true;
    % total_trials = 100;
    % trial_lower_bound = 50;
    % is_non_strobed_and_strobed = false;
    % total_events = 2;
    % event_map = [];
    % Format PSTH
    % create_psth = true;
    % trial_range = [];
    % wanted_events = [193, 194, 195, 196];
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
    % nv_analysis = false;
    % epsilon = 0.01;
    % norm_var_scaling = .2;
    % separate_events = true;
    %%%%%%%%%%%%%%%%%%%%%%%
    %%   NOT READY YET   %%
    %%%%%%%%%%%%%%%%%%%%%%%
    % %% Information Analysis
    % info_analysis = false;
    % unit_classification = true;
    % boot_iterations = 1;
    % %%GPFA
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
            %TODO add check to see if isfolder is a valid function -> if not have it tell people to change to isdir
            elseif isfolder(animal_path)
readVariables(original_path, label_channels, pre_time, post_time,bin_size, ignored_animals) % readVariable function reads the parameters from main.m  
                                                                                            % then outputs them to an excel file
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%           Parser           %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                parsed_path = [animal_path, '/parsed_plx'];
                if parse_files
                    parsed_path = parser(animal_path, animal_name, total_trials, total_events, trial_lower_bound, ...
                        is_non_strobed_and_strobed, event_map);
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%       Label Channels       %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if label_channels
                    label_neurons(animal_path, animal_name, parsed_path);
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%        Format PSTH         %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                psth_path = [parsed_path, '/psth'];
                if create_psth
                    psth_path = format_PSTH(parsed_path, animal_name, total_bins, bin_size, pre_time, post_time, ...
                        wanted_events, trial_range);
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%  Receptive Field Analysis  %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                rf_path = [psth_path, '/receptive_field_analysis'];
                if rf_analysis
                    rf_path = receptive_field_analysis(original_path, psth_path, animal_name, pre_time, post_time, bin_size, ...
                        threshold_scale, sig_check, sig_bins, span, first_iteration);
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%         Graph PSTH         %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if make_psth_graphs
                    graph_PSTH(psth_path, animal_name, total_bins, bin_size, ...
                        pre_time, post_time, rf_analysis, rf_path, make_region_subplot, sub_columns)
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%     Normalized Variance    %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                nv_csv_path = fullfile(original_path, 'single_unit_nv.csv');
                if nv_analysis
                    [nv_calc_path, nv_csv_path] = nv_calculation(original_path, psth_path, animal_name, pre_time, post_time, ...
                    bin_size, epsilon, norm_var_scaling, first_iteration, separate_events);
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%    Information Analysis    %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                classified_path = [psth_path, '/classifier'];
                if info_analysis
                    classified_path = crude_bootstrapper(original_path, first_iteration, psth_path, animal_name, boot_iterations, bin_size, pre_time, ...
                        post_time, unit_classification);
                end

                %TODO Reimplement synergy redundancy calculation
                %% Misc Functions
                %% Run for synergy redundancy calculation
                % Checks to make sure that both population and unit information exists
                % unit_path = [classified_path, '/unit'];
                % pop_path = [classified_path, '/population'];
                % if (exist(unit_path, 'dir') == 7) && (exist(pop_path, 'dir') == 7)
                %     synergy_redundancy(classified_path, animal_name);
                % end

                % intertrial_anlysis(original_path, animal_name, psth_path, bin_size, pre_time, post_time, first_iteration)
                %% Euclidian function call
                % euclidian_path = unit_euclidian_psth(original_path, psth_path, animal_name, pre_time, post_time, total_bins, first_iteration);
                %% Trajectory analysis
                % neural_trajectory_analysis(original_path, animal_name, psth_path, bin_size, total_trials, total_bins, pre_time, post_time, ...
                %     optimize_state_dimension, state_dimension, prediction_error_dimensions, plot_trials, dimsToPlot);
                
                first_iteration = false;
            end
        end
    end
    % z_nv_path = z_score_nv(nv_csv_path, pre_time, post_time, bin_size, epsilon, norm_var_scaling);
    % graph_z_nv(z_nv_path);
    % euclidian_path = fullfile(original_path, 'euclidian.csv');
    % graph_euclidian_psth(original_path, euclidian_path);
    toc(start_time);
end