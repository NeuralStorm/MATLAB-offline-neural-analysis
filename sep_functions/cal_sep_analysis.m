function sepdata = cal_sep_analysis(animal_name, sep_map, sep_window,...
            baseline_start_window, baseline_end_window, standard_deviation_coefficient, ...
            early_start, early_end, late_start, late_end)
        
sep = cell2mat(sep_map(:,2));
%create time vector for x-axis
time_vec = linspace((sep_window(1).*1000),(sep_window(2)*1000),length(sep));
early_window_range = find((time_vec >= (early_start * 1000)) & (time_vec <= (early_end * 1000)));
late_window_range = find((time_vec >= (late_start * 1000)) & (time_vec <= (late_end * 1000)));

background_window = find((time_vec >= (- abs(baseline_start_window)) * 1000) ...
    & (time_vec <= (- abs(baseline_end_window) * 1000)));

% chan_data = [];
% sepdata = [];
% temp1 = [];
% early_pos_sep_valid = [];
% early_neg_sep_valid = [];

% sepdata= struct('animal_id', {}, 'channel_name', {}, 'sep_window', {}, 'sep_sliced_data', {}, 'peak_to_peak',{}, 'neg_peak1',{},...
%      'neg_peak2',{}, 'neg_peak3',{},  'neg_peak_latency1',{},  'neg_peak_latency2',{},  'neg_peak_latency3',{},...
%      'pos_peak1', {}, 'pos_peak2', {}, 'pos_peak3', {}, 'pos_peak_latency1',{} , 'pos_peak_latency2',{} , ...
%      'pos_peak_latency3',{} ,'response_dur',{},'background', {},'background_sd',{},'snr',{},'pos_sep_valid',{},...
%      'neg_sep_valid',{},'type',{},'response',{}, 'posthresh', {}, 'negthresh', {});
sepdata= struct('animal_id', {}, 'channel_name', {}, 'sep_window', {}, 'early_window', {},...
    'late_window', {}, 'sep_sliced_data', {}, 'peak_to_peak',{},...
    'neg_peak1',{}, 'neg_peak_latency1',{}, 'pos_peak1', {}, 'pos_peak_latency1',{}, 'sig_early', {}, ...
    'neg_peak2',{}, 'neg_peak_latency2',{}, 'pos_peak2', {},  'pos_peak_latency2',{}, 'sig_late', {}, ...
    'neg_peak3',{}, 'neg_peak_latency3',{}, 'pos_peak3', {}, 'pos_peak_latency3',{} , 'sig_response',{} ,...
    'response_dur',{}, 'background', {}, 'background_sd',{}, 'snr',{}, 'pos_sep_valid',{}, ...
    'neg_sep_valid',{}, 'type',{}, 'response',{}, 'posthresh', {}, 'negthresh', {}, 'analysis_notes', {});

disp(['Analyzing SEP...']);

for i = 1:size(sep,1)
    chan_data = sep(i,:);
    
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
    sepdata(i).channel_name = sep_map{i, 1};
    sepdata(i).sep_window = sep_window;
    sepdata(i).early_window = [early_start early_end];
    sepdata(i).late_window = [late_start late_end];
    sepdata(i).sep_sliced_data = sep_map{i, 2};
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
    sepdata(i).sig_response = sig_response;
%     sepdata(i).response_dur = early_response_dur;
    sepdata(i).background = background;
    sepdata(i).background_sd = background_sd;
%     sepdata(i).snr = snr;
%     sepdata(i).neg_sep_valid = early_neg_sep_valid;
%     sepdata(i).type = type;
%     sepdata(i).response = early_response;
    sepdata(i).neg_peak3 = NaN;
    sepdata(i).pos_peak3 = NaN;
    sepdata(i).neg_peak_latency3 = NaN;
    sepdata(i).pos_peak_latency3 = NaN;
    sepdata(i).analysis_notes = [];
   
    
    
    %    sepdata(i).animal_num = file(1:6);
    end
end

    