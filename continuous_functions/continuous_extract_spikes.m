function [spikes, threshold] = continuous_extract_spikes(amp_signal, sd_size, ts, sample_rate, background_start, background_end)
    amp_time = linspace(0, (length(amp_signal) / sample_rate), length(amp_signal));

    %% Calculate threshold used to spike detection
    background_start_sample = sample_rate * abs(background_start);
    background_end_sample = sample_rate * abs(background_end);
    background_signals = [];

    for i = 1:length(ts)
        background_signals(i,:) = amp_signal((ts(i) - background_start_sample):(ts(i) - background_end_sample));
    end

    background_average = mean(background_signals, 'all');
    background_std = std(background_signals, 0, 'all');
    threshold = background_average - (background_std * sd_size);

    %Finds spike time stamps
    %Uses inverse signal and threshold in order to use the findpeaks
    %function with 'MinPeakHeight' restriction
    inv_sig = amp_signal * -1;
    inv_thresh = threshold * -1;
    [~, all_peaks_index] = findpeaks(inv_sig, amp_time, 'MinPeakDistance', 0.001, 'MinPeakHeight', inv_thresh);
    spikes = all_peaks_index;
end