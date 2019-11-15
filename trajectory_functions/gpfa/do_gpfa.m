function [gpfa_format, result] = do_gpfa(...
        session_num, labeled_data, psth_struct, bin_size, pre_time, post_time)

    all_events = psth_struct.all_events;
    event_strings = all_events(:,1)';
    unique_regions = fieldnames(labeled_data);
    for region = 1:length(unique_regions)
        region_name = unique_regions{region};

        total_region_neurons = height(labeled_data.(region_name));
        %% Find correct trials based on desired bin size
        [~, ~, ~, ~, correct_table, ~] = psth_classifier(psth_struct.(region_name), event_strings);
        if bin_size ~= 0.001
            %! Yu's code expects 1ms bin size --> Reshape neural data
            total_bins = (length(-abs(pre_time):.001:abs(post_time)) - 1);
            region_neurons = [labeled_data.(region_name).sig_channels, labeled_data.(region_name).channel_data];
            response_struct = create_relative_response(region_neurons, ...
                psth_struct.all_events, .001, pre_time, post_time);
        end

        for event = 1:length(event_strings)
            %! Figure out how to handle passing in PCA
            current_event = event_strings{event};
            %% Separate events in the correct response matrix
            event_response = response_struct.(current_event).relative_response;
            correct_trials = correct_table.correct(strcmpi(correct_table.true, current_event));
            correct_responses = event_response(correct_trials, :);
            %% Reformat event_response (TX(N*B)) to gpfa format
            % format = struct with fields trial id and spikes (NXB)
            gpfa_format = struct;
            [tot_trials, ~] = size(correct_responses);
            for trial = 1:tot_trials
                gpfa_format(trial).trialId = trial;
                current_response = correct_responses(trial, :);
                spikes = reshape(current_response, total_region_neurons, total_bins);
                gpfa_format(trial).spikes = spikes;
            end

            runIdx = ['pca', region_name, '_', num2str(session_num), '_', current_event];
            result = neuralTraj(runIdx, gpfa_format, 'method', 'gpfa', 'xDim', 3);
            % In Yu et al. 2009, C is the low dimensional matrix that maps neural trajectories
            % into recorded space (see pg: 621, 631-632)
            % c = result.estParams.C;
            [estParams, seqTrain] = postprocess(result);
            plot3D(seqTrain, 'xorth', 'nPlotMax', 5);
            legend({'Trajectory', 'Pre Window', 'Event start', 'End'});
            title(runIdx);
            % set(gcf, 'Name', runIdx, 'NumberTitle', 'off');
            plotEachDimVsTime(seqTrain, 'xorth', result.binWidth);
        end
    end
end