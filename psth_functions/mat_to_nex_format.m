% This function loads the data stored in parsed_spike mat files and
% formats the data in the Matlab workspace which can be read into
% NeuroExplorer. 
% See NeuroExplorer manual for importing instructions:
% https://plexon.com/wp-content/uploads/2017/06/NeuroExplorer-v5-Manual.pdf

function mat_to_nex_format

    [file, path] = uigetfile;
    load([path, file]); 

    for index = 1:length(channel_map)

        assignin('base', channel_map{index, 1}, channel_map{index, 2});          

    end

    event_iter = 1; 
    num_events = length(unique(event_ts(:,1)));
    for event_index = 1:num_events
        temp_events = []; 

        for ts_index = 1:length(event_ts)

            if event_ts(ts_index, 1) == event_index

                temp_events = [temp_events, event_ts(ts_index, 2)]; 

            end
        end

        event_name = ['event_', int2str(event_iter)];
        assignin('base', event_name, temp_events); 
        event_iter = event_iter + 1; 

    end

end

    