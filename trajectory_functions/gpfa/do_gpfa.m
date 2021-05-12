function [gpfa_results] = do_gpfa(subj_id, session_num, rr_data, event_info, ...
        bin_size, window_start, window_end, response_start, response_end, state_dimension)

    unique_ch_groups = fieldnames(rr_data);
    unique_events = unique(event_info.event_labels);
    tot_bins = get_tot_bins(response_start, response_end, bin_size);
    gpfa_results = struct;
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};

        tot_chans = numel(rr_data.(ch_group).chan_order);
        %! Yu's code expects 1ms bin size
        assert(bin_size == 0.001, 'To use GPFA code, bin size for data must be 1ms');

        for event_i = 1:length(unique_events)
            event = unique_events{event_i};
            event_indices = event_info.event_indices(strcmpi(event_info.event_labels, event));
            event_rr = rr_data.(ch_group).relative_response(event_indices, :);
            event_rr = slice_rr(event_rr, bin_size, window_start, ...
                window_end, response_start, response_end);
            %% Reformat event_response (TX(N*B)) to gpfa format
            % format = struct with fields trial id and spikes (NXB)
            gpfa_format = struct;
            [tot_trials, ~] = size(event_rr);
            for trial = 1:tot_trials
                gpfa_format(trial).trialId = trial;
                trial_rr = event_rr(trial, :);
                spikes = reshape(trial_rr, tot_chans, tot_bins);
                gpfa_format(trial).spikes = spikes;
            end

            runIdx = [subj_id, '_', ch_group, '_', num2str(session_num), '_', event, '_', num2str(state_dimension)];
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
            gpfa_results.(ch_group).(event).result = result;
            gpfa_results.(ch_group).(event).estParams = estParams;
            gpfa_results.(ch_group).(event).seqTrain = seqTrain;
        end
    end
end