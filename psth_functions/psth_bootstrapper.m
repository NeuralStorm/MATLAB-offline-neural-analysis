function [pop_table, chan_table] = psth_bootstrapper(...
        psth_struct, event_info, bin_size, window_start, window_end, ...
        response_start, response_end, boot_iterations)

    unique_regions = fieldnames(psth_struct);
    unique_events = unique(event_info.event_labels);
    [~, tot_bins] = get_bins(response_start, response_end, bin_size);

    %% Create population table
    pop_headers = [["region", "string"]; ["boot_perf", "double"]; ...
                   ["boot_mutual_info", "double"]];
    pop_table = table('Size',[0, 3], ...
        'VariableNames', pop_headers(:, 1), ...
        'VariableTypes', pop_headers(:, 2));
    %% Create channel table
    chan_headers = [["channel", "string"]; ["boot_perf", "double"]; ...
                    ["boot_mutual_info", "double"]];
    chan_table = table('Size',[0, 3], ...
        'VariableNames', chan_headers(:, 1), ...
        'VariableTypes', chan_headers(:, 2));

    %% Bootstrapping
    for reg_i = 1:length(unique_regions)
        region = unique_regions{reg_i};
        chan_order = psth_struct.(region).label_order;
        tot_chans = numel(chan_order);
        %% Preallocate region boot arrays
        reg_perf = prealloc_boot_array(boot_iterations, 1);
        reg_info = prealloc_boot_array(boot_iterations, 1);
        %% Preallocate channel boot arrays
        chan_perf = prealloc_boot_array(boot_iterations, tot_chans);
        chan_info = prealloc_boot_array(boot_iterations, tot_chans);

        parfor i = 1:boot_iterations
            %% Shuffle event labels
            shuffled_events = event_info;
            shuffled_events.event_indices = shuffled_events.event_indices(randperm(numel(shuffled_events.event_indices)));
            %% Create shuffled event struct to classify with
            shuffled_struct = create_event_struct(psth_struct.(region), shuffled_events, ...
                bin_size, window_start, window_end, response_start, response_end);

            %% Unit classification
            chan_s = 1;
            chan_e = tot_bins;
            for chan_i = 1:tot_chans
                %% slice channel from shuffled event struct
                event_struct = slice_event_channels(shuffled_struct, chan_s, chan_e);
                [~, shuffled_info, ~, shuffled_perf] = psth_classifier(event_struct, unique_events);
                chan_perf(chan_i, i) = shuffled_perf;
                chan_info(chan_i, i) = shuffled_info;
                %% Update channel counter
                chan_s = chan_s + tot_bins;
                chan_e = chan_e + tot_bins;
            end

            %% Population classification
            [~, shuffled_info, ~, shuffled_perf] = psth_classifier(shuffled_struct, unique_events);
            reg_perf(1, i) = shuffled_perf;
            reg_info(1, i) = shuffled_info;
        end
        %% Region avg
        avg_reg_perf = get_avg_boot(reg_perf);
        avg_reg_info = get_avg_boot(reg_info);
        %% Add region boot information to pop table
        a = [{region}, avg_reg_perf, avg_reg_info];
        pop_table = concat_cell(pop_table, a, pop_headers(:, 1));
        %% Channel avg
        avg_chan_perf = get_avg_boot(chan_perf);
        avg_chan_info = get_avg_boot(chan_info);
        %% Add channel boot information to pop table
        a = [chan_order, num2cell(avg_chan_perf), num2cell(avg_chan_info)];
        chan_table = concat_cell(chan_table, a, chan_headers(:, 1));
    end
end

function [res] = prealloc_boot_array(boot_iterations, tot_chans)
    res = nan(tot_chans, boot_iterations);
end

function [res] = get_avg_boot(boot_array)
    res = mean(boot_array, 2);
end