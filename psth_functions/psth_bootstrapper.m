function [pop_table, chan_table] = psth_bootstrapper(...
        rr_data, event_info, bin_size, window_start, window_end, ...
        response_start, response_end, boot_iterations)

    unique_ch_groups = fieldnames(rr_data);
    unique_events = unique(event_info.event_labels);
    [~, tot_bins] = get_bins(response_start, response_end, bin_size);

    %% Create population table
    pop_headers = [["chan_group", "string"]; ["boot_perf", "double"]; ...
                   ["boot_mutual_info", "double"]];
    pop_table = prealloc_table(pop_headers, [0, size(pop_headers, 1)]);
    %% Create channel table
    chan_headers = [["channel", "string"]; ["boot_perf", "double"]; ...
                    ["boot_mutual_info", "double"]];
    chan_table = prealloc_table(chan_headers, [0, size(chan_headers, 1)]);

    %% Bootstrapping
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        chan_order = rr_data.(ch_group).chan_order;
        tot_chans = numel(chan_order);
        %% Preallocate chan_group boot arrays
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
            shuffled_struct = create_event_struct(rr_data.(ch_group), shuffled_events, ...
                bin_size, window_start, window_end, response_start, response_end);

            %% chan classification
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
        %% chan_group avg
        avg_reg_perf = get_avg_boot(reg_perf);
        avg_reg_info = get_avg_boot(reg_info);
        %% Add chan_group boot information to pop table
        a = [{ch_group}, avg_reg_perf, avg_reg_info];
        pop_table = vertcat_cell(pop_table, a, pop_headers(:, 1), "after");
        %% Channel avg
        avg_chan_perf = get_avg_boot(chan_perf);
        avg_chan_info = get_avg_boot(chan_info);
        %% Add channel boot information to pop table
        a = [chan_order, num2cell(avg_chan_perf), num2cell(avg_chan_info)];
        chan_table = vertcat_cell(chan_table, a, chan_headers(:, 1), "after");
    end
end

function [res] = prealloc_boot_array(boot_iterations, tot_chans)
    res = nan(tot_chans, boot_iterations);
end

function [res] = get_avg_boot(boot_array)
    res = mean(boot_array, 2);
end