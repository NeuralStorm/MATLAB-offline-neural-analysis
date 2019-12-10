function [] = plot_state_obs(kalman_path, session_num, state_table, psth_struct)
    % event_list and trial_list are transposed to agree with for loop syntax
    state_names = state_table.Properties.VariableNames;
    state_names = setdiff(state_names, {'trial_number', 'event_label', 'event_ts', 'Timestamp'});
    event_list = unique(state_table.event_label)';
    event_struct = struct;
    state_struct = struct;
    tot_bins = length(state_table.trial_number(state_table.trial_number == 1));
    event_strings = psth_struct.all_events(:, 1);
    struct_names = fieldnames(psth_struct);
    meta_info = {'all_events'};
    unique_regions = setdiff(struct_names, meta_info);

    %% Remove incorrect trials
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        bad_rh_trials = unique(state_table.trial_number(find(state_table.rh_F < (mean(state_table.rh_F) - 3 * std(state_table.rh_F)))));
        bad_lh_trials = unique(state_table.trial_number(find(state_table.lh_F < (mean(state_table.lh_F) - 3 * std(state_table.lh_F)))));
        bad_lh_trials = unique(state_table.trial_number(find(state_table.fl_F < (mean(state_table.fl_F) - 3 * std(state_table.fl_F)))));
        bad_lh_trials = unique(state_table.trial_number(find(state_table.lh_F < (mean(state_table.lh_F) - 3 * std(state_table.lh_F)))));
        bad_fl_trials = unique(state_table.trial_number(find(state_table.fl_F < (mean(state_table.fl_F) - 3 * std(state_table.fl_F)))));
        bad_trials = unique([bad_rh_trials; bad_lh_trials; bad_fl_trials]);
        trial_nums = unique(state_table.trial_number);
        trial_nums = setdiff(trial_nums, bad_trials);
        state_table(ismember(state_table.trial_number, bad_trials), :) = [];
        relative_response = psth_struct.(region).relative_response;
        relative_response(bad_trials, :) = [];
        

        all_events = [];
        for event_i = 1:length(event_list)
            event_num = event_list(event_i);
            curr_event = ['event_', num2str(event_num)];
            all_events = [all_events; curr_event, ...
                {unique(state_table.event_ts(ismember(state_table.trial_number(state_table.event_label == event_num), trial_nums), :))}];
        end
        try
            event_struct = split_relative_response(relative_response, [{'pc_1'}; {'pc_2'}; {'pc_3'}], all_events, tot_bins);
        catch
            event_struct = split_relative_response(relative_response, [{'pc_1'}; {'pc_2'}], all_events, tot_bins);
        end
        psth_struct.(region) = event_struct;
        psth_struct.(region).relative_response = relative_response;
        psth_struct.(region).psth = sum(relative_response) / length(trial_nums);

        [confusion_matrix, ~, ~, ~, correct_trials, performance] = psth_classifier(psth_struct.(region), event_strings');
        correct_trial_nums = trial_nums(correct_trials.correct, :);
        state_struct.(region).state = state_table(ismember(state_table.trial_number, correct_trial_nums), :);
        state_struct.(region).performance = performance;
        state_struct.(region).confusion_matrix = confusion_matrix;
        size(state_struct.(region).state)
    end

    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        for curr_event = event_list
            % event_plot = figure
            event_name = ['event_', num2str(curr_event)];
            region_state = state_struct.(region).state;
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
                figure('visible', 'off');
                hold on
                event_name = ['event_', num2str(curr_event)];
                curr_psth = psth_struct.(region).(event_name).psth;
                event_data = state_struct.(region).(curr_state{1}).(event_name).avg;
                event_ste = state_struct.(region).(curr_state{1}).(event_name).ste;
                % plot(curr_psth(1:tot_bins), event_data, 'Marker', 'o');
                [l,p] = boundedline(curr_psth(1:tot_bins), event_data, event_ste, 'transparency', transparency);
                plot(curr_psth(1:tot_bins), event_data, '-o', 'MarkerIndices', 1, 'MarkerFaceColor', 'green');
                plot(curr_psth(1:tot_bins), event_data, '-s', 'MarkerIndices', tot_bins, 'MarkerFaceColor', 'red');
                plot(curr_psth(1:tot_bins), event_data, '-p', 'MarkerIndices', 10, 'MarkerFaceColor', 'k', 'MarkerSize', 9);
                % plot(curr_psth(1:tot_bins), event_data, 'd', 'MarkerIndices', [2:2:(tot_bins-1)]);
                xlabel('pc 1');
                ylabel('state average');
                plot_info = [session_num, ' ', region, ' INCORRECT ', event_type, ' ', curr_state{1}];
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
        fprintf('Performance: %d\n Confusion Matrix: \n', state_struct.(region).performance);
        state_struct.(region).confusion_matrix
        close all
    end
end