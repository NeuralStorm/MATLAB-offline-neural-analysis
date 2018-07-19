function [psth_path] = calculate_PSTH(parsed_path, total_bins, bin_size, pre_time, post_time)
% Current default values for testing:
% total_bins = 400;
% pre_time = 0.2;
% post_time = 0.2;
    tic;
    % Grabs all .mat files in the parsed plx directory
    parsed_mat_path = strcat(parsed_path, '/*.mat');
    parsed_files = dir(parsed_mat_path);
    
    % Checks and creates a psth directory if it does not exists
    psth_path = strcat(parsed_path, '/psth');
    if ~exist(psth_path, 'dir')
       mkdir(parsed_path, 'psth');
    end
    
    for h = 1: length(parsed_files)
        file = [parsed_path, '/', parsed_files(h).name];
        load(file);

        % Turns neuron matrix into PSTH form for the different events
        
        % Event 1
        [all_rel_spikes_1] = event_spike_times(event1, all_spike_times, ...
            total_bins, bin_size, pre_time, post_time);
        % Event 3
        [all_rel_spikes_3] = event_spike_times(event3, all_spike_times, ...
            total_bins, bin_size, pre_time, post_time);
        % Event 4
        [all_rel_spikes_4] = event_spike_times(event4, all_spike_times, ...
            total_bins, bin_size, pre_time, post_time);
        % Event 6
        [all_rel_spikes_6] = event_spike_times(event6, all_spike_times, ...
            total_bins, bin_size, pre_time, post_time);
        disp('All PSTH Done');

        % Total relative spikes is the (# trials)x(bins*neurons) matrix
        % which has each event trial for each neuron with data put in the #
        % of total bins defined by the window given by the pre and post
        % times and stepped by the bin size
        
        all_total_rel_spikes = [all_rel_spikes_1; all_rel_spikes_3; all_rel_spikes_4; all_rel_spikes_6];
        
        %% Saving the file
        [~ ,namestr, ~] = fileparts(file);
        filename = strcat('PSTH.format.', namestr);
        filename = strcat(filename, '.mat');
        matfile = fullfile(psth_path, filename);
        save(matfile, 'all_total_rel_spikes', 'total_neurons');
    end
    toc;
end