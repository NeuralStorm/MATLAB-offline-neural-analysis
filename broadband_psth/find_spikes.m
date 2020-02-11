function [spikes] = find_spikes(amp_signal, sd_size, time, ts, sample_rate,...
    background_start, background_end, remove_stim_artifact, artifact_rm_multiplier)

total_chan_num = length(amp_signal);
spikes = struct;

disp(['Creating spike table...']);
for current_chan_num = 1:total_chan_num
    
    signal = amp_signal(current_chan_num).data;
    background_signal = []; 
        
    %Remmoves stimulus artifact
    %EVENT_SPAN IS HARDCODED - NEEDS TO BE THE DIFF BETWEEN TS(2) - TS(1)
    %OR AN INPUT
    if remove_stim_artifact
        event_span = 0.001;
        num_samples = event_span * sample_rate; 
        for event = 1:length(ts)

            pre_event = ts(1, event) - (num_samples * artifact_rm_multiplier);
            post_event = ts(2, event) + (num_samples * artifact_rm_multiplier); 

            signal(pre_event:post_event) = nan; 

        end
    end
    
    %Finds threshold based on background window for spike detection
    for event = 1:length(ts)
       
        thresh_start = ts(1,event) - (abs(background_start) * sample_rate); 
        thresh_end = ts(1,event) - (abs(background_end) * sample_rate); 
        background_signal = [background_signal, signal(thresh_start:thresh_end)]; 
    end
    
    %Finds signal average and threshold 
    signal_average = nanmean(background_signal);     
    signal_sd = nanstd(background_signal) * sd_size;       
    threshold = signal_average - signal_sd;

    %Finds spike time stamps
    %Uses inverse signal and threshold in order to use the findpeaks
    %function with 'MinPeakHeight' restriction
    inv_sig = signal * -1;
    inv_thresh = threshold * -1; 
    [all_peaks, all_peaks_index] = findpeaks(inv_sig, time, 'MinPeakDistance', 0.001, 'MinPeakHeight', inv_thresh);
    spikes(current_chan_num).spike_table = all_peaks_index; 
    
    
    
end

end

