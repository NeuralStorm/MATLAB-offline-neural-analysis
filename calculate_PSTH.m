function [] = calculate_PSTH(parsed_path, bin, edge)
% Current default for bin and edge:
% bin = 0.001;
% edge=0:bin:0.4;
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
        % classifier window before time zero 
        pretime=-.2;   %seconds

        % classifier window after time zero 
        posttime=.2;   %seconds
        
        %totalrelspikes is the (400 trials)x(Bins*Neurons) matrix which has each event trial for each
        %neuron with data put into 100 bins (-0.2 : 0.2) seconds.
        %Binned every 1 ms(see edge above)

        % Right PSTH
        [right_rel_spikes_1]= Eventspiketimes(event1, right_spike_times, edge);
        [right_rel_spikes_3]= Eventspiketimes(event3, right_spike_times, edge);
        [right_rel_spikes_4]= Eventspiketimes(event4, right_spike_times, edge);
        [right_rel_spikes_6]= Eventspiketimes(event6, right_spike_times, edge);
        disp('Right PSTH Done');
        
        % Left PSTH
        [left_rel_spikes_1]= Eventspiketimes(event1, left_spike_times, edge);
        [left_rel_spikes_3]= Eventspiketimes(event3, left_spike_times, edge);
        [left_rel_spikes_4]= Eventspiketimes(event4, left_spike_times, edge);
        [left_rel_spikes_6]= Eventspiketimes(event6, left_spike_times, edge);
        disp('Left PSTH Done');

        %This next one is important-has spikes in bins

        right_total_rel_spikes = [right_rel_spikes_1, right_rel_spikes_3, right_rel_spikes_4, right_rel_spikes_6];
        left_total_rel_spikes = [left_rel_spikes_1, left_rel_spikes_3, left_rel_spikes_4, left_rel_spikes_6];        
        
        %% Saving the file
        [pathstr,namestr,extstr] = fileparts(file);
        filename = strcat('PSTH.format.', namestr);
        filename = strcat(filename, '.mat');
        psth_path = strcat(psth_path, '/');
        matfile = fullfile(psth_path, filename);
        
        save(matfile, 'right_total_rel_spikes', 'left_total_rel_spikes');
    end
    toc;
end