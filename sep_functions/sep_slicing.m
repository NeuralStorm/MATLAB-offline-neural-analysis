function sep_l2h_map = sep_slicing(amp_sig_map, dig_sig, sample_rate, window)
    ts = find_ts(dig_sig, sample_rate);
    [tot_channel, ~] = size(amp_sig_map);
    sep_l2h_map = [];
    amp_sig_mat = cell2mat(amp_sig_map(:,2));
    sep_l2h = make_sep(amp_sig_mat, ts(1,:), sample_rate, window);
    %mapping
    for channel_index = 1:tot_channel   
        sep_l2h_map = [sep_l2h_map; {amp_sig_map{channel_index, 1}}, {sep_l2h(channel_index, :)}];
    end

end

