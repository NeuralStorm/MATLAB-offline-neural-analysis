function [unit_struct, pop_struct, pop_table, unit_table] = psth_bootstrapper( ...
        response_window, event_info, boot_iterations)
    %! Pass in pre sliced psth_struct

    unique_features = fieldnames(response_window);
    unique_events = unique(event_info.event_labels);
    unit_struct = struct;
    pop_struct = struct;
    unit_results = [];
    pop_results = [];

    %! Added to remove table and feature headers
    unit_table = [];
    pop_table = [];

    %% Standard classification
    event_struct = create_event_response(response_window, event_info);
    for feature_i = 1:length(unique_features)
        feature = unique_features{feature_i};

        %% Unit classification
        [classify_struct, unit_info] = classify_unit(feature, ...
            event_struct.(feature), unique_events);
        %% Store unit classification
        unit_struct.(feature) = classify_struct.(feature);
        unit_results = [unit_results; unit_info];

        %% Population classification
        [classify_struct, pop_info] = classify_pop(feature, event_struct, unique_events);
        %% Store unit classification
        pop_struct.(feature) = classify_struct;
        pop_results = [pop_results; pop_info];
    end

    % unit_table = cell2table(unit_results, 'VariableNames', analysis_column_names);
    % pop_table = cell2table(pop_results, 'VariableNames', analysis_column_names);

    %% Bootstrapping
    if true %! remove this flag...its the bootstrapper, why would it not bootstrap
        for feature_i = 1:length(unique_features)
            feature = unique_features{feature_i};
            tot_units = numel(response_window.(feature).label_order);
            %% Preallocate arrays before bootstrapping
            feature_rand_info = nan(boot_iterations, 2);
            % unit_rand_info = nan(boot_iterations, (tot_units * 2));

            parfor i = 1:boot_iterations
                %% Shuffle labels
                shuffled_events = event_info;
                shuffled_events.event_indices = shuffled_events.event_indices(randperm(numel(shuffled_events.event_indices)));
                shuffled_struct = create_event_response(response_window, shuffled_events);

                %% Unit classification
                % unit_shuffled_info = [];
                % [classify_struct, ~] = classify_unit(feature, selected_data.(feature), ...
                %     shuffled_struct.(feature), unique_events);
                % for unit = 1:length(region_neurons(:,1))
                %     current_unit = region_neurons{unit, 1};
                %     shuffled_info = classify_struct.(feature).(current_unit).mutual_info;
                %     unit_shuffled_info = [unit_shuffled_info, {current_unit}, {shuffled_info}];
                % end
                % region_unit_info = [region_unit_info, unit_shuffled_info];

                %% Population classification
                [~, shuffled_info, ~, shuffled_perf] = psth_classifier(shuffled_struct.(feature), unique_events);
                % region_shuffled_info = [region_shuffled_info, {feature}, {shuffled_info}];
                feature_rand_info(i, :) = [shuffled_perf, shuffled_info];
            end
            boot_stats = mean(feature_rand_info);
            pop_struct.(feature).boot_array = feature_rand_info;
            pop_struct.(feature).rand_perf = boot_stats(1);
            pop_struct.(feature).rand_info = boot_stats(2);
        end

        % for region = 1:2:length(region_rand_info(1,:))
        %     %% Average region random info and correct classification info
        %     current_region_column = region_rand_info(:, region);
        %     %% Verify that labels are consistent before averaging random info
        %     % TODO throw error but save file info
        %     assert(length(unique(current_region_column)) == 1);
        %     current_region = current_region_column{1};
        %     avg_rand_info = mean([region_rand_info{:, region + 1}]);
        %     corrected_info = pop_table.mutual_info(strcmpi(pop_table.region, current_region)) - avg_rand_info;

        %     %% Store region population corrected info and averaged random info
        %     pop_struct.(current_region).avg_rand_info = avg_rand_info;
        %     pop_table.boot_info(strcmpi(pop_table.region, current_region)) = avg_rand_info;
        %     pop_table.corrected_info(strcmpi(pop_table.region, current_region)) = corrected_info;

        %     %% Average unit random info and correct classification info
        %     for unit = 1:2:length(unit_rand_info(1,:))
        %         current_unit_column = unit_rand_info(:, unit);
        %         %% Verify that labels are consistent before averaging random info
        %         % TODO throw error but save file info
        %         assert(length(unique(current_unit_column)) == 1);
        %         current_unit = current_unit_column{1};
        %         avg_rand_info = mean([unit_rand_info{:, unit + 1}]);
        %         corrected_info = unit_table.mutual_info(strcmpi(unit_table.region, current_region) ...
        %             & strcmpi(unit_table.sig_channels, current_unit)) - avg_rand_info;

        %         %% Store unit corrected info and averaged random info
        %         unit_struct.(current_region).(current_unit).avg_rand_info = avg_rand_info;
        %         unit_table.boot_info(strcmpi(unit_table.region, current_region) ...
        %             & strcmpi(unit_table.sig_channels, current_unit)) = avg_rand_info;
        %         unit_table.corrected_info(strcmpi(unit_table.region, current_region) ...
        %             & strcmpi(unit_table.sig_channels, current_unit)) = corrected_info;
        %     end
        % end
    end
end

function [classify_struct, table_results] = classify_unit(region_name, psth_struct, unique_events)
    classify_struct = struct;
    table_results = [];
    %% Unit Classification
    tot_feature_units = numel(psth_struct.(region_name).label_order);
    for unit = 1:tot_feature_units
        current_unit = psth_struct.(region_name).label_order{unit};
        unit_response = struct;
        for event = 1:length(unique_events)
            current_event = unique_events{event};
            unit_response.(current_event) = psth_struct.(current_event).(current_unit);
        end
        [confusion_matrix, mutual_info, correct_trials, performance] = ...
            psth_classifier(unit_response, unique_events);
        classify_struct.(region_name).(current_unit).confusion_matrix = confusion_matrix;
        classify_struct.(region_name).(current_unit).mutual_info = mutual_info;
        classify_struct.(region_name).(current_unit).correct_trials = correct_trials;
        classify_struct.(region_name).(current_unit).performance = performance;
    end
end

function [classify_struct, table_results] = classify_pop(region_name, psth_struct, unique_events)
    classify_struct = struct;
    table_results = [];

    %% Population Classification
    region_response = psth_struct.(region_name);
    [confusion_matrix, mutual_info, correct_trials, performance] = ...
        psth_classifier(region_response, unique_events);
    classify_struct.confusion_matrix = confusion_matrix;
    classify_struct.mutual_info = mutual_info;
    classify_struct.correct_trials = correct_trials;
    classify_struct.performance = performance;
    table_results = [table_results; {region_name}, {'population'}, {'population'}, {performance}, {mutual_info}, {0}, {mutual_info} ...
        {NaN}, {NaN}, {'n/a'}];
end

% function [classify_struct, table_results] = classify_unit(region_name, region_table, psth_struct, unique_events)
%     classify_struct = struct;
%     table_results = [];
%     %% Unit Classification
%     for unit = 1:height(region_table)
%         current_unit = region_table.sig_channels{unit};
%         unit_response = struct;
%         for event = 1:length(unique_events)
%             current_event = unique_events{event};
%             unit_response.(current_event) = psth_struct.(current_event).(current_unit);
%         end
%         [confusion_matrix, mutual_info, correct_trials, performance] = ...
%             psth_classifier(unit_response, unique_events);
%         classify_struct.(region_name).(current_unit).confusion_matrix = confusion_matrix;
%         classify_struct.(region_name).(current_unit).mutual_info = mutual_info;
%         classify_struct.(region_name).(current_unit).correct_trials = correct_trials;
%         classify_struct.(region_name).(current_unit).performance = performance;

%         user_channels = region_table.user_channels(strcmpi(region_table.sig_channels, current_unit));
%         notes = region_table.recording_notes(strcmpi(region_table.sig_channels, current_unit));
%         if strcmpi(class(notes), 'double') && isnan(notes)
%             notes = 'n/a';
%         end
%         table_results = [table_results; {region_name}, {current_unit}, {user_channels}, {performance}, {mutual_info}, ...
%             {0}, {mutual_info}, {NaN}, {NaN}, {notes}];
%     end
% end