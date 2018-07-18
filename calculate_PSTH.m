function [psth_path] = calculate_PSTH(parsed_path, total_bins, pre_time, post_time)
% Current default values for testing:
% total_bins = 400;
% pre_time = 0.2;
% post_time = 0.2;
    tic;
    parsed_mat_path = strcat(parsed_path, '/*.mat');
    parsed_files = dir([parsed_mat_path]);
    
    psth_path = strcat(parsed_path, '/psth');
    if ~exist(psth_path, 'dir')
       mkdir(parsed_path, 'psth');
    end
    
    for h = 1: length(parsed_files)
        file = strcat(parsed_path, '/');
        file = strcat(file, parsed_files(h).name);
        load(file);
        
        %totalrelspikes is the (400 trials)x(Bins*Neurons) matrix which has each event trial for each
        %neuron with data put into 100 bins (-0.2 : 0.2) seconds.
        %Binned every 1 ms(see edge above)

        % Right PSTH
%         [right_rel_spikes_1]= Eventspiketimes(event1, right_spike_times, ...
%             total_bins, pre_time, post_time);
%         [right_rel_spikes_3]= Eventspiketimes(event3, right_spike_times, ...
%             total_bins, pre_time, post_time);
%         [right_rel_spikes_4]= Eventspiketimes(event4, right_spike_times, ...
%             total_bins, pre_time, post_time);
%         [right_rel_spikes_6]= Eventspiketimes(event6, right_spike_times, ...
%             total_bins, pre_time, post_time);
%         disp('Right PSTH Done');
%         
%         % Left PSTH
%         [left_rel_spikes_1]= Eventspiketimes(event1, left_spike_times, ...
%             total_bins, pre_time, post_time);
%         [left_rel_spikes_3]= Eventspiketimes(event3, left_spike_times, ...
%             total_bins, pre_time, post_time);
%         [left_rel_spikes_4]= Eventspiketimes(event4, left_spike_times, ...
%             total_bins, pre_time, post_time);
%         [left_rel_spikes_6]= Eventspiketimes(event6, left_spike_times, ...
%             total_bins, pre_time, post_time);
%         disp('Left PSTH Done');
        
        % All PSTH
        [all_rel_spikes_1]= Eventspiketimes(event1, all_spike_times, ...
            total_bins, pre_time, post_time);
        [all_rel_spikes_3]= Eventspiketimes(event3, all_spike_times, ...
            total_bins, pre_time, post_time);
        [all_rel_spikes_4]= Eventspiketimes(event4, all_spike_times, ...
            total_bins, pre_time, post_time);
        [all_rel_spikes_6]= Eventspiketimes(event6, all_spike_times, ...
            total_bins, pre_time, post_time);
        disp('All PSTH Done');

        %This next one is important-has spikes in bins

%         right_total_rel_spikes = [right_rel_spikes_1; right_rel_spikes_3; right_rel_spikes_4; right_rel_spikes_6];
%         left_total_rel_spikes = [left_rel_spikes_1; left_rel_spikes_3; left_rel_spikes_4; left_rel_spikes_6];
        all_total_rel_spikes = [all_rel_spikes_1; all_rel_spikes_3; all_rel_spikes_4; all_rel_spikes_6];
        
        %% Saving the file
        [pathstr,namestr,extstr] = fileparts(file);
        filename = strcat('PSTH.format.', namestr);
        filename = strcat(filename, '.mat');
        matfile = fullfile(psth_path, filename);
        
%         save(matfile, 'right_total_rel_spikes', 'left_total_rel_spikes', ...
%             'total_left_neurons', 'total_right_neurons', 'all_total_rel_spikes');
        save(matfile, 'all_total_rel_spikes', 'total_neurons');
    end
    toc;
end