function [chan_perf_info, chan_boot_info] = psth_bootstrapper(...
        psth_struct, event_info, bin_size, window_start, window_end, ...
        response_start, response_end, boot_iterations)

    unique_regions = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    [~, tot_bins] = get_bins(window_start, window_end, bin_size);

    %% Bootstrapping
    for reg_i = 1:length(unique_regions)
        region = unique_regions{reg_i};
        chan_order = psth_struct.(region).label_order;
        tot_chans = numel(chan_order);
        %% Preallocate arrays before bootstrapping
        chan_perf_info = prealloc_boot_array(boot_iterations, chan_order);
        chan_boot_info = prealloc_boot_array(boot_iterations, chan_order);

        parfor i = 1:boot_iterations
            %% Shuffle labels
            shuffled_events = event_info;
            shuffled_events.event_indices = shuffled_events.event_indices(randperm(numel(shuffled_events.event_indices)));
            shuffled_struct = create_event_response(psth_struct, shuffled_events); %TODO remove regions from create_event_response()

            %% Unit classification
            chan_s = 1;
            chan_e = tot_bins;
            for chan_i = 1:tot_chans
                %TODO add check to skip channels with all the same values
                %TODO add assert to verify chan_i matches location in preallocated cell arrays
                chan_struct = struct;
                chan = chan_order{chan_i};
                chan_struct.label_order = {chan};
                chan_struct.relative_response = psth_struct.(region).relative_response(:, chan_s:chan_e);
                %% Unit classification
                event_struct = create_event_struct(chan_struct, shuffled_events, ...
                    bin_size, window_start, window_end, response_start, response_end);
                res = classify(event_struct, unique_events);
                chan_perf_info{chan_i, i + 1} = res.performance;
                chan_boot_info{chan_i, i + 1} = res.mutual_info;
                %% Update feature counter
                chan_s = chan_s + tot_bins;
                chan_e = chan_e + tot_bins;
            end

            % %% Population classification
            % [~, shuffled_info, ~, shuffled_perf] = psth_classifier(shuffled_struct.(region), unique_events);
        end
        avg_chan_info = get_avg_boot(chan_boot_info);
        avg_chan_perf = get_avg_boot(chan_perf_info);
    end
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

function [res] = prealloc_boot_array(boot_iterations, chan_order)
    tot_chans = numel(chan_order);
    res = cell(tot_chans, boot_iterations + 1);
    res(:, 1) = chan_order';
end

function [res] = get_avg_boot(boot_array)
    res = mean(cell2mat(boot_array(:, 2:end)), 2);
end