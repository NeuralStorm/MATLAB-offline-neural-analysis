function [] = parser()
    tic;
    %% Select Directory
    dir_path = uigetdir(pwd);
    
    % Necessary for plx_info to run correctly (if the path does not end
    % with / when called in that function, it causes the program to crash)
    path = strcat(dir_path, '/');
    
    % Creates a list of all the files in the given directory ending with
    % *.plx
    num_plx = strcat(dir_path, '/*.plx');
    files = dir([num_plx]);
    
    % Create parsed directory if it does not already exist    
    % TODO fix it so that file is placed into a parsed directory
    parsed_path = strcat(dir_path, '/parsed_plx');
    if ~exist(parsed_path, 'dir')
       mkdir(dir_path, 'parsed_plx');
    end
    
    % Runs through all of the .plx files in the selected directory
    for h = 1: length(files)
        filename = files(h).name;
        % Take the spike times and event times
        datafile = [path, filename];
        [tscounts, wfcounts, evcounts, slowcounts] = plx_info(datafile,1);
        
        [nunits1, nchannels1] = size(tscounts); 
        allts = cell(nunits1, nchannels1);
        for iunit = 0:nunits1-1   % starting with unit 0 (unsorted) 
            for ich = 1:nchannels1-1
                if ( tscounts( iunit+1 , ich+1 ) > 0 )
                    % get the timestamps for this channel and unit 
                    [nts, allts{iunit+1,ich}] = plx_ts(datafile, ich , iunit );
                 end
            end
        end
        svStrobed=[];
        svdummy=[];
        % and finally the events
        [u,nevchannels] = size( evcounts );  
        if ( nevchannels > 0 ) 
            % need the event chanmap to make any sense of these
            [u,evchans] = plx_event_chanmap(datafile);
            for iev = 1:nevchannels
                if ( evcounts(iev) > 0 )
                    evch = evchans(iev);
                    if ( evch == 257 )
                        [nevs{iev}, tsevs{iev}, svStrobed] = plx_event_ts(datafile, evch); 
                    else
                        [nevs{iev}, tsevs{iev}, svdummy{iev}] = plx_event_ts(datafile, evch);
                    end
                end
            end
        end

        events=[];
        j=0;
        if length(svStrobed)>1
            events = tsevs{1,17};
            events = [svStrobed,events];
        else
            for i=1:length(evcounts)
                if evcounts(i) >= 100
                    [nevs{i}, tsevs{i}, svdummy] = plx_event_ts(datafile, i);
                    j=j+1;
                    eventsingle(1:evcounts(i),1)=j;
                    events= [events;eventsingle,tsevs{i}];
                    eventsingle=[];
                end
            end
            for i=1:length(events)
                if events(i,1)==2
                    events(i,1)=3;
                elseif events(i,1)==3
                    events(i,1)=4;
                elseif events(i,1)==4
                    events(i,1)=6;
                end
            end
        end
            %% Removes Doubles and Triples from events
        i=1;
        while i <= length(events)-1
            if abs(events(i,2)-events(i+1,2)) < 2
                events(i+1,:) = [];
            end
            i = i+1;
        end
        i=1;
        while i <= length(events)-1
            if abs(events(i,2)-events(i+1,2)) < 2
                events(i+1,:) = [];
            end
            i = i+1;
        end
        i=1;
        while i <= length(events)-1
            if abs(events(i,2)-events(i+1,2)) < 2
                events(i+1,:) = [];
            end
            i = i+1;
        end

        %% Separate hemispheres

        % Right Hemisphere
        right_spike_times = [];
        for i = 1:16
            for j = 2:5
                if length(allts{j,i}) >= 1
                    right_spike_times = [right_spike_times, allts(j,i)];
                end
            end
        end

        % Left Hemisphere
        left_spike_times = [];
        for i = 17:32
            for j = 2:5
                if length(allts{j,i}) >= 1
                    left_spike_times = [left_spike_times,allts(j,i)];
                end
            end
        end
        
        %% Saves parsed files
        filename = replace(filename, '.plx', '.mat');
        matfile = fullfile(parsed_path, filename);
        
        save(matfile, 'tscounts', 'wfcounts', 'evcounts', 'slowcounts', 'right_spike_times', 'left_spike_times');
    end
    toc;
end