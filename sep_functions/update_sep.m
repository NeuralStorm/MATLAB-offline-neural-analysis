function [] = update_sep(sep_path, ignore_sessions, trial_range)
    [file_list] = get_file_list(sep_path, '.mat', ignore_sessions);

    for file_index = 1:length(file_list)
        %% Load file contents
        file = [sep_path, '/', file_list(file_index).name];
        load(file, 'sep_struct', 'sep_l2h_map', 'sep_log');
        empty_vars = check_variables(file, sep_struct, sep_l2h_map, sep_log);
        if empty_vars
            continue
        end
        sep_log.trial_range = trial_range;
        sep_log.ignore_sessions = ignore_sessions;

        %% slice
        for channel = fieldnames(sep_struct)'
            if isempty(trial_range)
                sep_slice = sep_struct.(channel{1});
            else
                sep_slice = sep_struct.(channel{1})(trial_range, :);
            end
            sep_l2h_map{strcmpi(sep_l2h_map(:,1), channel{1}), 2} = mean(sep_slice);
        end

        save(file, '-append', 'sep_l2h_map', 'sep_struct', 'sep_log');

    end
end