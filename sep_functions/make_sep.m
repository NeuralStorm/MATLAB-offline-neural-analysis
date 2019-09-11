function [final_sep] = make_sep(amp_sig, stim_ts, sample_rate, window)

final_sep = [];
[num_channels, ~] = size(amp_sig);

disp('Making SEP...');

    for i = 1:num_channels

        temp_row = [];
        temp_sep = [];
        mean_sep = [];
    
        for x = 1:length(stim_ts)  
            first_sample = stim_ts(x) + (sample_rate * window(1));  
            last_sample = stim_ts(x) + (sample_rate * window(2)); 

            temp_row = [];

            for y = first_sample:last_sample  
                temp_row = [temp_row, amp_sig(i, y)];
            end
            
            temp_sep = [temp_row; temp_sep];
        end

        mean_sep = mean(temp_sep);
        final_sep = [final_sep; mean_sep];
    end
end