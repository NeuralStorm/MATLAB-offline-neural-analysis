function [first_latency, last_latency, duration, peak_latency, peak, corrected_peak, ...
        response_magnitude, corrected_response_magnitude] = post_time_analysis(background_rate, ...
        post_response, smoothed_threshold, bin_size, post_start)
    %% Finds results of the receptive field analysis
    above_threshold_indeces = find(post_response > smoothed_threshold);
    above_threshold = post_response(above_threshold_indeces);
    peak = max(above_threshold);
    peak_index = find(peak == post_response);
    peak_latency = (peak_index(1) * bin_size) + post_start;
    corrected_peak = peak - background_rate;
    response_magnitude = sum(...
        post_response(above_threshold_indeces(1):above_threshold_indeces(end)));
    corrected_response_magnitude = response_magnitude - background_rate;
    first_latency = ((above_threshold_indeces(1)) * bin_size) + post_start;
    last_latency = ((above_threshold_indeces(end)) * bin_size) + post_start;
    duration = last_latency - first_latency;
end