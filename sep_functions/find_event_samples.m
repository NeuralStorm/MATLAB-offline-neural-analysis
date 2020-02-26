function [ts] = find_event_samples(dig_sig)
    %Row 1 contains the time stamp of the low -> high part of the pulse
    %Row 2 contains the time stamp of the high -> low part of the pulse

    temp_ts_low_high = [];
    temp_ts_high_low = [];

    x = 1;
    while x <= length(dig_sig)
        if dig_sig(x) == 1
            temp_ts_low_high = [temp_ts_low_high, x];
            while (dig_sig(x) ~= 0 && x < length(dig_sig))
                x = x + 1;
            end
        end
        x = x + 1;
    end

    y = length(dig_sig);
    while y >= 1
        if dig_sig(y) == 1
            temp_ts_high_low = [temp_ts_high_low, y];
            while dig_sig(y) ~= 0 && y > 1
                y = y - 1;
            end
        end
        y = y - 1;
    end

    temp_ts_high_low = fliplr(temp_ts_high_low);

    ts = [temp_ts_low_high; temp_ts_high_low];
end

