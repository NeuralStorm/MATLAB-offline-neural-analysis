function [ts] = find_ts(failed_path, filename, dig_sig, paired_pulse, isi, expected_trials)
    %This function outputs a matrix with two rows - 
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

    % %Temporary solution to remove paired pulse time stamps
    if paired_pulse && isi ~= 0
        for sample_i = 2:2:length(temp_ts_low_high)
            %% round gap to tens place (-1)
            low_gap = round(temp_ts_low_high(sample_i) - temp_ts_low_high(sample_i - 1), -1);
            high_gap = round(temp_ts_high_low(sample_i) - temp_ts_high_low(sample_i - 1), -1);
            if mod(low_gap, isi) ~= 0
                error('Paired pulse isi and time gap in samples do not match, sample gap: %d', low_gap);
            elseif mod(high_gap, isi) ~= 0
                error('Paired pulse isi and time gap in samples do not match, sample gap: %d', high_gap);
            end
        end
        temp_ts_low_high = temp_ts_low_high(:, 1:2:end);
        temp_ts_high_low = temp_ts_high_low(:, 1:2:end);
    end
    ts = [temp_ts_low_high; temp_ts_high_low];
    [~, tot_trials] = size(ts);
    if tot_trials == 0
        error('No event samples were found in the continuous event channel');
    elseif tot_trials < expected_trials || tot_trials > expected_trials
        try
            error('Found %d trials, but expected %d trials', ...
                tot_trials, expected_trials);
        catch ME
            handle_ME(ME, failed_path, filename)
        end
    end
end

