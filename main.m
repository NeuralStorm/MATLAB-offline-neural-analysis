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
% ignore_animal - Boolean set in config file to ignore animal or not

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

% nv_analysis      - Controls if normalized variance is calculated
%                      - nv_analysis = true: calculates the normalized variance
%                      - nv_analysis = false: does not do calculate the normalized variance
% epsilon          - Used to prevent accidental division by 0
% norm_var_scaling - Used to scale the normalized variance depending on filter
% separate_events  - Determines whether or not the event sets are combined or not for the normalized variance
%                   typically you will want to keep events separated

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%     PSTH Classification    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% psth_classify        - Controls if psth classification is ran
%                          - psth_classify = true: classifies region population and unit data
%                          - psth_classify = false: does not classify the data
% bootstrap_classifier - Controls if psth classification is ran
%                          - True: bootstraps region population and unit data
%                          - False: does not bootstrap the data
% boot_iterations      - Sets how many bootstrap iterations are done (1 = classification only)
% calc_syn_red         - Contols if synergy redundancy calculation is made based on classification
% bootstrap_classifier - Controls if psth classification is ran
%                          - True: uses corrected information found from bootstrapping
%                          - False: Uses classifier information

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Information Analysis    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% info_analysis - Controls if mutual information is calculated for dataset
%                   - True: Finds mutual info analysis
%                   - False: Skips mutual info analysis

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%                                START OF CODE                                         %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = main()
    % Get the directory with all animals and their respective .plx files
    original_path = uigetdir(pwd);
    start_time = tic;
    animal_list = dir(original_path);
    animal_names = {animal_list([animal_list.isdir] == 1 & ~contains({animal_list.name}, '.')).name};
    first_iteration = true;
    for animal = 1:length(animal_names)
        animal_name = animal_names{animal};
        animal_path = fullfile(...
            animal_list(strcmpi(animal_names{animal}, {animal_list.name})).folder, animal_name);
        config = import_config(animal_path);
        total_bins = (length(-abs(config.pre_time):config.bin_size:abs(config.post_time)) - 1);
        export_params(animal_path, 'main', config);
        % Skips animals we want to ignore
        if config.ignore_animal
            continue;
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Parser           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %! Needs to stay as is so that file paths for plx files are able to be passed into
            %! plexon offline sdk
            parsed_path = [animal_path, '/parsed_plx'];
            if config.parse_files
                parsed_path = parser(animal_path, animal_name, config.total_trials, ...
                    config.total_events, config.trial_lower_bound, ...
                    config.is_non_strobed_and_strobed, config.event_map);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%       Label Channels       %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.label_channels
                label_neurons(animal_path, animal_name, parsed_path);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%        Format PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            psth_path = [parsed_path, '/psth'];
            if config.create_psth
                psth_start = tic;
                % warning('Since the pre time is set to 0, there will not be a psth generated with only the pre time activity.\n');
                [parsed_files, psth_path, failed_path] = create_dir(parsed_path, 'psth', '.mat');

                fprintf('Calculating PSTH for %s \n', animal_name);
                %% Goes through all the files and creates PSTHs according to the parameters set in config
                for file_index = 1:length(parsed_files)
                    file = [parsed_path, '/', parsed_files(file_index).name];
                    [~, filename, ~] = fileparts(file);
                    load(file, 'event_ts', 'labeled_neurons');
                    try
                        [event_struct, event_ts, event_strings] = ...
                            format_PSTH(event_ts, labeled_neurons, config.bin_size, config.pre_time, ...
                            config.post_time, config.wanted_events, config.trial_range, config.trial_lower_bound);
                        filename = ['PSTH_format_', filename, '.mat'];
                        matfile = fullfile(psth_path, filename);

                        % if isempty(label_neurons) || isempty(event_struct) || isempty(event_strings)
                        %     warning('PSTH does not contain any information about units or events. Skipping File.');
                        %     if exist(file, 2)
                        %         delete(file);
                        %     end
                        %     continue
                        % end


                        save(matfile, 'event_struct', 'event_ts', 'event_strings', 'labeled_neurons');
                        export_params(psth_path, 'format_psth', parsed_path, failed_path, animal_name, config);
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                fprintf('Finished calculating PSTH for %s. It took %s \n', ...
                    animal_name, num2str(toc(psth_start)));
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            rf_path = [psth_path, '/receptive_field_analysis'];
            if config.rf_analysis
                if abs(config.pre_time) <= 0.050
                    error('Pre time ~= 0 for receptive field analysis. Create psth with pre time > 0.');
                end
                rf_start = tic;
                [psth_files, rf_path, failed_path] = create_dir(psth_path, 'receptive_field_analysis', '.mat');
                general_column_names = {'animal', 'group', 'date', 'record_session', 'pre_time', 'post_time', ...
                    'bin_size', 'sig_check', 'sig_bins', 'span', 'threshold_scale'};
                analysis_column_names = {'region', 'channel', 'event', 'significant', ...
                    'background_rate', 'background_std', 'threshold', 'first_latency', 'last_latency', 'duration', ...
                    'peak_latency', 'peak_response', 'corrected_peak', 'response_magnitude', 'corrected_response_magnitude', ...
                    'total_sig_events', 'principal_event', 'norm_magnitude', 'notes'};
                column_names = [general_column_names, analysis_column_names];

                fprintf('Receptive field analysis for %s \n', animal_name);
                all_neurons = [];
                general_info = table;
                for file_index = 1:length(psth_files)
                    %% pull info from filename and set up file path for analysis
                    file = fullfile(psth_path, psth_files(file_index).name);
                    [~, filename, ~] = fileparts(file);
                    filename = erase(filename, 'PSTH_format_');
                    filename = erase(filename, 'PSTH.format.');
                    [animal_id, experimental_group, ~, session_num, session_date, ~] = get_filename_info(filename);

                    try
                        %% Load needed variables from psth and does the receptive field analysis
                        load(file, 'labeled_neurons', 'event_struct');
                        [sig_neurons, non_sig_neurons] = receptive_field_analysis( ...
                            labeled_neurons, event_struct, config.bin_size, config.threshold_scale, ...
                            config.sig_check, config.sig_bins, config.span, analysis_column_names);

                        %% Capture data to save to csv from current day
                        session_neurons = [sig_neurons; non_sig_neurons];
                        current_general_info = [{animal_id}, {experimental_group}, session_date, ...
                            session_num, config.pre_time, config.post_time, config.bin_size, ...
                            config.sig_check, config.sig_bins, config.span, config.threshold_scale];
                        [general_info, all_neurons] = ...
                            concat_tables(general_column_names, general_info, current_general_info, all_neurons, session_neurons);

                        %% Save receptive field matlab output
                        matfile = fullfile(rf_path, ['rec_field_', filename, '.mat']);
                        save(matfile, 'labeled_neurons', 'sig_neurons', 'non_sig_neurons');
                        export_params(rf_path, 'receptive_field_analysis', rf_path, failed_path, ...
                            animal_name, config);
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                %% CSV export set up

                csv_path = fullfile(original_path, 'receptive_field_results.csv');
                export_csv(csv_path, column_names, general_info, all_neurons);

                fprintf('Finished receptive field analysis for %s. It took %s \n', ...
                    animal_name, num2str(toc(rf_start)));
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                graph_PSTH(psth_path, animal_name, total_bins, config.bin_size, ...
                    config.pre_time, config.post_time, config.rf_analysis, rf_path, config.make_region_subplot, config.sub_columns)
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     Normalized Variance    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            nv_csv_path = fullfile(original_path, 'single_unit_nv.csv');
            if config.nv_analysis
                if abs(config.pre_time) <= 0.050
                    error('Pre time ~= 0 for normalized variance analysis. Create psth with pre time > 0.');
                end
                nv_start = tic;
                [psth_files, nv_path, failed_path] = create_dir(psth_path, 'normalized_variance_analysis', '.mat');
                general_column_names = {'animal', 'group', 'date', 'record_session'};
                analysis_column_names = {'event', 'region', 'channel', 'avg_background_rate', ...
                    'background_var', 'norm_var', 'fano'};
                column_names = [general_column_names, analysis_column_names];

                fprintf('Normalized variance analysis for %s \n', animal_name);
                all_neurons = [];
                general_info = table;
                for file_index = 1:length(psth_files)
                    %% pull info from filename and set up file path for analysis
                    file = fullfile(psth_path, psth_files(file_index).name);
                    [~, filename, ~] = fileparts(file);
                    filename = erase(filename, 'PSTH_format_');
                    filename = erase(filename, 'PSTH.format.');
                    [animal_id, experimental_group, ~, session_num, session_date, ~] = get_filename_info(filename);

                    try
                        load(file, 'labeled_neurons', 'event_struct');
                        neuron_activity = nv_calculation(labeled_neurons, event_struct, config.pre_time, config.post_time, ...
                            config.bin_size, config.epsilon, config.norm_var_scaling, config.separate_events, analysis_column_names);

                        current_general_info = [{animal_name}, {experimental_group}, session_date, session_num];
                        [general_info, all_neurons] = ...
                            concat_tables(general_column_names, general_info, current_general_info, all_neurons, neuron_activity);

                        %% Save analysis results
                        matfile = fullfile(nv_path, ['NV_analysis_', filename, '.mat']);
                        save(matfile, 'labeled_neurons', 'neuron_activity');
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                %% CSV export set up
                csv_path = fullfile(original_path, 'single_unit_nv.csv');
                export_csv(csv_path, column_names, general_info, all_neurons);

                fprintf('Finished receptive field analysis for %s. It took %s \n', ...
                    animal_name, num2str(toc(nv_start)));
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            classify_path = [psth_path, '/classifier'];
            if config.psth_classify
                classifier_start = tic;
                [psth_files, classify_path, failed_path] = create_dir(psth_path, 'classifier', '.mat');

                general_column_names = {'animal', 'group', 'date', 'record_session', 'bin_size', 'pre_time', ...
                    'post_time', 'bootstrap_classifier', 'boot_iterations'};
                analysis_column_names = {'region', 'channel', 'performance', 'mutual_info', ...
                    'boot_info', 'corrected_info', 'synergy_redundancy', 'synergistic', 'notes'};
                column_names = [general_column_names, analysis_column_names];

                fprintf('PSTH classification for %s \n', animal_name);

                pop_config_info = table;
                unit_config_info = table;
                pop_info = [];
                unit_info = [];
                for file_index = 1:length(psth_files)
                    %% pull info from filename and set up file path for analysis
                    file = fullfile(psth_path, psth_files(file_index).name);
                    [~, filename, ~] = fileparts(file);
                    filename = erase(filename, 'PSTH_format_');
                    filename = erase(filename, 'PSTH.format.');
                    [animal_id, experimental_group, ~, session_num, session_date, ~] = get_filename_info(filename);

                    try
                        load(file, 'labeled_neurons', 'event_struct', 'event_ts');

                        %% Classify and bootstrap
                        [unit_struct, pop_struct, pop_table, unit_table] = psth_bootstrapper(labeled_neurons, event_struct, ...
                            event_ts, config.boot_iterations, config.bootstrap_classifier, config.bin_size, ...
                            config.pre_time, config.post_time, analysis_column_names);

                        %% PSTH synergy redundancy
                        if config.calc_syn_red
                            [pop_table] = synergy_redundancy(pop_table, unit_table, config.bootstrap_classifier);
                            pop_column_names = [general_column_names, pop_table.Properties.VariableNames];
                        end

                        current_general_info = [{animal_name}, {experimental_group}, session_date, session_num, ...
                            config.bin_size, config.pre_time, config.post_time, config.bootstrap_classifier, ...
                            config.boot_iterations];
                        [pop_config_info, pop_info] = ...
                            concat_tables(general_column_names, pop_config_info, current_general_info, pop_info, pop_table);
                        [unit_config_info, unit_info] = ...
                            concat_tables(general_column_names, unit_config_info, current_general_info, unit_info, unit_table);

                        matfile = fullfile(classify_path, ['test_psth_classifier_', filename, '.mat']);
                        save(matfile, 'pop_struct', 'unit_struct', 'pop_table', 'unit_table');
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end

                unit_csv_path = fullfile(original_path, 'test_unit_psth_classification_info.csv');
                pop_csv_path = fullfile(original_path, 'test_population_psth_classification_info.csv');

                export_csv(unit_csv_path, column_names, unit_config_info, unit_info);
                export_csv(pop_csv_path, column_names, pop_config_info, pop_info);

                fprintf('Finished PSTH classifier for %s. It took %s \n', ...
                    animal_name, num2str(toc(classifier_start)));
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.info_analysis
                info_start = tic;
                [psth_files, info_path, failed_path] = create_dir(psth_path, 'mutual_info', '.mat');

                fprintf('Mutual Info for %s \n', animal_name);
                %% Goes through all the files and calculates mutual info according to the parameters set in config
                for file_index = 1:length(psth_files)
                    %% pull info from filename and set up file path for analysis
                    file = fullfile(psth_path, psth_files(file_index).name);
                    [~, filename, ~] = fileparts(file);
                    filename = erase(filename, 'PSTH_format_');
                    filename = erase(filename, 'PSTH.format.');

                    try
                        load(file, 'event_struct', 'labeled_neurons');
                        [prob_struct, mi_results] = mutual_info(event_struct, labeled_neurons);

                        %% Saving the file
                        matfile = fullfile(info_path, ['mutual_info_', filename, '.mat']);
                        save(matfile, 'labeled_neurons', 'prob_struct', 'mi_results');
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                fprintf('Finished information analysis for %s. It took %s \n', ...
                    animal_name, num2str(toc(info_start)));
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
            % neural_trajectory_analysis(animal_name, psth_path, bin_size, total_trials, pre_time, post_time, ...
            %     optimize_state_dimension, state_dimension, prediction_error_dimensions, plot_trials, dimsToPlot);
            
            first_iteration = false;
        end
    end
    % z_nv_path = z_score_nv(nv_csv_path, pre_time, post_time, bin_size, epsilon, norm_var_scaling);
    % graph_z_nv(z_nv_path);
    % euclidian_path = fullfile(original_path, 'euclidian.csv');
    % graph_euclidian_psth(original_path, euclidian_path);
    toc(start_time);
end