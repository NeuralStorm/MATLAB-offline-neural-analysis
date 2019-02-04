function [] = main()
    start_time = tic;

    %% Initialize global variables
    % bin_size - sets the bin size for the PSTH
    % total_trials - How many times an event was repeated 
    %              --> going to be depricated (still used in neural_trajectories)
    % total_events - Tells the code how many events to look for
    % pre_time & post_time - time window for before and after event, they do not have to be equal
    % wanted_events - Requires for all events to be in array. IF empty it will skip all events
    % trial_range - Inclusive Range, if left empty it will use all available events
    %               Cuts all trials in given session afterwards
    %               ex: [1 300] would look at trials 1 through 300 and ignore any trials afterwards
    % trial_lower_bound - Acts as a lower bound when finding events in the parser --> event channels
    %                     with less than the lower bound will be skipped
    % ignored_animals - Give exact name of directory inside of data directory that you want skipped
    % is_non_strobed_and_strobed - Used to tell the parser if there is both strobed and non strobed animals in the animal set
    %                              If animal set is only strobed -> will use strobed event values
    %                              If animal set is only non-strobed -> will use event channel to label events
    % event_map - Used to map non strobbed animal events to strobed event values -> assumes event channels are in categorical order
    

    %% Nate's tilt project parameters
    % bin_size = 0.002;
    % pre_time = 0.2;
    % post_time = 0.2;
    % total_events = 4;
    % wanted_events = [1, 3, 4, 6];
    % total_trials = 100;
    % trial_range = [1 300];
    % trial_lower_bound = 80;
    % ignored_animals = [];
    % is_non_strobed_and_strobed = true;
    % event_map = [1, 3, 4, 6];

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

    %% Receptive Field Analysis
    % Controls if receptive field analysis is ran
    rf_analysis = true;
    % Span is the number of bins, centered on the current bin the moving average filter will be applied to
    span = 1;
    % threshold_scale determines how the threshold is scaled
    % avg background activity + threshold_scale * standard deviation(background activity)
    threshold_scale = 3;
    % sig_bins determines how many consecutive bins are needed for significant response
    sig_bins = 1;
    % Significant response first checks if there are enough consecutive bins and then applies one of the two tests below
    % 0 = no statistical testing
    % 1 = two-sample t test on pre and post psth; 2 =  unpaired two-sample Kolmogorov-Smirnov test on pre and post psth
    sig_check = 0;

    %% PSTH graphing
    % controls if plots are made
    % If rf_analysis is also true then it will plot the event start, first and last bin latency
    % and the threshold for significant neurons
    make_psth_graphs = true;
    % controls if a single fig is made containing all the units from a given region is made
    % sub_plot requires the scrollsubplot function to be on your matlab path
    % this dependency can be found here: https://www.mathworks.com/matlabcentral/fileexchange/7730-scrollsubplot
    sub_plot = true;
    % determines how many columns are in the subplot
    sub_columns = 3;

    %% Normalized variance (nv) Analysis
    epsilon = 0.01;
    norm_var_scaling = .2;
    separate_events = true;

    %% Information Analysis
    % Boolean to control classification for population or single neurons
    % Default is set to single neuron
    unit_classification = true;
    % controls how many bootstrap iterations are done. Default is 1 (equivalent to single classification)
    boot_iterations = 1;
    spreadsheet_name = 'unit_20ms_spreadsheet.csv';
    append_spreadsheet = false;
    
    %% gpfa
    optimize_state_dimension = true;
    state_dimension = 2;
    prediction_error_dimensions = [3 6 9];
    % Max number of trials plotted on trajectory
    plot_trials = 10;
    % How many dimensions should be used to plot trajectories (2 or 3 dimensions)
    plot_dimensions = 2;
    %% Controls which factors are used in the plot
    dimsToPlot = 1:2;
    
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
                parsed_path = parser(animal_path, animal_name, total_trials, total_events, trial_lower_bound, ...
                    is_non_strobed_and_strobed, event_map);
                %% Use the code commented out below to skip parsing
                parsed_path = [animal_path, '/parsed_plx'];
                
                %% Creates labeled neurons
                label_neurons(animal_path, animal_name, parsed_path);
                
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
                        pre_time, post_time, rf_analysis, rf_path, sub_plot, sub_columns)
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
                % [nv_calc_path, nv_csv_path] = nv_calculation(original_path, psth_path, animal_name, pre_time, post_time, ...
                %     bin_size, epsilon, norm_var_scaling, first_iteration, separate_events);

                %% Misc Functions
                % intertrial_anlysis(original_path, animal_name, psth_path, bin_size, pre_time, post_time, first_iteration)
                %% Euclidian function call
                % euclidian_path = unit_euclidian_psth(original_path, psth_path, animal_name, pre_time, post_time, total_bins, first_iteration);
                %% Trajectory analysis
                %TODO remove event strings parameter
                % neural_trajectory_analysis(original_path, animal_name, psth_path, bin_size, total_trials, total_bins, pre_time, post_time, ...
                %     event_strings, optimize_state_dimension, state_dimension, prediction_error_dimensions, plot_trials, plot_dimensions, dimsToPlot);
                
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