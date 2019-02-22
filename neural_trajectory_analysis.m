function [] = neural_trajectory_analysis(original_path, animal_name, psth_path, bin_size, total_trials, pre_time, post_time, ...
    optimize_state_dimension, state_dimension, prediction_error_dimensions, plot_trials, plot_dimensions, dimsToPlot)
% ! TODO SKIP EVENTS WITH TOO FEW CORRECT TRIALS (<10 for right now)

    %% Animal categories
    learning = ['PRAC03', 'TNC16', 'RAVI19', 'RAVI20', 'RAVI019', 'RAVI020'];
    non_learning = ['LC02', 'TNC06', 'TNC12', 'TNC25'];
    control = ['TNC01', 'TNC03', 'TNC04', 'TNC14'];
    right_direct = ['RAVI19', 'PRAC03', 'LC02', 'TNC12'];
    left_direct = ['RAVI20', 'TNC16', 'TNC25', 'TNC06'];

    % Grabs all the psth formatted files
    psth_mat_path = strcat(psth_path, '/*.mat');
    psth_files = dir(psth_mat_path);

    % Checks if a classify graph directory exists and if not it creates it
    trajectory_path = [psth_path, '/trajectory_analysis'];
    if ~exist(trajectory_path, 'dir')
        % mkdir(region_path, ['/', current_event]);
        mkdir(psth_path, ['/trajectory_analysis']);
    end

    % Deletes the failed directory if it already exists
    failed_path = [trajectory_path, '/failed'];
    if exist(failed_path, 'dir') == 7
        delete([failed_path, '/*']);
        rmdir(failed_path);
    end

    pre_time_bins = (length([-abs(pre_time): bin_size: 0])) - 1;
    post_time_bins = (length([0:bin_size:post_time])) - 1;
    gpfa_post_time_bins = (length([-abs(0):0.001:post_time])) - 1;

    %% Iterates through all the psth formated files
    for file = 1: length(psth_files)
        current_file = [psth_path, '/', psth_files(file).name];
        [file_path, filename, file_extension] = fileparts(current_file);
        split_name = strsplit(filename, '.');
        current_day = split_name{6};
        day_num = regexp(current_day,'\d*','Match');
        day_num = str2num(day_num{1});
        exp_date = split_name{end};
        current_animal = split_name{3};
        current_animal_id = split_name{4};
        fprintf('Neural trajectories for %s on %s\n', animal_name, current_day);        

        load(current_file);

        neuro_traj_struct = struct;
        neuro_traj_table = table();
        all_events = event_struct.all_events;
        for region = 1:length(unique_regions)
            region_name = unique_regions{region};
            %% Create region directory
            if (contains(right_direct, current_animal) && strcmpi(region_name, 'right')) || ...
                    (contains(left_direct, current_animal) && strcmpi(region_name, 'left'))
                region_path = [trajectory_path, '/direct'];
                if ~exist(region_path, 'dir')
                    mkdir(trajectory_path, ['/direct']);
                end
            else
                region_path = [trajectory_path, '/indirect'];
                if ~exist(region_path, 'dir')
                    mkdir(trajectory_path, ['/indirect']);
                end
            end

            total_region_neurons = length(labeled_neurons.(region_name)(:,1));          
            region_neurons = [labeled_neurons.(region_name)(:,1), labeled_neurons.(region_name)(:,end)];
            region_psth = NeuroToolbox.PSTHToolbox.PSTH(region_neurons, all_events, 'bin_size', ... 
                bin_size, 'PSTH_window', [-abs(pre_time), post_time]);
            region_template = NeuroToolbox.PSTHToolbox.SU_Classifier(region_psth);
            region_decoder_output = region_template.classify(region_neurons, all_events, 'SameDataSet', true);
            correct_trials = cellfun(@strcmp, region_decoder_output.Decision, region_decoder_output.Event);
            correct_labels = region_decoder_output.Event(correct_trials);
            label_counts = tabulate(correct_labels);
            %! Raw data passed into trajectory code needs 1ms bin size
            relative_response = event_spike_times(labeled_neurons.(region_name)(:, end), event_struct.all_events(:,2), ...
                total_trials, .001, 0, post_time);
            correct_response = [];
            for i = 1:length(correct_trials)
                if correct_trials(i)
                    correct_response = [correct_response; relative_response(i,:)];
                end
            end
            %% Store info in neuro_traj_struct
            neuro_traj_struct.(region_name).correct_labels = correct_labels;
            neuro_traj_struct.(region_name).label_counts = label_counts;
            neuro_traj_struct.(region_name).correct_response = correct_response;
            event_counts = cell2mat(label_counts(:,2));
            event_end_indeces = cumsum(event_counts);
            previous_event = 1;
            for event = 1:length(event_counts)
                current_event = event_strings{event};
                event_path = [region_path, '/', current_event];
                if ~exist(event_path, 'dir')
                    mkdir(region_path, ['/', current_event]);
                end
                %% Separate events in the correct response matrix
                event_response = correct_response(previous_event:event_end_indeces(event), :);
                neuro_traj_struct.(region_name).([current_event, '_responses']) = event_response;
                previous_event = event_end_indeces(event) + 1;
                %% Reformat event_response (TX(N*B)) to gpfa format
                % format = struct with fields trial id and spikes (NXB)
                gpfa_format = struct;
                % disp(event_response)
                disp(total_region_neurons)
                disp(length(event_response(:,1)))
                for trial = 1:length(event_response(:,1))
                    gpfa_format(trial).trialId = trial;
                    current_response = event_response(trial, :);
                    spikes = reshape(current_response, total_region_neurons, gpfa_post_time_bins);
                    gpfa_format(trial).spikes = spikes;
                end

                %Change region_name to indirect or direct
                runIdx = [num2str(day_num), '_', animal_name, '_', region_name, '_', current_event];
                % try
                    numFolds = 4;
                    kernSD = 30;
                    tic
                    if optimize_state_dimension
                        optimize_path = strcat(event_path, '/p_optimization');
                        if ~exist(optimize_path, 'dir')
                            mkdir(event_path, '/p_optimization');
                        end

                        day_path = [optimize_path, '/', current_day];
                        if ~exist(day_path, 'dir')
                            mkdir(optimize_path, ['/', current_day]);
                        end

                        % p = state dimension (from Yu et al. 2009)
                        for p = prediction_error_dimensions
                            result = neuralTraj(day_path, gpfa_format, 'method', 'gpfa', 'xDim', p, 'numFolds', numFolds);
                            [estParams, seqTrain] = postprocess(result, 'kernSD', kernSD);
                        end
                        pred_err = plotPredErrorVsDim(day_path, optimize_path, kernSD, runIdx);
                        if isempty(pred_err)
                            continue
                        end
                        matfile = fullfile(optimize_path, ['RESULTS_', runIdx, '.mat']);
                        save(matfile, 'gpfa_format', 'neuro_traj_struct', 'correct_trials', 'result', 'pred_err');
                    end

                    day_path = [event_path, '/', current_day];
                    if ~exist(day_path, 'dir')
                        mkdir(event_path, ['/', current_day]);
                    end

                    result = neuralTraj(day_path, gpfa_format, 'method', 'gpfa', 'xDim', state_dimension,... 
                        'kernSDList', kernSD);
                    % In Yu et al. 2009, C is the low dimensional matrix that maps neural trajectories
                    % into recorded space (see pg: 621, 631-632)
                    c = result.estParams.C;
                    %% Create plots
                    plots_path = [event_path, '/plots'];
                    if ~exist(plots_path, 'dir')
                        mkdir(event_path, '/plots');
                    end
                    [estParams, seqTrain] = postprocess(result, 'kernSD', kernSD);
                    plot3D(seqTrain, 'xorth', 'dimsToPlot', dimsToPlot, 'nPlotMax', plot_trials);
                    legend({'Neural Trajectory', 'Start of Tilt', 'Decision Made', 'End of Tilt'},'TextColor', 'black');
                    % title(legend, current_event);
                    set(gcf, 'Name', runIdx, 'NumberTitle', 'off');
                    graph_name = [runIdx '.png'];
                    saveas(gcf, fullfile(plots_path, graph_name));
                    graph_name = [runIdx '.fig'];
                    saveas(gcf, fullfile(plots_path, graph_name));
                    plotEachDimVsTime(seqTrain, 'xorth', result.binWidth);
                    set(gcf, 'Name', runIdx, 'NumberTitle', 'off');
                    graph_name = [runIdx '_DimvsTime.png'];
                    saveas(gcf, fullfile(plots_path, graph_name));
                    close all
                    matfile = fullfile(day_path, [filename, '.mat']);
                    save(matfile, 'gpfa_format', 'neuro_traj_struct', 'correct_trials', 'result');

                % catch ME
                %     if ~exist(failed_path, 'dir')
                %         mkdir(trajectory_path, 'failed');
                %     end
                %     matfile = fullfile(failed_path, [runIdx '.mat']);
                %     % failed_traj{end + 1} = file_name;
                %     failed_traj = ME;
                %     warning('Error: %s\n', ME.message)
                %     save(matfile, 'failed_traj');
                %     % rethrow(ME)
                %     % if (strcmpi(ME.identifier, 'MATLAB:rankDeficient'))
                %     %     save(matfile, 'runIdx');
                %     %     continue
                %     % else
                %     %     save(matfile, 'ME');
                %     %     rethrow(ME)
                %     % end
                % end
            end
        end
    end
end