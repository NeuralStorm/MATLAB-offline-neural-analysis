function [bin_edges, tot_bins] = get_bins(start_time, end_time, step_size)
    %% Purpose: Calculate total bins based on start and stop time and step size
    %% Input:
    % start_time: start time of window
    % end_time: end time of window
    % step_size: bin size
    bin_edges = start_time:step_size:end_time;
    tot_bins = numel(bin_edges) - 1;
end