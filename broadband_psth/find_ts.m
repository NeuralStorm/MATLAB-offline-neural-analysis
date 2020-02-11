function [ts] = find_ts(dig_sig, sample_rate)
%This function outputs a matrix with two rows - 
%Row 1 contains the time stamp of the low -> high part of the pulse
%Row 2 contains the time stamp of the high -> low part of the pulse

temp_ts_low_high = [];
temp_ts_high_low = [];

% sm_dig = smooth(dig_sig).';  %use this line when there is noise in the dig signal
sm_dig = (dig_sig).';       %use this line when there is NO noise in the dig signal   

% trimCount = 0; 
% 
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


ts = [temp_ts_low_high; temp_ts_high_low];

end

