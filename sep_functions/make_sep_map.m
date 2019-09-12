function [sep_l2h_map, sep_struct, analysis_sep_struct] = make_sep_map(amp_sig_map, dig_sig, sample_rate, time_window, trial_range)
    ts = find_ts(dig_sig, sample_rate);
    [tot_channel, ~] = size(amp_sig_map);
    sep_l2h_map = [];
    % amp_sig_mat = cell2mat(amp_sig_map(:,2));
    [sep_l2h, sep_struct, analysis_sep_struct] = make_sep(amp_sig_map, ts(1,:), sample_rate, time_window, trial_range);
    %mapping
    for channel_index = 1:tot_channel   
        sep_l2h_map = [sep_l2h_map; {amp_sig_map{channel_index, 1}}, {sep_l2h(channel_index, :)}];
    end

end

