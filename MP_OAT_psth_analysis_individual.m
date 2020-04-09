%right now runs on the assumption that psth_struct is already loaded into
%the matlab workspace. To eventually be turned into a function that gets
%psth_struct passed in


%% Event Codes
%{ 
PSTH's used for determining if a neuron prefers the right or left paw:
Event 1: a grouped PSTH for all steps of the left paw near the obstacle
Event 2: a grouped PSTH for all steps of the right paw near the obstacle


Individual PSTH's

Left paw leading sequence
step -3 of left paw: event 41
step -3 of right paw: event 52
step -2 of left paw: 61
step -2 of right paw: 72
step -1 of left paw: 81
step -1 of right paw: 92
step 0 of left paw: 101 (leading step over obstacle)
step 0 of right paw: 112 (trailing step over obatacle)
step 1 of left paw: 121
step 1 of right paw: 132
step 2 of left paw: 141
step 2 of right paw: 152

Right paw leading sequence
step -3 of right paw: 42
step -3 of left paw: 51
step -2 of right paw: 62
step -2 of left paw: 71
step -1 of right paw: 82
step -1 of left paw: 91
step 0 of right paw: 102 (leading step over obstacle)
step 0 of left paw: 111 (trailing step over obstacle)
step 1 of right paw: 122
step 1 of left paw: 131
step 2 of right paw: 142
step 2 of left paw: 151


Grouped PSTH's

Event 998: a grouped psth of all steps near obstacle, used for dtermining
if a nuron is modulated while steping near an obstacle

Event 999: a grouped psth of all steps not near the obstacle, used as a
background psth (may need to be downsampled)
%}

%% Detrmine if left leading session or right leading session
leading_steps_by_left_paw=size(psth_struct.All.event_101.relative_response,1);
leading_steps_by_right_paw=size(psth_struct.All.event_102.relative_response,1);
if leading_steps_by_left_paw > leading_steps_by_right_paw
    leading_paw=1;
else
    leading_paw=2;
end

%% Determine if enough steps by leading paw for session to be valid
if max(leading_steps_by_left_paw , leading_steps_by_right_paw)>49
    enough_steps=1;
else
    enough_steps=0;
end

%% Analize signal channels
for signal_iterator=1:length(labeled_data.All.sig_channels)
    signal = labeled_data.All.sig_channels{signal_iterator}; % load the name of the signal channel
    
    %% analize the bakground psth
    psth_999 = psth_struct.All.event_999.(signal).psth; % load the background psth
    [background_r, ~, ~, ~, ~] = MultipleHistogramCircularStatistics(psth_999,120); % calculate r for background psth
    background_mean_firing_rate=mean(psth_999); %calculate the mean response of the backgound psth
    background_standard_deviation=std(psth_999); %calculate the standard deviation of the background psth
    background_high_threshold = background_mean_firing_rate + 0.5 * background_standard_deviation; %calculate high threshold for background psth
    background_low_threshold = background_mean_firing_rate - 0.5 * background_standard_deviation; %calculate low threshold for background psth

    %% analize the grouped psth for all steps near obstacle
    psth_998 = psth_struct.All.event_998.(signal).psth; % load the grouped psth for steps near the obstacle
    [~, ~, ~, ~, p] = MultipleHistogramCircularStatistics(psth_998,120); %find out the probability that the nuron is unmodulated through the step cycle
    %make a list of signal channels that are modulated
    if p<0.01
        modulated(signal_iterator)=1;
    else
        modulated(signal_iterator)=0;
    end
    
    %% asign paw pereferences
    psth_1 = psth_struct.All.event_1.(signal).psth; % load the grouped psth for steps by left paw
    [r_1, ~, ~, ~, ~] = MultipleHistogramCircularStatistics(psth_1,120); %find the magnitude of the response to the left paw
    psth_2 = psth_struct.All.event_2.(signal).psth; % load the grouped psth for steps by right paw
    [r_2, ~, ~, ~, ~] = MultipleHistogramCircularStatistics(psth_2,120); % find the magnitde of the response to the right paw
    
    %assign a paw preference for that signal channel based on magnitude of
    %response to left and right paw, and if it is tied to the leading paw
    %or the trailing paw
    if r_1>r_2
        paw_preference(signal_iterator)=1; %signal is tied to left paw
        if leading_paw==1
            leading_trailing(signal_iterator)=1; %signal is tied to leading paw
        else
            leading_trailing(signal_iterator)=2; %signal is tied to trailing paw
        end
    elseif r_2>r_1
        paw_preference(signal_iterator)=2; %signal is tied to right paw
        if leading_paw==2
            leading_trailing(signal_iterator)=1; %signal is tied to leading paw
        else
            leading_trailing(signal_iterator)=2; %signal is tied to trailing paw
        end
    else
        paw_preference(signal_iterator)=0; %signal does not prefer either paw
        leading_trailing(signal_iterator)=0; %signal is not tied to either paw
    end
    
    %% analize each event
    for event_iterator=1:length(psth_struct.all_events)
        event=psth_struct.all_events{event_iterator}; %load the event number
        current_psth=psth_struct.All.(event).(signal).psth; %load the psth for the current event and current signal
        [current_r, ~, ~, ~, ~] = MultipleHistogramCircularStatistics(current_psth,120); % calculate r for the current psth
        delta_r(signal_iterator,event_iterator) = current_r-background_r; % the difference in the r values for the current psth and the background psth
        current_mean_firing_rate=mean(current_psth); %calculate the mean response of the backgound psth
        delta_mean_firing_rate(signal_iterator,event_iterator) = current_mean_firing_rate-background_mean_firing_rate; % the difference between the mean firing rate of the current psth and the background psth
        current_standard_deviation=std(psth_999); %calculate the standard deviation of the background psth
        current_high_threshold = background_mean_firing_rate + 0.5 * current_standard_deviation; %calculate high threshold for background psth
        current_low_threshold = background_mean_firing_rate - 0.5 * current_standard_deviation; %calculate low threshold for background psth
        
    end
end