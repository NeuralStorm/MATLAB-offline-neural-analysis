function [measurements] = process_raw_grf(raw_measurements, event_ts, pre_time, post_time, bin_size, ...
        sampling_rate, n_order, cutoff_freq, filter_type)

    %% Filter data
    %! Check to see how z-scoring data before and after butterworth affects kalman filter
    event_list = [(1:1:length(event_ts(:,1)))', event_ts];
    event_window = -(abs(pre_time)):bin_size:(abs(post_time));
    tot_bins = length(event_window) - 1;
    event_list = repelem(event_list, tot_bins, 1);
    filtered_table = raw_measurements;
    tot_cols = width(raw_measurements);
    all_response = [];
    for column_i = 1:tot_cols
        filtered_data = butterworth(n_order, cutoff_freq, filter_type, table2array(raw_measurements(:, column_i)));
        filtered_table(:, column_i) = num2cell(zscore(filtered_data));
        column_response = [];
        for trial_index = 1:length(event_ts)
            trial_ts = event_ts(trial_index, 2);
            pre_start = round(trial_ts * sampling_rate) - round(abs(pre_time) * sampling_rate);
            post_end = round(trial_ts * sampling_rate) + round(abs(post_time) * sampling_rate);
            response = filtered_data(pre_start:(post_end - 1));
            column_response = [column_response; response];
        end
        all_response = [all_response, column_response];
    end
    response_array = num2cell([event_list, all_response]);
    column_names = ['trial_number'; 'event_label'; 'event_ts'; filtered_table.Properties.VariableNames']';
    measurements = cell2table(response_array);
    measurements.Properties.VariableNames = column_names;

end