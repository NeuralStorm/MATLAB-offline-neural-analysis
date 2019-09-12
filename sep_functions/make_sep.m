function [final_sep, sep_struct, analysis_sep_struct] = make_sep(amp_sig, stim_ts, sample_rate, time_window, trial_range)

final_sep = [];
[num_channels, ~] = size(amp_sig);
sep_struct = struct;

disp('Making SEP...');

    for i = 1:num_channels
        temp_row = [];
        temp_sep = [];
        mean_sep = [];

        for x = 1:length(stim_ts)  
            first_sample = stim_ts(x) + (sample_rate * time_window(1));  
            last_sample = stim_ts(x) + (sample_rate * time_window(2)); 

            temp_row = [];

            for y = first_sample:last_sample  
                temp_row = [temp_row, amp_sig{i, 2}(1, y)];
            end
            
            temp_sep = [temp_row; temp_sep];
        end
        sep_struct.(amp_sig{i, 1}) = temp_sep;
        if isempty(trial_range)
            analysis_sep_struct.(amp_sig{i, 1}) = temp_sep;
            mean_sep = mean(temp_sep);
        else
            analysis_sep_struct.(amp_sig{i, 1}) = temp_sep(trial_range, :);
            mean_sep = mean(temp_sep(trial_range, :));
        end

        final_sep = [final_sep; mean_sep];
    end
end