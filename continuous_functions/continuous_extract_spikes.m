function [spikes, threshold] = continuous_extract_spikes(amp_signal, sd_size, ts, sample_rate)

    
    [total_chan_num, num_samples] = size(amp_signal);
    spikes = [];
    amp_time = linspace(0, (length(amp_signal) / sample_rate), length(amp_signal)); 
  
    %% Artifact removal: Removes +/- 1 ms of signal around each event ts
    one_ms = sample_rate * 0.001; 
    for event_i = 1:length(ts)      
        start_artifact = ts(event_i) - one_ms;
        end_artifact = ts(event_i) + one_ms; 
        amp_signal(start_artifact:end_artifact) = nan;         
    end

    %% Calculate threshold used to spike detection
    signal_average = nanmean(amp_signal);     
    signal_sd = nanstd(amp_signal) * sd_size;       
    threshold = signal_average - signal_sd;
    
    %Finds spike time stamps
    %Uses inverse signal and threshold in order to use the findpeaks
    %function with 'MinPeakHeight' restriction
    inv_sig = amp_signal * -1;
    inv_thresh = threshold * -1; 
    [all_peaks, all_peaks_index] = findpeaks(inv_sig, amp_time, 'MinPeakDistance', 0.001, 'MinPeakHeight', inv_thresh);
    spikes = all_peaks_index; 

end

