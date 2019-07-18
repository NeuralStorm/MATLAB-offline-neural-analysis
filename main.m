%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%      Global Variables      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% bin_size      - sets the bin size for the PSTH
% pre_time      - time window before the event, pre and post times do not have to be equal
% post_time     - time window after event, pre and post times do not have to be equal
% ignore_animal - Boolean set in config file to ignore animal or not

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%           Parser           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MUST BE RAN AT LEAST ONCE
% parse_files                - Controls if the raw .plx files are parsed -> should only need to parse files once
%                                 - parse_files = true: parses .plx files (label_channels MUST also be true)
%                                 - parse_files = false: skips parsing
% total_trials               - How many times an event was repeated 
%                              going to be depricated (still used in neural_trajectories)
% total_events               - Tells the code how many events to look for
% trial_lower_bound          - Acts as a lower bound when finding events in the parser --> event channels
%                              with less than the lower bound will be skipped
% is_non_strobed_and_strobed - Used to tell the parser if there is both strobed and non strobed animals in the animal set
%                              If animal set is only strobed -> will use strobed event values
%                              If animal set is only non-strobed -> will use event channel to label events
% event_map                  - Used to map non strobbed animal events to strobed event values -> assumes event channels are in categorical order

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%           Labeler          %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MUST BE RAN AT LEAST ONCE
% label_channels - labels channels after files are finished being parsed. If the parser is ran, 
%                  then this must also be true, but this can be ran to relabel the channels
%                  as long as the parsed files exist
%                  - True: labels channels according to labels csv (must also be trueif parse_files is true)
%                  - False: does not label channels

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%        Format PSTH         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create_psth   - Controls if format_PSTH is ran 
%                   - True: creates PSTH according to pre time, post time, and bin size
%                   - False: does not create the PSTH
% wanted_events - If left empty, wanted_events will default to all events above lower threshold.
%                 To select specific events, you must know the specific channel the event happened in
% trial_range   - Inclusive Range, if left empty it will use all available events
%               Cuts all trials in given session afterwards
%               ex: [1 300] would look at trials 1 through 300 and ignore any trials afterwards

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Receptive Field Analysis  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% rf_analysis     - Controls if receptive field analysis is ran
% span            - number of bins, centered on the current bin the moving average filter will be applied to
% threshold_scale - avg background activity + threshold_scale * standard deviation(background activity)
% sig_bins        - determines how many consecutive bins are needed for significant response
% sig_check       - Significant response first checks if there are enough consecutive bins and then applies one of the two tests below
%                     - 0 = no statistical testing;
%                     - 1 = two-sample t test on pre and post psth;
%                     - 2 = unpaired two-sample Kolmogorov-Smirnov test on pre and post psth

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%         Graph PSTH         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make_psth_graphs    - Controls if PSTH plots are made. 
%                     - rf_analysis = true: plot the PSTH with event start and
%                          - Significant neurons: event start, threshold, first, and last bin latency
%                          - Nonsignificant neurons: event start and threshold
%                     - rf_analysis = false: plot PSTH with event start
% make_region_subplot - Controls if a .fig image is made with all the PSTHs from a given region is created
%                         - True: will make the region subplots, but requires scrollsubplot as a dependency.
%                           the dependency can be found here: https://www.mathworks.com/matlabcentral/fileexchange/7730-scrollsubplot
%                         - False: Does not make region subplots
% sub_columns         - determines how many columns are in the subplot

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
%                    typically you will want to keep events separated

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%     PSTH Classification    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% psth_classify        - Controls if psth classification is ran
%                          - psth_classify = true: classifies region population and unit data
%                          - psth_classify = false: does not classify the data
% bootstrap_classifier - Controls if psth classification is ran
%                          - True: bootstraps region population and unit data
%                          - False: does not bootstrap the data
% boot_iterations      - Sets how many bootstrap iterations are done
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
    %% Get directory with all animals and their data
    original_path = uigetdir(pwd);
    start_time = tic;
    animal_list = dir(original_path);
    animal_names = {animal_list([animal_list.isdir] == 1 & ~contains({animal_list.name}, '.')).name};
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
            if config.parse_files
                %% Parse files
                %! Might remove the file handling in the future
                parsed_path = parser(animal_path, animal_name, config.total_trials, ...
                    config.total_events, config.trial_lower_bound, ...
                    config.is_non_strobed_and_strobed, config.event_map);
            else
                parsed_path = [animal_path, '/parsed'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%       Label Channels       %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.label_channels
                %% Label channels
                %! Might remove the file handling in the future
                label_neurons(animal_path, animal_name, parsed_path);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%        Format PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.create_psth
                psth_start = tic;
                % warning('Since the pre time is set to 0, there will not be a psth generated with only the pre time activity.\n');
                [parsed_files, psth_path, failed_path] = create_dir(parsed_path, 'psth', '.mat');

                fprintf('Calculating PSTH for %s \n', animal_name);
                %% Goes through all the files and creates PSTHs according to the parameters set in config
                for file_index = 1:length(parsed_files)
                    try
                        %% Load file contents
                        file = [parsed_path, '/', parsed_files(file_index).name];
                        [~, filename, ~] = fileparts(file);
                        load(file, 'event_ts', 'labeled_neurons');
                        %% Check parsed variables to make sure they are not empty
                        empty_vars = check_variables(file, event_ts, labeled_neurons);
                        if empty_vars
                            continue
                        end

                        %% Format PSTH
                        [event_struct, event_ts, event_strings] = ...
                            format_PSTH(event_ts, labeled_neurons, config.bin_size, config.pre_time, ...
                            config.post_time, config.wanted_events, config.trial_range, config.trial_lower_bound);

                        %% Saving outputs
                        matfile = fullfile(psth_path, ['PSTH_format_', filename, '.mat']);
                        %% Check PSTH output to make sure there are no issues with the output
                        empty_vars = check_variables(matfile, event_struct, event_ts, event_strings);
                        if empty_vars
                            continue
                        end

                        %% Save file if all variables are not empty
                        save(matfile, 'event_struct', 'event_ts', 'event_strings', 'labeled_neurons');
                        export_params(psth_path, 'format_psth', parsed_path, failed_path, animal_name, config);
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                fprintf('Finished calculating PSTH for %s. It took %s \n', ...
                    animal_name, num2str(toc(psth_start)));
            else
                psth_path = [parsed_path, '/psth'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.rf_analysis
                rf_path = batch_recfield(animal_name, original_path, psth_path, 'receptive_field_analysis', ...
                    '.mat', 'PSTH', 'format', config);
            else
                rf_path = [psth_path, '/receptive_field_analysis'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, psth_path, 'psth_graphs', '.mat', 'PSTH', 'format', ...
                    total_bins, config.bin_size, config.pre_time, config.rf_analysis, rf_path, ...
                    config.make_region_subplot, config.sub_columns);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     Normalized Variance    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.nv_analysis
                batch_nv(animal_name, original_path, psth_path, 'normalized_variance_analysis', ...
                    '.mat', 'psth', 'format', config)
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.psth_classify
                batch_classify(animal_name, original_path, psth_path, 'classifier', '.mat', 'PSTH', 'format', ...
                    config.boot_iterations, config.bootstrap_classifier, config.bin_size, ...
                    config.pre_time, config.post_time);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.info_analysis
                batch_info(animal_name, psth_path, 'mutual_info', ...
                    '.mat', 'psth', 'format');
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%            MNTS            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.create_mnts
                mnts_start = tic;
                [parsed_files, mnts_path, failed_path] = create_dir(parsed_path, 'mnts', '.mat');

                fprintf('Calculating mnts for %s \n', animal_name);
                %% Goes through all the files and creates mnts according to the parameters set in config
                for file_index = 1:length(parsed_files)
                    try
                        %% Load file contents
                        file = [parsed_path, '/', parsed_files(file_index).name];
                        [~, filename, ~] = fileparts(file);
                        load(file, 'event_ts', 'labeled_neurons');
                        %% Check parsed variables to make sure they are not empty
                        empty_vars = check_variables(file, event_ts, labeled_neurons);
                        if empty_vars
                            continue
                        end

                        %% Format mnts
                        [mnts_struct, event_ts, event_strings, labeled_neurons] = format_mnts(event_ts, ...
                            labeled_neurons, config.bin_size, config.pre_time, config.post_time, config.wanted_events, ...
                            config.trial_range, config.trial_lower_bound);

                        %% Saving outputs
                        matfile = fullfile(mnts_path, ['mnts_format_', filename, '.mat']);
                        %% Check PSTH output to make sure there are no issues with the output
                        empty_vars = check_variables(matfile, mnts_struct, event_ts, event_strings, labeled_neurons);
                        if empty_vars
                            continue
                        end

                        %% Save file if all variables are not empty
                        save(matfile, 'mnts_struct', 'event_ts', 'event_strings', 'labeled_neurons');
                        export_params(mnts_path, 'mnts_psth', parsed_path, failed_path, animal_name, config);
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                fprintf('Finished calculating mnts for %s. It took %s \n', ...
                    animal_name, num2str(toc(mnts_start)));
            else
                mnts_path = [parsed_path, '/mnts'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %             PCA            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.pc_analysis
                pca_start = tic;
                [mnts_files, pca_path, failed_path] = create_dir(mnts_path, 'pca', '.mat');

                fprintf('PCA for %s \n', animal_name);
                %% Goes through all the files and performs pca according to the parameters set in config
                for file_index = 1:length(mnts_files)
                    try
                        %% pull info from filename and set up file path for analysis
                        file = fullfile(mnts_path, mnts_files(file_index).name);
                        [~, filename, ~] = fileparts(file);
                        filename = erase(filename, 'mnts_format_');
                        filename = erase(filename, 'mnts.format.');
                        load(file, 'event_ts', 'labeled_neurons', 'mnts_struct');
                        %% Check variables to make sure they are not empty
                        empty_vars = check_variables(file, event_ts, labeled_neurons, mnts_struct);
                        if empty_vars
                            continue
                        end

                        %% PCA
                        [pca_results, event_struct, labeled_neurons] = calc_pca(labeled_neurons, ...
                            mnts_struct, config.bin_size, config.pre_time, ...
                            config.post_time, config.feature_filter, config.feature_value);

                        %% Saving the file
                        matfile = fullfile(pca_path, ['pc_analysis_', filename, '.mat']);
                        check_variables(matfile, event_struct, pca_results, labeled_neurons);
                        save(matfile, 'event_struct', 'labeled_neurons', 'event_ts', 'pca_results');
                        clear('event_struct', 'labeled_neurons', 'event_ts', 'pca_results');
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                fprintf('Finished PCA for %s. It took %s \n', ...
                    animal_name, num2str(toc(pca_start)));
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     Normalized Variance    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.nv_analysis
                batch_nv(animal_name, original_path, pca_path, 'normalized_variance_analysis', ...
                    '.mat', 'pc', 'analysis', config)
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.rf_analysis
                pc_rf_path = batch_recfield(animal_name, original_path, pca_path, 'receptive_field_analysis', ...
                    '.mat', 'pc', 'analysis', config);
            else
                pc_rf_path = [pca_path, '/receptive_field_analysis'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, pca_path, 'pc_graphs', '.mat', 'pc', 'analysis', ...
                    total_bins, config.bin_size, config.pre_time, config.rf_analysis, pc_rf_path, ...
                    config.make_region_subplot, config.sub_columns);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.psth_classify
                batch_classify(animal_name, original_path, pca_path, 'classifier', '.mat', 'pc', 'analysis', ...
                    config.boot_iterations, config.bootstrap_classifier, config.bin_size, ...
                    config.pre_time, config.post_time);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.info_analysis
                batch_info(animal_name, pca_path, 'mutual_info', ...
                    '.mat', 'pc', 'analysis');
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %             ICA            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.ic_analysis
                ica_start = tic;
                [mnts_files, ica_path, failed_path] = create_dir(mnts_path, 'ica', '.mat');
                fprintf('ICA for %s \n', animal_name);
                %% Goes through all the files and performs pca according to the parameters set in config
                for file_index = 1:length(mnts_files)
                    try
                        %% pull info from filename and set up file path for analysis
                        file = fullfile(mnts_path, mnts_files(file_index).name);
                        [~, filename, ~] = fileparts(file);
                        filename = erase(filename, 'mnts_format_');
                        filename = erase(filename, 'mnts.format.');
                        load(file, 'event_ts', 'labeled_neurons', 'mnts_struct');
                        %% Check variables to make sure they are not empty
                        empty_vars = check_variables(file, event_ts, labeled_neurons, mnts_struct);
                        if empty_vars
                            continue
                        end

                        %% ICA
                        [labeled_neurons, event_struct, ica_results] = ...
                            calc_ica(labeled_neurons, mnts_struct, config.pre_time, config.post_time, ...
                            config.bin_size, config.ic_pc, config.extended, config.sphering, ...
                            config.anneal, config.anneal_deg, config.bias, config.momentum, ...
                            config.max_steps, config.stop, config.rnd_reset, config.verbose);

                        %% Saving the file
                        matfile = fullfile(ica_path, ['ic_analysis_', filename, '.mat']);
                        empty_vars = check_variables(matfile, labeled_neurons, event_struct, ica_results);
                        if empty_vars
                            continue
                        end
                        save(matfile, 'event_struct', 'labeled_neurons', 'event_ts', 'ica_results');
                    catch ME
                        handle_ME(ME, failed_path, filename);
                    end
                end
                fprintf('Finished ICA for %s. It took %s \n', ...
                    animal_name, num2str(toc(ica_start)));
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     Normalized Variance    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.nv_analysis
                batch_nv(animal_name, original_path, ica_path, 'normalized_variance_analysis', ...
                    '.mat', 'ic', 'analysis', config)
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.rf_analysis
                ic_rf_path = batch_recfield(animal_name, original_path, ica_path, 'receptive_field_analysis', ...
                    '.mat', 'ic', 'analysis', config);
            else
                ic_rf_path = [ica_path, '/receptive_field_analysis'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, ica_path, 'ic_graphs', '.mat', 'ic', 'analysis', ...
                    total_bins, config.bin_size, config.pre_time, config.rf_analysis, ic_rf_path, ...
                    config.make_region_subplot, config.sub_columns);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.psth_classify
                batch_classify(animal_name, original_path, ica_path, 'classifier', '.mat', 'ic', 'analysis', ...
                    config.boot_iterations, config.bootstrap_classifier, config.bin_size, ...
                    config.pre_time, config.post_time);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.info_analysis
                batch_info(animal_name, ica_path, 'mutual_info', ...
                    '.mat', 'ic', 'analysis');
            end

            %% Trajectories
            %% TODO implement
            % neural_trajectory_analysis(animal_name, psth_path, bin_size, total_trials, pre_time, post_time, ...
            %     optimize_state_dimension, state_dimension, prediction_error_dimensions, plot_trials, dimsToPlot);
        end
    end
    toc(start_time);
end