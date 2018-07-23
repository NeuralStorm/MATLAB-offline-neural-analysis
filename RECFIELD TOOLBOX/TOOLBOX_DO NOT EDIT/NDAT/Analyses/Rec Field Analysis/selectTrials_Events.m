function [Events] = selectTrials_Events(Events,options)
%SELECTTRIALS_EVENTS redefines "Events" with select trials removed
%   Detailed explanation goes here

% create a string array of event names
for row=[options.CurrentEvents,options.backgroundevent]
   
    Events(row).names=repmat(string(Events(row).name),size(Events(row).ts,1),...
        size(Events(row).ts,2));
end

% create single dimension array of event timestamps
events=vertcat(Events(options.CurrentEvents).ts);
events_bgnd=vertcat(Events(options.backgroundevent).ts);

% create single dimension array of event names
strings=vertcat(Events(options.CurrentEvents).names);
strings_bgnd=vertcat(Events(options.backgroundevent).names);


% sort event timestamps (i.e. each row is a trial)
[sortedEvents,groupInd]=sort(events);
[sortedEvents_bgnd,~]=sort(events_bgnd);

% sort event names (i.e. each row is a trial)
sortedStrings=strings(groupInd);
sortedStrings_bgnd=strings_bgnd(groupInd);

% create cell array of event names
names=cellstr(unique(strings));

% create logical matrix corresponding to select trials
selectEventLog=cellfun(@(x)sortedStrings(options.trials{:})==x,...
    names,'UniformOutput',false);

% redefine event timestamps with appropiate trials removed 
for name=options.CurrentEvents 
    
    Events(name).ts=sortedEvents(selectEventLog{name});
    Events(name+length(options.CurrentEvents)).ts=sortedEvents_bgnd(selectEventLog{name});

end

% remove "names" field from "Events"
Events=rmfield(Events,'names');
