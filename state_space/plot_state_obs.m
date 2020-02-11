function [] = plot_state_obs(kalman_path, session_num, state_measurement_struct, psth_struct)
    %! TODO PLOT ICS AND COMPARE TO PCS
    % event_list and trial_list are transposed to agree with for loop syntax
    event_struct = struct;
    state_struct = struct;
    struct_names = fieldnames(psth_struct);
    meta_info = {'all_events'};
    unique_regions = setdiff(struct_names, meta_info);

    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        region_state = state_measurement_struct.(region);
        event_list = unique(region_state.event_label)';
        state_names = region_state.Properties.VariableNames;
        state_names = setdiff(state_names, {'trial_number', 'event_label', 'event_ts', 'Timestamp', 'fl_F'});
        state_struct.(region).state = region_state;
        trial_nums = unique(region_state.trial_number);
        tot_bins = length(region_state.trial_number(region_state.trial_number == trial_nums(1)));
        for curr_event = event_list
            % event_plot = figure
            event_name = ['event_', num2str(curr_event)];
            % region_state = state_struct.(region).state;
            event_table = region_state(region_state.event_label == curr_event, :);
            %% Plot all trials
            trial_list = unique(event_table.trial_number)';

            %% Preallocate states in array
            for curr_state = state_names
                % event_struct.(event_name).(curr_state{1}) = zeros(tot_bins, length(trial_list));
                event_struct.(event_name).(curr_state{1}) = [];
            end

            for curr_trial = trial_list
                trial_table = event_table(event_table.trial_number == curr_trial, :);
                for curr_state = state_names
                    event_struct.(event_name).(curr_state{1}) = ...
                        [event_struct.(event_name).(curr_state{1}); trial_table.(curr_state{1})'];

                    %! Move averaging up one loop
                    state_struct.(region).(curr_state{1}).(event_name).avg = mean(trial_table.(curr_state{1}), 2);
                    state_struct.(region).(curr_state{1}).(event_name).ste = std(trial_table.(curr_state{1})) ./ sqrt(length(trial_list));
                end
            end
        end
    end

    transparency = 0.2;
    % for region = unique_regions
    %     for curr_state = state_names
    %         figure
    %         hold on
    %         for curr_event = event_list
    %             event_name = ['event_', num2str(curr_event)];
    %             curr_psth = psth_struct.(region{1}).(event_name).psth;
    %             event_data = state_struct.(curr_state{1}).(event_name).avg;
    %             event_ste = state_struct.(curr_state{1}).(event_name).ste;
    %             plot(curr_psth(1:tot_bins), event_data, 'Marker', 'o');
    %             [l,p] = boundedline(curr_psth(1:tot_bins), event_data, event_ste, 'transparency', transparency);
    %         end
    %         legend
    %         title([curr_state{1}, ' ' region{1}, ' ', event_name]);
    %         hold off
    %     end
    % end
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        for curr_state = state_names
            for curr_event = event_list
                if curr_event == 1
                    event_type = 'Event right fast';
                elseif curr_event == 3
                    event_type = 'Event right slow';
                elseif curr_event == 4
                    event_type = 'Event left fast';
                elseif curr_event == 6
                    event_type = 'Event left slow';
                end
                figure('visible', 'on');
                hold on
                event_name = ['event_', num2str(curr_event)];
                curr_psth = psth_struct.(region).(event_name).psth;
                event_data = state_struct.(region).(curr_state{1}).(event_name).avg';
                event_ste = state_struct.(region).(curr_state{1}).(event_name).ste';
                % plot(curr_psth(1:tot_bins), event_data, 'Marker', 'o');
                [l,p] = boundedline(curr_psth(1:tot_bins), event_data, event_ste, 'transparency', transparency);
                plot(curr_psth(1:tot_bins), event_data, '-o', 'MarkerIndices', 1, 'MarkerFaceColor', 'green');
                plot(curr_psth(1:tot_bins), event_data, '-s', 'MarkerIndices', tot_bins, 'MarkerFaceColor', 'red');
                plot(curr_psth(1:tot_bins), event_data, '-p', 'MarkerIndices', 10, 'MarkerFaceColor', 'k', 'MarkerSize', 9);
                % plot(curr_psth(1:tot_bins), event_data, 'd', 'MarkerIndices', [2:2:(tot_bins-1)]);
                xlabel('factor 1');
                ylabel('state average');
                plot_info = [session_num, ' ', region, ' ', event_type, ' ', curr_state{1}];
                title(plot_info);
                graph_path = [kalman_path, '/', 'state_plots/'];
                if ~exist(graph_path, 'dir')
                    mkdir(kalman_path, 'state_plots');
                end
                filename = [plot_info, '.png'];
                saveas(gcf, fullfile(graph_path, filename));

                %% Calculated R^2 for states
                % linear_model = fitlm(curr_psth(1:tot_bins), event_data);
                % x_values = curr_psth(1:tot_bins);
                % length(event_data)
                % assert(length(curr_psth(1:tot_bins)) == length(event_data));
                % linear_fit = polyfit(curr_psth(1:tot_bins)', event_data, 1);
                % % slope = linear_fit(1);
                % yfit = polyval(linear_fit, curr_psth(1:tot_bins));
                % yresid = event_data - yfit;
                % SSresid = sum(yresid.^2);
                % SStotal = (length(event_data)-1) * var(event_data);
                % rsq = 1 - SSresid/SStotal;
                % linear_fit = linear_fit(1) * curr_psth(1:tot_bins) + linear_fit(2);
                % plot(curr_psth(1:tot_bins), linear_fit,'r-.');
                % fprintf('%s Rsq for event %d: %d \n', region{1}, curr_event, linear_model.Rsquared.Ordinary);
                hold off
            end
        end
        disp(plot_info)
        % fprintf('Performance: %d\n Confusion Matrix: \n', state_struct.(region).performance);
        % state_struct.(region).confusion_matrix
        % close all
    end
end