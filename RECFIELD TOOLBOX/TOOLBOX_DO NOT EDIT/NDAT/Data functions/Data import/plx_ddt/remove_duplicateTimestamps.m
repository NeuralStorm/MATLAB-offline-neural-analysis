function  [ eventTSadj ] = remove_duplicateTimestamps(eventTS,varargin )
%REMOVE_DUPLICATETIMESTAMPS removes duplicate timestamps in event channels
%input=event timestamps
%dt=minimum time that elapses between each event

%varargin{1}=dt
%varargin{2}=eventInd

if nargin>1
    dt=varargin{1};
else
    dt=2.4;   %changed to 2 6/8/2016, 2.4/6/13/2016
end

%Find duplicate events
diffArray=diff(sort(eventTS))<dt;

if nargin>2
    
    event=varargin{2};
else
    event=sort(eventTS);
    
end
%Remove duplicate events
event([false;diffArray])=[];

%True event (i.e. one per tilt) indice values
eventTSadj=event;

end






