function [consecutive, bin_indeces] = is_consecutive(above_threshold_indeces, sig_bins)
    consecutive_bins = 0;
    consecutive = false;
    bin_indeces = [];
    if length(above_threshold_indeces) >= sig_bins
        difference = diff(above_threshold_indeces);
        for i = 1:length(difference)
            if difference(i) == 1
                consecutive_bins = consecutive_bins + 1;
                bin_indeces = [bin_indeces; above_threshold_indeces(i)];
                if consecutive_bins >= sig_bins
                    consecutive = true;
                end
            elseif consecutive
                break;
            else
                consecutive_bins = 0;
                bin_indeces = [];
            end
        end
    end
end