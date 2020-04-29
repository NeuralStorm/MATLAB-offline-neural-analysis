function sepdata = cal_sep_analysis(filename_meta, sep_map, sep_window, ...
            config)

    sep = {sep_map.data};
    %create time vector for x-axis
    time_vec = linspace((sep_window(1).*1000), (sep_window(2)*1000), ...
        length(sep{1,1}));
    early_window_range = find((time_vec >= (config.early_response_start * 1000)) ...
        & (time_vec <= (config.early_response_end * 1000)));
    late_window_range = find((time_vec >= (config.late_response_start * 1000)) ...
        & (time_vec <= (config.late_response_end * 1000)));

    background_window = find((time_vec >= (- abs(config.baseline_start)) * 1000) ...
        & (time_vec <= (- abs(config.baseline_end) * 1000)));

    sepdata= struct('animal_id', {}, 'event', {}', 'channel_name', {}, 'sep_sliced_data', {}, 'user_channels', {},...
        'label', {}, 'label_id', {}, 'exp_group', {}, 'exp_cond', {}, 'rec_session', {}, 'notch', {}, 'filter', {}, ...
        'sep_window', {}, 'early_window', {},'late_window', {}, 'posthresh', {}, 'negthresh', {}, ...
        'neg_peak1', {}, 'neg_peak_latency1', {}, 'pos_peak1', {}, 'pos_peak_latency1', {}, 'sig_early', {}, ...
        'neg_peak2', {}, 'neg_peak_latency2', {}, 'pos_peak2', {},  'pos_peak_latency2', {}, 'sig_late', {}, ...
        'neg_peak3', {}, 'pos_peak3', {}, 'neg_peak_latency3', {}, 'pos_peak_latency3', {} , 'sig_response',{}, ...
        'background', {}, 'background_sd', {}, 'analysis_notes', {});

    for i = 1:size(sep,2)
        chan_data = cell2mat(sep(i));

        background = mean(chan_data(background_window(1:end)));
        background_sd = std(chan_data(background_window(1:end)));

        early_response = chan_data(early_window_range(1:end));
        late_response = chan_data(late_window_range(1:end));

        posthreshbackground = background + (config.threshold_scalar * background_sd);
        negthreshbackground = background - (config.threshold_scalar * background_sd);


        % early window
        [early_pos_peak, early_neg_peak, early_pos_peak_latency, ...
            early_neg_peak_latency, sig_early] = select_peak(early_response, ...
            posthreshbackground, negthreshbackground, time_vec, early_window_range);

        % late window
        [late_pos_peak, late_neg_peak, late_pos_peak_latency, ...
            late_neg_peak_latency, sig_late] = select_peak(late_response, ...
            posthreshbackground, negthreshbackground, time_vec, late_window_range);

        if sig_early || sig_late
            sig_response = 1;
        else
            sig_response = 0;
        end

        sepdata(i).animal_id = filename_meta.animal_id;
        sepdata(i).channel_name = sep_map(i).sig_channels;
        sepdata(i).sep_sliced_data = sep_map(i).data;
        sepdata(i).event = sep_map(i).event;
        sepdata(i).user_channels = sep_map(i).user_channels;
        sepdata(i).label = sep_map(i).label;
        sepdata(i).label_id = sep_map(i).label_id;
        sepdata(i).exp_group = filename_meta.experimental_group;
        sepdata(i).exp_cond = filename_meta.experimental_condition;
        sepdata(i).rec_session = filename_meta.session_num;
        sepdata(i).notch = config.notch_filt;
        sepdata(i).filter = config.filt_freq{:};
        %%
        sepdata(i).sep_window = sep_window;
        sepdata(i).early_window = [config.early_response_start config.early_response_end];
        sepdata(i).late_window = [config.late_response_start config.late_response_end];
        sepdata(i).posthresh = posthreshbackground;
        sepdata(i).negthresh = negthreshbackground;
        sepdata(i).neg_peak1 = early_neg_peak;
        sepdata(i).neg_peak_latency1 = early_neg_peak_latency;
        sepdata(i).pos_peak1 = early_pos_peak;
        sepdata(i).pos_peak_latency1 = early_pos_peak_latency;
        sepdata(i).sig_early = sig_early;
        sepdata(i).neg_peak2 = late_neg_peak;
        sepdata(i).neg_peak_latency2 = late_neg_peak_latency;
        sepdata(i).pos_peak2 = late_pos_peak;
        sepdata(i).pos_peak_latency2 = late_pos_peak_latency;
        sepdata(i).sig_late = sig_late;
        sepdata(i).neg_peak3 = NaN;
        sepdata(i).pos_peak3 = NaN;
        sepdata(i).neg_peak_latency3 = NaN;
        sepdata(i).pos_peak_latency3 = NaN;
        sepdata(i).sig_response = sig_response;
        sepdata(i).background = background;
        sepdata(i).background_sd = background_sd;
        sepdata(i).analysis_notes = 'n/a';
    end
end