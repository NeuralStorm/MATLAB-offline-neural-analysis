function [event_info] = find_event_samples(dig_sig)
    %TODO figure out how to assert square pulse
    %x contains the time stamp of the low -> high part of the pulse
    %y contains the time stamp of the high -> low part of the pulse

    headers = [["event_labels", "string"]; ["event_ts", "double"]; ...
    ["event_indices", "double"]];
    event_info = prealloc_table(headers, [0, size(headers, 1)]);
    [tot_rows, tot_cols] = size(dig_sig);
    for row_i = 1:tot_rows
        lo_hi = [];
        hi_lo = [];
        x = 1;
        trial_i = 1;
        while x <= tot_cols
            if dig_sig(row_i, x) == 1
                a = [{['event_', num2str(row_i), '_start']}, x, trial_i];
                lo_hi = [lo_hi; a];
                trial_i = trial_i + 1;
                while (dig_sig(row_i, x) ~= 0 && x < tot_cols)
                    x = x + 1;
                end
            end
            x = x + 1;
        end
        trial_i = trial_i - 1;
        y = tot_cols;
        while y >= 1
            if dig_sig(row_i, y) == 1
                a = [{['event_', num2str(row_i), '_end']}, y, trial_i];
                hi_lo = [hi_lo; a];
                trial_i = trial_i - 1;
                while dig_sig(row_i, y) ~= 0 && y > 1
                    y = y - 1;
                end
            end
            y = y - 1;
        end

        a = [lo_hi; hi_lo];
        event_info = vertcat_cell(event_info, a, headers(:, 1), "after");
        event_info = sortrows(event_info, 'event_ts');
    end
end

