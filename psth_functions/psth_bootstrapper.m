function [unit_struct, pop_struct, pop_table, unit_table] = psth_bootstrapper( ...
        labeled_data, response_window, event_ts, boot_iterations, ...
        bootstrap_classifier, bin_size, pre_time, pre_start, pre_end, post_time, ...
        post_start, post_end, analysis_column_names)

    region_names = fieldnames(labeled_data);
    event_strings = response_window.all_events(:,1)';
    unit_struct = struct;
    pop_struct = struct;
    unit_results = [];
    pop_results = [];

    %% Standard classification
    total_neurons = 0;
    for region = 1:length(region_names)
        current_region = region_names{region};
        region_neurons = labeled_data.(current_region).sig_channels;
        total_neurons = total_neurons + length(region_neurons(:, 1));

        %% Unit classification
        [classify_struct, unit_info] = classify_unit(current_region, ...
            labeled_data.(current_region), response_window.(current_region), event_strings);
        %% Store unit classification
        unit_struct.(current_region) = classify_struct.(current_region);
        unit_results = [unit_results; unit_info];

        %% Population classification
        [classify_struct, pop_info] = classify_pop(current_region, response_window, event_strings);
        %% Store unit classification
        pop_struct.(current_region) = classify_struct;
        pop_results = [pop_results; pop_info];
    end

    unit_table = cell2table(unit_results, 'VariableNames', analysis_column_names);
    pop_table = cell2table(pop_results, 'VariableNames', analysis_column_names);

    %% Bootstrapping
    if bootstrap_classifier
        unit_rand_info = cell(boot_iterations, (total_neurons * 2));
        region_rand_info = cell(boot_iterations, (length(region_names) * 2));
        parfor i = 1:boot_iterations
            %% Shuffle labels
            shuffled_labels = shuffle_event_labels(event_ts, event_strings);
            region_shuffled_info = [];
            region_unit_info = [];
            for region = 1:length(region_names)
                current_region = region_names{region};
                % region_neurons = [labeled_data.(current_region)(:,1), labeled_data.(current_region)(:,4)];
                region_neurons = [labeled_data.(current_region).sig_channels, labeled_data.(current_region).channel_data];
                %% Recreate relative response matrix from shuffled labels for region
                shuffled_region = create_relative_response(region_neurons, shuffled_labels, bin_size, ...
                    pre_time, post_time);
                shuffled_response = struct;
                shuffled_response.all_events = shuffled_labels;
                shuffled_response.(current_region) = shuffled_region;
                %% Isolate response
                [~, shuffled_struct] = create_analysis_windows(labeled_data, shuffled_response, ...
                    pre_time, pre_start, pre_end, post_time, post_start, post_end, bin_size);

                %% Unit classification
                unit_shuffled_info = [];
                [classify_struct, ~] = classify_unit(current_region, labeled_data.(current_region), ...
                    shuffled_struct.(current_region), event_strings);
                for unit = 1:length(region_neurons(:,1))
                    current_unit = region_neurons{unit, 1};
                    shuffled_info = classify_struct.(current_region).(current_unit).mutual_info;
                    unit_shuffled_info = [unit_shuffled_info, {current_unit}, {shuffled_info}];
                end
                region_unit_info = [region_unit_info, unit_shuffled_info];

                %% Population classification
                [~, shuffled_info, ~, ~, ~, ~] = psth_classifier(shuffled_struct.(current_region), event_strings);
                region_shuffled_info = [region_shuffled_info, {current_region}, {shuffled_info}];
            end
            unit_rand_info(i, :) = region_unit_info;
            region_rand_info(i, :) = region_shuffled_info;
        end
        unit_struct.rand_info = unit_rand_info;
        pop_struct.rand_info = region_rand_info;

        for region = 1:2:length(region_rand_info(1,:))
            %% Average region random info and correct classification info
            current_region_column = region_rand_info(:, region);
            %% Verify that labels are consistent before averaging random info
            % TODO throw error but save file info
            assert(length(unique(current_region_column)) == 1);
            current_region = current_region_column{1};
            avg_rand_info = mean([region_rand_info{:, region + 1}]);
            corrected_info = pop_table.mutual_info(strcmpi(pop_table.region, current_region)) - avg_rand_info;

            %% Store region population corrected info and averaged random info
            pop_struct.(current_region).avg_rand_info = avg_rand_info;
            pop_table.boot_info(strcmpi(pop_table.region, current_region)) = avg_rand_info;
            pop_table.corrected_info(strcmpi(pop_table.region, current_region)) = corrected_info;

            %% Average unit random info and correct classification info
            for unit = 1:2:length(unit_rand_info(1,:))
                current_unit_column = unit_rand_info(:, unit);
                %% Verify that labels are consistent before averaging random info
                % TODO throw error but save file info
                assert(length(unique(current_unit_column)) == 1);
                current_unit = current_unit_column{1};
                avg_rand_info = mean([unit_rand_info{:, unit + 1}]);
                corrected_info = unit_table.mutual_info(strcmpi(unit_table.region, current_region) ...
                    & strcmpi(unit_table.channel, current_unit)) - avg_rand_info;

                %% Store unit corrected info and averaged random info
                unit_struct.(current_region).(current_unit).avg_rand_info = avg_rand_info;
                unit_table.boot_info(strcmpi(unit_table.region, current_region) ...
                    & strcmpi(unit_table.channel, current_unit)) = avg_rand_info;
                unit_table.corrected_info(strcmpi(unit_table.region, current_region) ...
                    & strcmpi(unit_table.channel, current_unit)) = corrected_info;
            end
        end
    end
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

function [classify_struct, table_results] = classify_unit(region_name, region_table, psth_struct, event_strings)
    classify_struct = struct;
    table_results = [];
    %% Unit Classification
    for unit = 1:height(region_table)
        current_unit = region_table.sig_channels{unit};
        unit_response = struct;
        for event = 1:length(event_strings)
            current_event = event_strings{event};
            unit_response.(current_event) = psth_struct.(current_event).(current_unit);
        end
        [confusion_matrix, mutual_info, predicted_events, true_events, correct_trials, performance] = ...
            psth_classifier(unit_response, event_strings);
        classify_struct.(region_name).(current_unit).confusion_matrix = confusion_matrix;
        classify_struct.(region_name).(current_unit).mutual_info = mutual_info;
        classify_struct.(region_name).(current_unit).predicted_events = predicted_events;
        classify_struct.(region_name).(current_unit).true_events = true_events;
        classify_struct.(region_name).(current_unit).correct_trials = correct_trials;
        classify_struct.(region_name).(current_unit).performance = performance;

        notes = region_table.recording_notes(strcmpi(region_table.sig_channels, current_unit));
        table_results = [table_results; {region_name}, {current_unit}, {performance}, {mutual_info}, ...
            {0}, {mutual_info}, {NaN}, {NaN}, {notes}];
    end
end

function [classify_struct, table_results] = classify_pop(region_name, psth_struct, event_strings)
    classify_struct = struct;
    table_results = [];

    %% Population Classification
    region_response = psth_struct.(region_name);
    [confusion_matrix, mutual_info, predicted_events, true_events, correct_trials, performance] = ...
        psth_classifier(region_response, event_strings);
    classify_struct.confusion_matrix = confusion_matrix;
    classify_struct.mutual_info = mutual_info;
    classify_struct.predicted_events = predicted_events;
    classify_struct.true_events = true_events;
    classify_struct.correct_trials = correct_trials;
    classify_struct.performance = performance;
    table_results = [table_results; {region_name}, {'population'}, {performance}, {mutual_info}, {0}, {mutual_info} ...
        {NaN}, {NaN}, {strings}];
end