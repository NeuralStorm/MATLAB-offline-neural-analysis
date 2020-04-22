function [event_samples] = find_event_samples(dig_sig)
    %Row 1 contains the time stamp of the low -> high part of the pulse
    %Row 2 contains the time stamp of the high -> low part of the pulse

    event_samples = struct;
    [tot_rows, tot_cols] = size(dig_sig);
    for row_i = 1:tot_rows
        temp_ts_low_high = [];
        temp_ts_high_low = [];
        x = 1;
        while x <= tot_cols
            if dig_sig(row_i, x) == 1
                temp_ts_low_high = [temp_ts_low_high, x];
                while (dig_sig(row_i, x) ~= 0 && x < tot_cols)
                    x = x + 1;
                end
            end
            x = x + 1;
        end
    
        y = tot_cols;
        while y >= 1
            if dig_sig(row_i, y) == 1
                temp_ts_high_low = [temp_ts_high_low, y];
                while dig_sig(row_i, y) ~= 0 && y > 1
                    y = y - 1;
                end
            end
            y = y - 1;
        end
    
        temp_ts_high_low = fliplr(temp_ts_high_low);
    
        ts = [temp_ts_low_high; temp_ts_high_low];
        event_str = ['event_', num2str(row_i)];
        if isempty(ts)
            continue
        else
            event_samples.(event_str) = ts;
        end
    end
end

