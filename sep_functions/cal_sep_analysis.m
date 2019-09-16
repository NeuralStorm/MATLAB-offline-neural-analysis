function sepdata = cal_sep_analysis(animal_name, sep_map, sep_window,...
            baseline_window_start, baseline_window_end, standard_deviation_coefficient, ...
            early_response_start, early_response_end, late_response_start, late_response_end)
        
    sep = {sep_map.data};
    %create time vector for x-axis
    time_vec = linspace((sep_window(1).*1000),(sep_window(2)*1000),length(sep{1,1}));
    early_window_range = find((time_vec >= (early_response_start * 1000)) & (time_vec <= (early_response_end * 1000)));
    late_window_range = find((time_vec >= (late_response_start * 1000)) & (time_vec <= (late_response_end * 1000)));

    background_window = find((time_vec >= (- abs(baseline_window_start)) * 1000) ...
        & (time_vec <= (- abs(baseline_window_end) * 1000)));

    sepdata= struct('animal_id', {}, 'channel_name', {}, 'sep_sliced_data', {}, 'user_channels', {},...
        'label', {}, 'label_id', {}, 'exp_group', {}, 'exp_cond', {}, 'rec_session', {}, 'notch', {}, 'filter', {},...
        'sep_window', {}, 'early_window', {},'late_window', {}, 'posthresh', {}, 'negthresh', {}, ...
        'neg_peak1',{}, 'neg_peak_latency1',{}, 'pos_peak1', {}, 'pos_peak_latency1',{}, 'sig_early', {}, ...
        'neg_peak2',{}, 'neg_peak_latency2',{}, 'pos_peak2', {},  'pos_peak_latency2',{}, 'sig_late', {}, ...
        'neg_peak3',{}, 'pos_peak3', {}, 'neg_peak_latency3',{} , 'pos_peak_latency3',{} , 'sig_response',{} ,...
        'background', {}, 'background_sd',{}, 'analysis_notes', {});

    disp(['Analyzing SEP...']);

    for i = 1:size(sep,2)
        chan_data = cell2mat(sep(i));

        background = mean(chan_data(background_window(1:end)));
        background_sd = std(chan_data(background_window(1:end)));

    %     background_rms = rms(chan_data(background_window(1:end)));

        early_response = chan_data(early_window_range(1:end));
        late_response = chan_data(late_window_range(1:end));
        %     response_rms = rms(early_response);
    %      peak_to_peak = early_pos_peak - early_neg_peak;
    %     snr = 20*log(response_rms ./ background_rms);%%chgned to db

    %     early_pos_peak = max(early_response);
    %     early_neg_peak = min(early_response);%%%what if response is entirely positive?
    % 
    %     early_pos_peak_index = find(chan_data >= early_pos_peak);
    %     temp1=find(early_pos_peak_index >= early_window(1));
    %     early_pos_peak_latency = time_vec(early_pos_peak_index(temp1(1)));

    %     early_neg_peak_index = find(chan_data <= early_neg_peak);
    %     temp1 = find(early_neg_peak_index >= early_window(1));
    %     early_neg_peak_latency = time_vec(early_neg_peak_index(temp1(1)));
    %     early_response_dur = abs(early_neg_peak_latency-early_pos_peak_latency);

        posthreshbackground = background + (standard_deviation_coefficient * background_sd);
        negthreshbackground = background - (standard_deviation_coefficient * background_sd);


        % early window
            [early_pos_peak, early_neg_peak, early_pos_peak_latency, early_neg_peak_latency, ...
        sig_early] = select_peak(early_response, posthreshbackground, negthreshbackground, time_vec, early_window_range);

        % late window
            [late_pos_peak, late_neg_peak, late_pos_peak_latency, late_neg_peak_latency, ...
        sig_late] = select_peak(late_response, posthreshbackground, negthreshbackground, time_vec, late_window_range);

        if sig_early || sig_late
            sig_response = 1;
        else
            sig_response = 0;
        end

    %     if (early_pos_sep_valid==1 && (abs(early_pos_peak_latency) < abs(early_neg_peak_latency)))
    %         type='hyperpolarize';
    %     elseif  (early_neg_sep_valid==1 && (abs(early_neg_peak_latency) < abs(early_pos_peak_latency)))
    %         type='depolarize';
    %     else
    %         type='NaN';
    %     end

    %     snrthresh = 20 * log(2);%%signal rms atleast twice background rms
    %     if (snr > snrthresh)
    %         early_response = 1;
    %     else
    %         early_response = 0;
    %     end

        sepdata(i).animal_id = animal_name;
        sepdata(i).channel_name = sep_map(i).sig_channels;
        sepdata(i).sep_sliced_data = sep_map(i).data;    
        sepdata(i).user_channels = sep_map(i).user_channels;
        sepdata(i).label = sep_map(i).label;
        sepdata(i).label_id = sep_map(i).label_id;
        sepdata(i).exp_group = sep_map(i).exp_group;
        sepdata(i).exp_cond = sep_map(i).exp_cond;
        sepdata(i).rec_session = sep_map(i).rec_session;
        sepdata(i).notch = sep_map(i).notch;
        sepdata(i).filter = sep_map(i).filter;
        sepdata(i).sep_window = sep_window;
        sepdata(i).early_window = [early_response_start early_response_end];
        sepdata(i).late_window = [late_response_start late_response_end];    
        sepdata(i).posthresh = posthreshbackground;
        sepdata(i).negthresh = negthreshbackground;   
    %     sepdata(i).peak_to_peak = peak_to_peak;
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
    %     sepdata(i).response_dur = early_response_dur;
        sepdata(i).background = background;
        sepdata(i).background_sd = background_sd;
    %     sepdata(i).snr = snr;
    %     sepdata(i).neg_sep_valid = early_neg_sep_valid;
    %     sepdata(i).type = type;
    %     sepdata(i).response = early_response;

        sepdata(i).analysis_notes = [];
    end
    
    
end