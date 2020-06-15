function [baseline_struct, response_struct] = create_analysis_windows(selected_data, psth_struct, ...
    window_start, baseline_start, baseline_end, window_end, response_start, response_end, bin_size, window_shift_time)

    check_time(window_start, baseline_start, baseline_end, window_end, response_start, response_end, bin_size)

    pre_event_bins = (length(window_start:bin_size:window_shift_time)) - 1;
    post_event_bins = (length(window_shift_time:bin_size:window_end)) - 1;

    baseline_bins = (length(baseline_start:bin_size:baseline_end)) - 1;
    response_bins = (length(response_start:bin_size:response_end)) - 1;

    all_events = psth_struct.all_events;

    baseline_start_i = round(((abs(window_start) - abs(baseline_start)) / bin_size));
    response_start_i = round(abs((abs(window_shift_time) - abs(response_start)) / bin_size));

    unique_regions = setdiff(fieldnames(psth_struct), 'all_events');
    baseline_struct = struct;
    baseline_struct.all_events = all_events;
    response_struct = struct;
    response_struct.all_events = all_events;
    for region_index = 1:length(unique_regions)
        region = unique_regions{region_index};
        region_labels = selected_data.(region).sig_channels;
        region_response = psth_struct.(region).relative_response;
        %% Seperate pre and post response times
        [pre_response, post_response] = split_time(region_response, pre_event_bins, post_event_bins);

        %% slice out baseline window
        baseline_response = slice_window(pre_response, pre_event_bins, baseline_start_i, baseline_bins);
        if isnan(baseline_response)
            baseline_struct = NaN;
        else
            baseline_struct.(region) = split_relative_response(baseline_response, region_labels, ...
                all_events, baseline_bins);
            baseline_struct.(region).relative_response = baseline_response;
        end

        %% Slice out response window
        response_window = slice_window(post_response, post_event_bins, response_start_i, response_bins);
        if isnan(response_window)
            response_struct = NaN;
        else
            response_struct.(region) = split_relative_response(response_window, region_labels, ...
                all_events, response_bins);
            response_struct.(region).relative_response = response_window;
        end
    end

end

function [psth_window] = slice_window(response, tot_bins, start_time_i, tot_window_bins)
    if isnan(response)
        psth_window = NaN;
        return
    end
    assert(tot_window_bins ~= 0);
    label_start = 1;
    label_end = tot_bins;
    [~, tot_cols] = size(response);
    psth_window = [];
    while label_end <= tot_cols
        window_start = label_start + start_time_i;
        window_end = window_start + tot_window_bins - 1;
        assert(window_end <= tot_cols)
        psth_window = [psth_window, response(:, window_start:window_end)];
        % Update counter
        label_end = label_end + tot_bins;
        label_start = label_end - tot_bins + 1;
    end
end