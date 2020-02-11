function [] = plot_event_states(state_table, plot_trials)
    % event_list and trial_list are transposed to agree with for loop syntax
    state_names = state_table.Properties.VariableNames;
    state_names = setdiff(state_names, {'trial_number', 'event_label', 'event_ts', 'Timestamp'});
    event_list = unique(state_table.event_label)';
    event_struct = struct;
    state_struct = struct;
    tot_bins = length(state_table.trial_number(state_table.trial_number == 1));
    for curr_event = event_list
        % event_plot = figure
        event_name = ['event_', num2str(curr_event)];
        event_table = state_table(state_table.event_label == curr_event, :);
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
                state_struct.(curr_state{1}).(event_name).avg = mean(trial_table.(curr_state{1}), 2);
                state_struct.(curr_state{1}).(event_name).ste = std(trial_table.(curr_state{1})) ./ sqrt(length(trial_list));
            end
        end
        if plot_trials
            for curr_state = state_names
                figure
                hold on
                state_measures = event_struct.(event_name).(curr_state{1});
                [tot_trials, ~] = size(state_measures);
                for trial = 1:tot_trials
                    plot(state_measures(trial, :))
                end
                title([event_name, ' ', curr_state{1}])
                hold off
            end
        end
    end

    transparency=0.2;
    for curr_state = state_names
        figure
        hold on
        for curr_event = event_list
            event_name = ['event_', num2str(curr_event)];
            event_data = state_struct.(curr_state{1}).(event_name).avg;
            ste = state_struct.(curr_state{1}).(event_name).ste;
            [l,p] = boundedline(1:tot_bins, event_data, ste, 'transparency', transparency);
            plot(event_data, 'DisplayName', strrep(event_name, '_', ' '));
        end
        legend
        title(curr_state{1});
        hold off
    end
end