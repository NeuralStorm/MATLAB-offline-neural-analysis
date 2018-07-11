function [ eventTSadj ] = remove_duplicateTimestamps(eventTS,varargin )
%REMOVE_DUPLICATETIMESTAMPS removes duplicate timestamps in event channels
%input=event timestamps
%dt=minimum time that elapses between each event

%varargin{1}=dt
%varargin{2}=eventInd

if nargin>1
    dt=varargin{1};
else
    dt=2.4;  %changed from 1 to 2.1 6/8/16
end

% Sort ascending 
eventTS=sort(eventTS);

% Find duplicate events
diffArray=diff(eventTS)<dt;

if nargin>2
    
    event=varargin{2};
else
    event=eventTS;
    
end
% Remove duplicate events
event([false;diffArray])=[];

% True event (i.e. one per tilt) indice values
eventTSadj=event;

end

