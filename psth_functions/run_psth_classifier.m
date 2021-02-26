function [pop_table, res_struct] = run_psth_classifier(psth_struct, event_info, bin_size, window_start, window_end, ...
    response_start, response_end)
    pop_table = create_table();
    unique_regions = fieldnames(psth_struct);
    for reg_i = 1:length(unique_regions)
        region = unique_regions{reg_i};

        %% Population classification
        res_struct.(region) = run_pop(psth_struct.(region), event_info, ...
            bin_size, window_start, window_end, response_start, response_end);

        pop_table = add_row(pop_table, region, res_struct.(region).performance, ...
            res_struct.(region).mutual_info);
    end
end

function [res] = classify(event_struct, unique_events)
    res = struct;
    [confusion_matrix, mutual_info, correct_trials, performance] = ...
        psth_classifier(event_struct, unique_events);
    res.confusion_matrix = confusion_matrix;
    res.mutual_info = mutual_info;
    res.correct_trials = correct_trials;
    res.performance = performance;
end

function [res] = run_pop(psth_struct, event_info, bin_size, window_start, ...
        window_end, response_start, response_end)
    %% Population classification
    unique_events = unique(event_info.event_labels);
    event_struct = create_event_struct(psth_struct, event_info, ...
        bin_size, window_start, window_end, response_start, response_end);
    res = classify(event_struct, unique_events);
end

function [res] = create_table()
    % https://www.mathworks.com/matlabcentral/answers/244084-is-there-a-simpler-way-to-create-an-empty-table-with-a-list-of-variablenames#answer_422250
    anlysis_columns = [["label", "string"]; ...
                       ["performance", "double"]; ...
                       ["mutual_info", "double"]];
    res = table('Size',[0,size(anlysis_columns,1)], ...
                'VariableNames', anlysis_columns(:,1), ...
                'VariableTypes', anlysis_columns(:,2));
end

function [res_table] = add_row(res_table, label, perf, mutual_info)
    %TODO make into varargin
    row = {label, perf, mutual_info};
    row = cell2table(row, 'VariableNames', ["label", "performance", "mutual_info"]);
    res_table = [res_table; row];
end