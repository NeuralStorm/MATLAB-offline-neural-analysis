function sep_data = format_sep(data_table, event_info, ...
        sample_rate, window_start, window_end)
    table_headers = [{'channel'}, {'user_channels'}, {'chan_group'}, {'chan_group_id'}];

    sep_data = data_table(:,ismember(data_table.Properties.VariableNames, table_headers));

    event_ts = event_info.event_ts;

    %% Create array of all trial samples based on event times
    trial_indices = arrayfun(@(x) ...
        [(x + (window_start*sample_rate)):(x+(window_end*sample_rate))], ...
        event_ts, 'UniformOutput', false);
    seps = cell(height(data_table), 1);
    for trial_i = 1:numel(trial_indices)
        trial = trial_indices{trial_i};
        for chan_i = 1:height(data_table)
            a = data_table.channel_data(chan_i, trial);
            seps{chan_i, :} = [seps{chan_i,:}; a];
        end
    end
    sep_data = horzcat_cell(sep_data, seps, {'channel_data'}, 'after');
end