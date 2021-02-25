function [res_struct] = psth_bootstrapper(...
        psth_struct, event_info, bin_size, window_start, window_end, ...
        response_start, response_end, boot_iterations)

    unique_regions = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    [~, tot_bins] = get_bins(window_start, window_end, bin_size);

    unit_table = create_table();
    pop_table = create_table();

    %% Standard classification
    for reg_i = 1:length(unique_regions)
        region = unique_regions{reg_i};

        %% Population classification
        event_struct = create_event_struct(psth_struct.(region), event_info, ...
            bin_size, window_start, window_end, response_start, response_end);
        res_struct.(region).pop = classify(event_struct, unique_events);

        %% Unit classification
        tot_features = numel(psth_struct.(region).label_order);
        feat_s = 1;
        feat_e = tot_bins;
        for feat_i = 1:tot_features
            feature = psth_struct.(region).label_order{feat_i};
            feat_struct.label_order = {feature};
            feat_struct.relative_response = psth_struct.(region).relative_response(:, feat_s:feat_e);
            %% Unit classification
            event_struct = create_event_struct(feat_struct, event_info, ...
                bin_size, window_start, window_end, response_start, response_end);
            res_struct.(region).unit.(feature) = classify(event_struct, unique_events);
            %% Update feature counter
            feat_s = feat_s + tot_bins;
            feat_e = feat_e + tot_bins;
        end
    end

    %% Bootstrapping
    % if boot_iterations > 0
    %     for feature_i = 1:length(unique_features)
    %         feature = unique_features{feature_i};
    %         tot_units = numel(psth_struct.(feature).label_order);
    %         %% Preallocate arrays before bootstrapping
    %         feature_rand_info = nan(boot_iterations, 2);
    %         % unit_rand_info = nan(boot_iterations, (tot_units * 2));

    %         parfor i = 1:boot_iterations
    %             %% Shuffle labels
    %             shuffled_events = event_info;
    %             shuffled_events.event_indices = shuffled_events.event_indices(randperm(numel(shuffled_events.event_indices)));
    %             shuffled_struct = create_event_response(psth_struct, shuffled_events);

    %             %% Unit classification
    %             % unit_shuffled_info = [];
    %             % [classify_struct, ~] = classify_unit(feature, selected_data.(feature), ...
    %             %     shuffled_struct.(feature), unique_events);
    %             % for unit = 1:length(region_neurons(:,1))
    %             %     current_unit = region_neurons{unit, 1};
    %             %     shuffled_info = classify_struct.(feature).(current_unit).mutual_info;
    %             %     unit_shuffled_info = [unit_shuffled_info, {current_unit}, {shuffled_info}];
    %             % end
    %             % region_unit_info = [region_unit_info, unit_shuffled_info];

    %             %% Population classification
    %             [~, shuffled_info, ~, shuffled_perf] = psth_classifier(shuffled_struct.(feature), unique_events);
    %             % region_shuffled_info = [region_shuffled_info, {feature}, {shuffled_info}];
    %             feature_rand_info(i, :) = [shuffled_perf, shuffled_info];
    %         end
    %         boot_stats = mean(feature_rand_info);
    %         pop_struct.(feature).boot_array = feature_rand_info;
    %         pop_struct.(feature).rand_perf = boot_stats(1);
    %         pop_struct.(feature).rand_info = boot_stats(2);
    %     end

    %     % for region = 1:2:length(region_rand_info(1,:))
    %     %     %% Average region random info and correct classification info
    %     %     current_region_column = region_rand_info(:, region);
    %     %     %% Verify that labels are consistent before averaging random info
    %     %     % TODO throw error but save file info
    %     %     assert(length(unique(current_region_column)) == 1);
    %     %     current_region = current_region_column{1};
    %     %     avg_rand_info = mean([region_rand_info{:, region + 1}]);
    %     %     corrected_info = pop_table.mutual_info(strcmpi(pop_table.region, current_region)) - avg_rand_info;

    %     %     %% Store region population corrected info and averaged random info
    %     %     pop_struct.(current_region).avg_rand_info = avg_rand_info;
    %     %     pop_table.boot_info(strcmpi(pop_table.region, current_region)) = avg_rand_info;
    %     %     pop_table.corrected_info(strcmpi(pop_table.region, current_region)) = corrected_info;

    %     %     %% Average unit random info and correct classification info
    %     %     for unit = 1:2:length(unit_rand_info(1,:))
    %     %         current_unit_column = unit_rand_info(:, unit);
    %     %         %% Verify that labels are consistent before averaging random info
    %     %         % TODO throw error but save file info
    %     %         assert(length(unique(current_unit_column)) == 1);
    %     %         current_unit = current_unit_column{1};
    %     %         avg_rand_info = mean([unit_rand_info{:, unit + 1}]);
    %     %         corrected_info = unit_table.mutual_info(strcmpi(unit_table.region, current_region) ...
    %     %             & strcmpi(unit_table.sig_channels, current_unit)) - avg_rand_info;

    %     %         %% Store unit corrected info and averaged random info
    %     %         unit_struct.(current_region).(current_unit).avg_rand_info = avg_rand_info;
    %     %         unit_table.boot_info(strcmpi(unit_table.region, current_region) ...
    %     %             & strcmpi(unit_table.sig_channels, current_unit)) = avg_rand_info;
    %     %         unit_table.corrected_info(strcmpi(unit_table.region, current_region) ...
    %     %             & strcmpi(unit_table.sig_channels, current_unit)) = corrected_info;
    %     %     end
    %     % end
    % end
end

function [res] = classify(event_struct, unique_events)
    [confusion_matrix, mutual_info, correct_trials, performance] = ...
        psth_classifier(event_struct, unique_events);
    res.confusion_matrix = confusion_matrix;
    res.mutual_info = mutual_info;
    res.correct_trials = correct_trials;
    res.performance = performance;
end

function [res] = create_table()
    % https://www.mathworks.com/matlabcentral/answers/244084-is-there-a-simpler-way-to-create-an-empty-table-with-a-list-of-variablenames#answer_422250
    anlysis_columns = [["region", "string"]; ...
                       ["sig_channels", "string"]; ...
                       ["user_channels", "string"]; ...
                       ["performance", "double"]; ...
                       ["mutual_info", "double"]; ...
                       ["boot_info", "double"]; ...
                       ["corrected_info", "double"]; ...
                       ["synergy_redundancy", "double"]; ...
                       ["synergistic", "double"]; ...
                       ["recording_notes", "string"]];
    res = table('Size',[0,size(anlysis_columns,1)], ...
                'VariableNames', anlysis_columns(:,1), ...
                'VariableTypes', anlysis_columns(:,2));
end