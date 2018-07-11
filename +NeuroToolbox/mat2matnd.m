function [Channels,Events,Explab ] = mat2matnd(neuronsIn,eventsIn,filename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


%% Create "Channels" structure

% convert plexon sig names into channel numbers
chanNums=cellfun(@(x) str2double(x(5:6)),neuronsIn(:,1),...
    'UniformOutput',false);

% convert channel number cell array into a double array
chanNumsDouble=[chanNums{:}];

% extract unique channel number and thier array position 
[uniqueVals,~,uniquePos]=unique([chanNums{:}]);

% for each channel
for uniqueVal=1:length(uniqueVals)
    
    % mask (i.e. logical array) to extract relevant channel timestamps
    chanMask=uniqueVals(uniqueVal)==chanNumsDouble;
    
    % extract relevant channel timestamps
    chanTs=neuronsIn(chanMask,2);
    
    % create cell array of unit types (e.g. unit a=1, unit b=2)
    chanCell=num2cell(1:size(chanTs,1))';
    
    % create channel indicator array for unit type
    chanNumCell=cellfun(@(x) repmat(x,size(chanTs{x,1},1),1),chanCell,...
        'UniformOutput',false);
    
    % concatenate channel indicator arrays into one
    chanNumCell_cat=cat(1,chanNumCell{:});
    
    % sort from early ts to highest timestamp
    [chanTs,sortInd]=sort(cat(1,chanTs{:,1}));
    
    % define "Channels" structure fields: timestamps
    Channels(uniqueVal).ts=chanTs;
    
    % define "Channels" structure fields: unit
    Channels(uniqueVal).unit=chanNumCell_cat(sortInd);
    
    % define "Channels" structure fields: channel
    Channels(uniqueVal).channel=uniqueVals(uniqueVal);
    
    % define "Channels" structure fields: name
    Channels(uniqueVal).name=neuronsIn{find(uniqueVal==uniquePos,1)}(1:end-1);
end

%% Create "Events" structure

% change "events" name to "strobe" for consistency

eventNames=cellfun(@(x) ['Strobe',x(6:8)],eventsIn(:,1),...
    'UniformOutput',false);

% create event channel number cell array 
eventChans=[num2cell(1:size(eventNames,1))';...
    {size(eventNames,1)+1};{size(eventNames,1)+2}];

% define complete path to file
%opened_file_name = [plxDir,plxName]; for plexon computer
% opened_file_name='TNC.13.ClosedLoop.Day17.061416.plx';

% acquire plexon start time from .plx file
[~, Start, ~] =plx_event_ts(filename,258);

% acquire plexon stop time from .plx file
[~, Stop, ~] =plx_event_ts(filename,259);

% create event timestamp cell array 
eventTSs=[eventsIn(:,2);Start;Stop];

% create "Events" structure
Events=struct('name',[eventNames;'Start';'Stop'],...
    'channel',eventChans,'ts',eventTSs);

%% Define "Explab" 
Explab='exp.ratid.type.week.date.';

