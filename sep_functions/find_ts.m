function [ts] = find_ts(dig_sig, paired_pulse, isi)
    %This function outputs a matrix with two rows - 
    %Row 1 contains the time stamp of the low -> high part of the pulse
    %Row 2 contains the time stamp of the high -> low part of the pulse

    temp_ts_low_high = [];
    temp_ts_high_low = [];

    % sm_dig = smooth(dig_sig).'; %use this line when there is noise in the dig signal
    sm_dig = (dig_sig).';       %use this line when there is NO noise in the dig signal

    % trimCount = 0; 

    % while sm_dig(length(sm_dig) ~= 0)
    %     sm_dig(length(sm_dig)) = [];
    %     trimCount = trimCount + 1;
    % end

    % sm_adc = smooth(adc_sig).';

    dig_up_down = [];

    x = 1;
    while x <= length(sm_dig)
        if sm_dig(x) == 1
            temp_ts_low_high = [temp_ts_low_high, x];
            while (sm_dig(x) ~= 0 && x < length(sm_dig))
                x = x + 1;
            end
        end
        x = x + 1;
    end

    y = length(sm_dig);
    while y >= 1
        if sm_dig(y) == 1
            temp_ts_high_low = [temp_ts_high_low, y];
            while sm_dig(y) ~= 0 && y > 1
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
end

