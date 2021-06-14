function [pop_table, chan_table] = scheme_psth_bootstrapper(...
        rr_data, event_info, bin_size, window_start, window_end, ...
        response_start, response_end, boot_iterations)

    unique_ch_groups = fieldnames(rr_data);
    unique_events = unique(event_info.event_labels);
    [~, tot_bins] = get_bins(response_start, response_end, bin_size);

    %% Create population table
    pop_headers = [["scheme", "string"]; ["chan_group", "string"]; ["boot_perf", "double"]; ...
                   ["boot_mutual_info", "double"]];
    pop_table = prealloc_table(pop_headers, [0, size(pop_headers, 1)]);
    %% Create channel table
    chan_headers = [["scheme", "string"]; ["channel", "string"]; ["boot_perf", "double"]; ...
                    ["boot_mutual_info", "double"]];
    chan_table = prealloc_table(chan_headers, [0, size(chan_headers, 1)]);

    %% Bootstrapping
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        chan_order = rr_data.(ch_group).chan_order;
        tot_chans = numel(chan_order);
        %% Preallocate chan_group boot arrays
        t_reg_perf = prealloc_boot_array(boot_iterations, 1);
        t_reg_info = prealloc_boot_array(boot_iterations, 1);
        non_t_reg_perf = prealloc_boot_array(boot_iterations, 1);
        non_t_reg_info = prealloc_boot_array(boot_iterations, 1);
        %% Preallocate channel boot arrays
        t_chan_perf = prealloc_boot_array(boot_iterations, tot_chans);
        t_chan_info = prealloc_boot_array(boot_iterations, tot_chans);
        non_t_chan_perf = prealloc_boot_array(boot_iterations, tot_chans);
        non_t_chan_info = prealloc_boot_array(boot_iterations, tot_chans);

        parfor i = 1:boot_iterations
            %% Shuffle event labels
            shuffled_events = event_info;
            shuffled_events.event_indices = shuffled_events.event_indices(randperm(numel(shuffled_events.event_indices)));
            %% Create shuffled event struct to classify with
            % shuffled_struct = create_event_struct(rr_data.(ch_group), shuffled_events, ...
            %     bin_size, window_start, window_end, response_start, response_end);

            %% chan classification
            chan_s = 1;
            chan_e = tot_bins;
            for chan_i = 1:tot_chans
                chan_rr = rr_data.(ch_group).relative_response(:, chan_s:chan_e);
                chan_rr = slice_rr(chan_rr, bin_size, window_start, ...
                    window_end, response_start, response_end);
                %% slice channel from shuffled event struct
                % event_struct = slice_event_channels(shuffled_struct, chan_s, chan_e);
                % [~, shuffled_info, ~, shuffled_perf] = psth_classifier(event_struct, unique_events);
                %% template
                [~, shuffled_info, ~, shuffled_perf] = psth_classifier_templates(chan_rr, shuffled_events, 'template');
                t_chan_perf(chan_i, i) = shuffled_perf;
                t_chan_info(chan_i, i) = shuffled_info;
                %% non template
                [~, shuffled_info, ~, shuffled_perf] = psth_classifier_templates(chan_rr, shuffled_events, 'non_template');
                non_t_chan_perf(chan_i, i) = shuffled_perf;
                non_t_chan_info(chan_i, i) = shuffled_info;
                %% Update channel counter
                chan_s = chan_s + tot_bins;
                chan_e = chan_e + tot_bins;
            end

            %% Population classification
            % [~, shuffled_info, ~, shuffled_perf] = psth_classifier(shuffled_struct, unique_events);
            % reg_perf(1, i) = shuffled_perf;
            % reg_info(1, i) = shuffled_info;

            ch_group_rr = rr_data.(ch_group).relative_response;
            ch_group_rr = slice_rr(ch_group_rr, bin_size, window_start, ...
                window_end, response_start, response_end);
            %% Population classification: Template
            [~, shuffled_info, ~, shuffled_perf] = psth_classifier_templates(ch_group_rr, shuffled_events, 'template');
            t_reg_perf(1, i) = shuffled_perf;
            t_reg_info(1, i) = shuffled_info;

            %% Population classification: non Template
            [~, shuffled_info, ~, shuffled_perf] = psth_classifier_templates(ch_group_rr, shuffled_events, 'non_template');
            non_t_reg_perf(1, i) = shuffled_perf;
            non_t_reg_info(1, i) = shuffled_info;
        end
        %% chan_group avg
        t_avg_reg_perf = get_avg_boot(t_reg_perf);
        t_avg_reg_info = get_avg_boot(t_reg_info);
        non_t_avg_reg_perf = get_avg_boot(non_t_reg_perf);
        non_t_avg_reg_info = get_avg_boot(non_t_reg_info);
        %% Add chan_group boot information to pop table
        a = [{'template'}, {ch_group}, t_avg_reg_perf, t_avg_reg_info];
        b = [{'non_template'}, {ch_group}, non_t_avg_reg_perf, non_t_avg_reg_info];
        c = [a; b];
        pop_table = vertcat_cell(pop_table, c, pop_headers(:, 1), "after");
        %% Channel avg
        t_avg_chan_perf = get_avg_boot(t_chan_perf);
        t_avg_chan_info = get_avg_boot(t_chan_info);
        non_t_avg_chan_perf = get_avg_boot(non_t_chan_perf);
        non_t_avg_chan_info = get_avg_boot(non_t_chan_info);
        %% Add channel boot information to pop table
        temp_scheme = repmat({'template'}, [numel(chan_order), 1]);
        non_temp_scheme = repmat({'non_template'}, [numel(chan_order), 1]);
        a = [temp_scheme, chan_order, num2cell(t_avg_chan_perf), num2cell(t_avg_chan_info)];
        b = [non_temp_scheme, chan_order, num2cell(non_t_avg_chan_perf), num2cell(non_t_avg_chan_info)];
        c = [a; b];
        chan_table = vertcat_cell(chan_table, c, chan_headers(:, 1), "after");
    end
end

function [res] = prealloc_boot_array(boot_iterations, tot_chans)
    res = nan(tot_chans, boot_iterations);
end

function [res] = get_avg_boot(boot_array)
    res = mean(boot_array, 2);
end