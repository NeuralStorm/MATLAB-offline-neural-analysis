function sepdata = cal_sep_analysis(animal_name, sep_map, window)
sep = cell2mat(sep_map(:,2));
%create time vector for x-axis
time_vec = linspace((window(1).*1000),(window(2)*1000),length(sep));
response_window = find(time_vec >= 5);%%find 5ms after stim
background_window = find(time_vec <= -10);%%10ms before 0 background

chan_data = [];
sepdata = [];
temp1 = [];
pos_sep_valid = [];
neg_sep_valid = [];

sepdata= struct('animal_id', {}, 'channel_name', {}, 'window', {}, 'sep_sliced_data', {}, 'peak_to_peak',{}, 'neg_peak1',{},...
     'neg_peak2',{}, 'neg_peak3',{},  'neg_peak_latency1',{},  'neg_peak_latency2',{},  'neg_peak_latency3',{},...
     'pos_peak1', {}, 'pos_peak2', {}, 'pos_peak3', {}, 'pos_peak_latency1',{} , 'pos_peak_latency2',{} , ...
     'pos_peak_latency3',{} ,'response_dur',{},'background', {},'background_sd',{},'snr',{},'pos_sep_valid',{},...
     'neg_sep_valid',{},'type',{},'response',{}, 'posthresh', {}, 'negthresh', {});

disp(['Analyzing SEP...']);

for i = 1:size(sep,1)
    chan_data = sep(i,:);
    
    background = mean(chan_data(background_window(1:end)));
    background_sd = std(chan_data(background_window(1:end)));
    background_rms = rms(chan_data(background_window(1:end)));
    
    response = chan_data(response_window(1:end));
    response_rms = rms(response);
    snr = 20*log(response_rms./background_rms);%%chgned to db
    
    pos_peak = max(response);
    neg_peak = min(response);%%%what if response is entirely positive?
    peak_to_peak = pos_peak - neg_peak;

    pos_peak_index = find(chan_data >= pos_peak);
    temp1=find(pos_peak_index>=response_window(1));
    pos_peak_latency = time_vec(pos_peak_index(temp1(1)));


    neg_peak_index = find(chan_data <= neg_peak);
    temp1=find(neg_peak_index>=response_window(1));
    neg_peak_latency = time_vec(neg_peak_index(temp1(1)));
    response_dur = abs(neg_peak_latency-pos_peak_latency);

    posthreshbackground = background + (3*background_sd);
    negthreshbackground = background - (3*background_sd);

    if (pos_peak > posthreshbackground)
        pos_sep_valid=1;
    else
        pos_sep_valid=0;
    end

    if (neg_peak < negthreshbackground)
        neg_sep_valid=1;
    else
        neg_sep_valid=0;
    end

    if (pos_sep_valid==1&&(abs(pos_peak_latency)<abs(neg_peak_latency)))
        type='hyperpolarize';
    elseif  (neg_sep_valid==1&&(abs(neg_peak_latency)<abs(pos_peak_latency)))
        type='depolarize';
    else
        type='NaN';
    end
    

    snrthresh = 20*log(2);%%signal rms atleast twice background rms
    if (snr > snrthresh)
        response = 1;
    else
        response = 0;
    end
    

    sepdata(i).animal_id = animal_name;
    sepdata(i).channel_name = sep_map{i, 1};
    sepdata(i).window = window;
    sepdata(i).sep_sliced_data = sep_map{i, 2};
    sepdata(i).posthresh = posthreshbackground;
    sepdata(i).negthresh = negthreshbackground;   
    sepdata(i).peak_to_peak = peak_to_peak;
    sepdata(i).neg_peak1 = neg_peak;
    sepdata(i).neg_peak_latency1 = neg_peak_latency;
    sepdata(i).pos_peak1 = pos_peak;
    sepdata(i).pos_peak_latency1 = pos_peak_latency;
    sepdata(i).response_dur = response_dur;
    sepdata(i).background = background;
    sepdata(i).background_sd = background_sd;
    sepdata(i).snr = snr;
    sepdata(i).pos_sep_valid = pos_sep_valid;
    sepdata(i).neg_sep_valid = neg_sep_valid;
    sepdata(i).type = type;
    sepdata(i).response = response;
    sepdata(i).neg_peak2 = NaN;
    sepdata(i).neg_peak3 = NaN;
    sepdata(i).pos_peak2 = NaN;    
    sepdata(i).pos_peak3 = NaN;
    sepdata(i).neg_peak_latency2 = NaN;
    sepdata(i).neg_peak_latency3 = NaN;
    sepdata(i).pos_peak_latency2 = NaN;
    sepdata(i).pos_peak_latency3 = NaN;
   
    
    
    %    sepdata(i).animal_num = file(1:6);
    end
end

    