function [classified_struct, results_table] = psth_bootstrapper(labeled_neurons, event_struct, ...
        event_ts, boot_iterations, unit_classification, bin_size, pre_time, post_time)
    region_names = fieldnames(labeled_neurons);
    event_strings = event_struct.all_events(:,1)';
    classified_struct = struct;
    rand_info = 0;
    results = [];
    %% Standard classification
    for region = 1:length(region_names)
        current_region = region_names{region};
        region_neurons = [labeled_neurons.(current_region)(:,1), labeled_neurons.(current_region)(:,4)];
        if unit_classification
            for unit = 1:length(region_neurons(:,1))
                current_unit = region_neurons{unit, 1};
                unit_response = struct;
                for event = 1:length(event_strings)
                    current_event = event_strings{event};
                    unit_response.(current_event) = event_struct.(current_region).(current_event).(current_unit);
                end
                [confusion_matrix, mutual_info, predicted_events, true_events, correct_trials, performance] = ...
                    psth_classifier(unit_response, event_strings);
                classified_struct.(current_region).(current_unit).confusion_matrix = confusion_matrix;
                classified_struct.(current_region).(current_unit).mutual_info = mutual_info;
                classified_struct.(current_region).(current_unit).predicted_events = predicted_events;
                classified_struct.(current_region).(current_unit).true_events = true_events;
                classified_struct.(current_region).(current_unit).correct_trials = correct_trials;
                classified_struct.(current_region).(current_unit).performance = performance;
                results = [results; {current_region}, {current_unit}, {performance}, {mutual_info}];
            end
        else
            %% CLASSIFY TIME
            % Preforms standard classification --> Does not create the relative response template
            region_response = event_struct.(current_region);
            [confusion_matrix, mutual_info, predicted_events, true_events, correct_trials, performance] = ...
                psth_classifier(region_response, event_strings);
            classified_struct.(current_region).confusion_matrix = confusion_matrix;
            classified_struct.(current_region).mutual_info = mutual_info;
            classified_struct.(current_region).predicted_events = predicted_events;
            classified_struct.(current_region).true_events = true_events;
            classified_struct.(current_region).correct_trials = correct_trials;
            classified_struct.(current_region).performance = performance;
            results = [results; {current_region}, {'population'}, {performance}, {mutual_info}];
        end
    end

    results_table = cell2table(results, 'VariableNames', {'region', 'channel', 'performance', 'mutual_info'});

    parfor i = 1:boot_iterations
        %% Shuffle labels
        shuffled_labels = shuffle_event_labels(event_ts, event_strings);
        for region = 1:length(region_names)
            current_region = region_names{region};
            region_neurons = [labeled_neurons.(current_region)(:,1), labeled_neurons.(current_region)(:,4)];
            %% Recreate relative response matrix from shuffled labels for region
            shuffled_response = create_relative_response(region_neurons, shuffled_labels, bin_size, pre_time, post_time);

            if unit_classification
                for unit = 1:length(region_neurons(:,1))
                    current_unit = region_neurons{unit, 1};
                    unit_response = struct;
                    for event = 1:length(event_strings)
                        current_event = event_strings{event};
                        unit_response.(current_event) = shuffled_response.(current_event).(current_unit);
                    end
                    [~, shuffled_info, ~, ~, ~, ~] = psth_classifier(unit_response, event_strings);
                end
            else
                %% CLASSIFY TIME
                [~, shuffled_info, ~, ~, ~, ~] = psth_classifier(shuffled_response, event_strings);
            end
            rand_info = rand_info + shuffled_info;
        end
    end

    %% Find average random info
    rand_info = rand_info / (boot_iterations - 1);
    %% Subtract out random info
    corrected_info = results_table.mutual_info - rand_info;
    results_table = addvars(results_table, repmat(rand_info, [length(corrected_info), 1]), corrected_info, 'NewVariableNames', {'bootstrapped_info', 'corrected_info'});
end

function [all_events] = shuffle_event_labels(event_ts, event_strings)
    % Shuffle event labels from the events matrix
    shuffled_event_labels = event_ts(:,1);
    shuffled_event_labels = shuffled_event_labels(randperm(length(shuffled_event_labels)));
    shuffled_events = [shuffled_event_labels, event_ts(:,2)];
    %% Recreate event struct with shuffled labels
    all_events = {};
    unique_events = unique(event_ts(:,1));
    for event = 1:length(unique_events)
        %% Slices out the desired trials from the event_ts matrix (Inclusive range)
        all_events = [all_events; event_strings{event}, {shuffled_events(shuffled_events == unique_events(event), 2)}];
        if isempty(all_events{event, 2})
            all_events(event, :) = [];
        end
    end
end