function [spikes,reference] = SDKFormat_to_ToolboxFormat(TS)
%SDKFORMAT_TO_TOOLBOXFORMAT  Converts ClientSDK format to Spikes and Reference format
% 
%     This function converts the timestamps acquired from the Plexon MAP
%     server using the PL_GetTS function (provided by Plexon as part of the
%     Matlab Online Client Development Kit) to the format expected by the
%     functions in the NeuroToolbox.
%     
%     Syntax:
%     
%         [SPIKES,REFERENCE] = SDKFORMAT_TO_TOOLBOXFORMAT(TS)
%     
%     Outputs:
%     
%         SPIKES is the standard spikes input for the NeuroToolbox package
%         in the cell array format. See the help page for PARSE_SPIKE_REF
%         for more information.
% 
%         REFERENCE is the standard reference input for the NeuroToolbox
%         package in the cell array format. See the help page for
%         PARSE_SPIKE_REF for more information.
%     
%     Inputs:
%     
%         TS is the array of timestamps returned by calling the plexon
%         PL_GetTS function. It is the second output argument of that
%         function.
%
%     
%     See also PARSE_SPIKE_REF, PL_GETTS, PLX_TO_TOOLBOXFORMAT.

% Create array of unit names
chans = 1:32;
chans = repmat(chans,4,1);
chans = chans(:)';
subchans = 'abcd';
subchans = repmat(subchans,1,32);
chans = num2cell(chans);
subchans = num2cell(subchans);
unit_names = cellfun(@(chan,unit)(sprintf('sig%03d%c',chan,unit)),chans,subchans,'uniformoutput',false)';

% Get Neural timestamps
spike_TS = TS(TS(:,1)==1,:);

% Remove unsorted units
spike_TS = spike_TS(spike_TS(:,3)~=0,:);

% Get the names from the unit_names cell array
chan_nums = spike_TS(:,2);
unit_nums = spike_TS(:,3);
name_inds = (chan_nums-ones(size(chan_nums)))*4 + unit_nums;
trial_unit_names = unit_names(name_inds);

% Get coded unit names
[unique_unit_names,~,coded_trial_unit_names] = unique(trial_unit_names);

% and group the timestamps by unit
spike_times = accumarray(coded_trial_unit_names,spike_TS(:,4),[],@(x)({x}));

% construct the output
spikes = [unique_unit_names,spike_times];

% Get event timestamps
event_TS = TS(TS(:,1)==4 & TS(:,3)<=10,:);

% Get the event names
event_channels = num2cell(event_TS(:,3));
trial_event_names = cellfun(@(x)(sprintf('event%03d',x)),event_channels,'uniformoutput',false);

% Get coded unit names
[unique_event_names,~,coded_trial_event_names] = unique(trial_event_names);

% and group the timestamps by unit
event_times = accumarray(coded_trial_event_names,event_TS(:,4),[],@(x)({x}));

% construct the output
reference = [unique_event_names,event_times];