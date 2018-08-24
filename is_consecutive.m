function [consecutive] = is_consecutive(above_threshold_indeces, sig_bins)
    consecutive_bins = 0;
    consecutive = false;
    if length(above_threshold_indeces) >= sig_bins
        for bin = 1:(length(above_threshold_indeces) - 1)
            if above_threshold_indeces(bin + 1) - above_threshold_indeces(bin) == 1
                consecutive_bins = consecutive_bins + 1;
                if consecutive_bins >= sig_bins
                    consecutive = true;
                    break;
                end
            else
                consecutive_bins = 0;
            end
        end
    end
end