function [gpfa_results] = do_gpfa(animal_id, session_num, selected_data, ...
        psth_struct, bin_size, window_start, window_end, state_dimension)

    unique_regions = fieldnames(selected_data);
    gpfa_results = struct;
    for region = 1:length(unique_regions)
        region_name = unique_regions{region};
        region_events = psth_struct.(region_name).filtered_events;
        event_strings = region_events(:,1)';

        total_region_neurons = height(selected_data.(region_name));
        if bin_size ~= 0.001
            %! Yu's code expects 1ms bin size --> Reshape neural data
            total_bins = (length(-abs(window_start):.001:abs(window_end)) - 1);
            region_neurons = [selected_data.(region_name).channel, selected_data.(region_name).channel_data];
            response_struct = create_relative_response(region_neurons, ...
                region_events, .001, window_start, window_end);
        else
            response_struct = psth_struct.(region_name);
        end

        for event = 1:length(event_strings)
            current_event = event_strings{event};
            event_response = response_struct.(current_event).relative_response;
            %% Reformat event_response (TX(N*B)) to gpfa format
            % format = struct with fields trial id and spikes (NXB)
            gpfa_format = struct;
            [tot_trials, ~] = size(event_response);
            for trial = 1:tot_trials
                gpfa_format(trial).trialId = trial;
                current_response = event_response(trial, :);
                spikes = reshape(current_response, total_region_neurons, total_bins);
                gpfa_format(trial).spikes = spikes;
            end

            runIdx = [animal_id, '_', region_name, '_', num2str(session_num), '_', current_event, '_', num2str(state_dimension)];
            result = neuralTraj(runIdx, gpfa_format, 'method', 'gpfa', 'xDim', state_dimension);
            % In Yu et al. 2009, C is the low dimensional matrix that maps neural trajectories
            % into recorded space (see pg: 621, 631-632)
            % c = result.estParams.C;
            [estParams, seqTrain] = postprocess(result);
            % plot3D(seqTrain, 'xorth', 'nPlotMax', 5);
            % legend({'Trajectory', 'Pre Window', 'Event start', 'End'});
            % title(runIdx);
            % set(gcf, 'Name', runIdx, 'NumberTitle', 'off');
            % plotEachDimVsTime(seqTrain, 'xorth', result.binWidth);
            gpfa_results.(region_name).(current_event).result = result;
            gpfa_results.(region_name).(current_event).estParams = estParams;
            gpfa_results.(region_name).(current_event).seqTrain = seqTrain;
        end
    end
end