function [spikes, reference] = PLX_to_ToolboxFormat(plx_dir, plx_name, varargin)
%PLX_TO_TOOLBOXFORMAT  load PLX file in NeuroToolbox input format. 
% 
%     This function converts the timestamps in a .plx file to the format
%     expected by the functions in the NeuroToolbox. It uses the MATLAB
%     Offline Files SDK (provided by Plexon as part of the OmniPlex and MAP
%     Offline SDK Bundle)
%     
%     Syntax:
%     
%         [SPIKES,REFERENCE] = PLX_TO_TOOLBOXFORMAT(PLX_DIR,PLX_NAME)
%
%         PLX_TO_TOOLBOXFORMAT(�,�parameter_1�,value_1,'parameter_2',value_2�)
%         append parameter-value pairs after the required arguments. You
%         can list several pairs in series. See Parameter-value pairs
%         section below for a list of parameters that can be used.
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
%         PLX_DIR is a string containing the directory where the .plx file
%         to load is located. It must end with the file separator
%         character. To determine the file separator character on your
%         platform type 'filesep' in the command window.
% 
%         PLX_NAME is a string containing the name of the .plx file to
%         load.
%     
%     Parameter-value pairs:
%     
%         Parameter-value pairs can be used after the required inputs to
%         specify the following parameters. Enter the name as a string
%         followed by the value for that parameter. The following
%         parameters are valid
% 
%         �show_progress� - Logical. If true, a progress bar is generated
%         showing the progress of loading the file. Default is false.
% 
%         �load_waveforms� - Logical. If true, the third column of Spikes
%         contains the spike waveforms loaded from the .plx file. Default
%         is false.
%     
%     
%     See also PARSE_SPIKE_REF, SDKFORMAT_TO_TOOLBOXFORMAT.

% Parse inputs (if any invalid, throw an exception)
parameters = {'show_progress','load_waveforms'};
parameter_classes = {'logical','logical'};
parameter_attributes = {{},{}};
parameter_defaults = {false,false};
[err,msg] = NeuroToolbox.parse_arguments(parameters,parameter_classes,parameter_attributes,parameter_defaults,varargin);
if err
    id = ['NeuroToolbox:PLX_to_ToolboxFormat:invalid_parameter',num2str(err)];
    msg = [msg,'\nFor more information, type ''help NeuroToolbox.PLX_to_ToolboxFormat'''];
    exception = MException(id,msg);
    throw(exception);
end

% Generate complete path to file
opened_file_name = [plx_dir,plx_name];

% Load header information about spikes
[~,spk_names] = plx_chan_names(opened_file_name);
[ts_counts,~,~] = plx_info(opened_file_name,1);

% Create subchannel labels
subchan = ['a','b','c','d'];        

% Initialize Spikes
spikes = {};

% Remove unsorted units
ts_counts(1,:) = [];

% Initialize the progress bar (the anonymous function as CloseRequestFcn
% makes it impossible to close the window. Closing the window is handled
% programmatically when loading is complete)
if show_progress
    prog_dlg = waitbar(0,'Loading spikes from PLX file: 0%','CloseRequestFcn',@(varargin)(0));
end

total_units = sum(sum(logical(ts_counts)));

% For each channel
for channel = 1:size(ts_counts,2)

    % Check how many units are sorted on current channel
    sorted_units = find(ts_counts(:,channel));
    
    % If any, iterate through the units
    if length(sorted_units)>=1
        
        % For each sorted unit
        for unit = 1:length(sorted_units)
            
            % Generate the unit name
            unit_name = [spk_names(channel-1,:),subchan(sorted_units(unit))];
            
            % Load the units timestamps
            [~,ts] = plx_ts(opened_file_name, channel-1, sorted_units(unit));
            
            % Populate Spikes
            spikes{end+1,1} = unit_name;
            spikes{end,2} = ts;
            
            
            % Load the waveforms (if desired)
            if load_waveforms
                [~,~,~,wave] = plx_waves(opened_file_name, channel-1, sorted_units(unit));
                spikes{end,3} = wave;
            end
            
            % Update progress bar
            if show_progress
                new_prct = size(spikes,1)/total_units;
                new_msg = sprintf('Loading spikes from PLX file: %d%%',round(new_prct*100));
                waitbar(new_prct,prog_dlg,new_msg);
            end
        end
    end
end

% Get all event names
% [~,names] = plx_event_names(opened_file_name);

%  Eliminate Start, Stop, Strobe, and Keyboard events
% names_cell = cellstr(names);
% events_mask_cell = strfind(names_cell,'Event');
% events_mask = ~cellfun(@isempty,events_mask_cell);
% event_inds = find(events_mask);

% Get all event names
[n, ts, sv] =plx_event_ts(opened_file_name,257)   %for strobed events
names=unique(sv);

names_cell=num2cell(names);

%Convert into event names
names_cell=cellfun(@(x) ['Event00',num2str(x)],names_cell,...
    'UniformOutput',false);



% Intialize Reference
reference = {};

% Reset progress bar for loading events
if show_progress
    waitbar(0,prog_dlg,'Loading reference events from PLX file: 0%');
end

% % For each event
% for channel=1 %event_inds'
%     
%     % Get event name
%     event = names(channel,:);
%     
% %     % Remove null characters
% %     null_mask = event == 0;
% %     event = event(~null_mask);
%     
%     % Load event timestamps. Use evalc to suppress the hardcoded text
%     % output from plx_event_ts
%     str = '[n,event_TS_new,~] = plx_event_ts(opened_file_name,channel);';
%     [~] = evalc(str);
%     
%     % Reset progress bar for loading events
%     if show_progress
%         new_prct = find(event_inds==channel,1,'first')/numel(event_inds);
%         new_msg = sprintf('Loading reference events from PLX file: %d%%',round(new_prct*100));
%         waitbar(new_prct,prog_dlg,new_msg);
%     end
%     
%     % If the channel has associated timestamps
%     if n>0
%         % Populate reference
%         reference{end+1,1} = event;
%         reference{end,2}= event_TS_new;
%     end
% end

%   If the channel has associated timestamps
if n>0
    
    %group reference timestamps
    referenceTS=accumarray(sv,ts,[],@(x) {x});
    referenceTS=referenceTS(~cellfun(@isempty,referenceTS));
    
    
    %create reference matrix
    reference=[names_cell, referenceTS];
    
    %mask for empty references (i.e. no timestamps)
    referenceMask=~cellfun('isempty',reference);
    
    %remove empty references
    reference=reference(referenceMask(:,2),:);
    
    
    reference(:,2)=cellfun(@NeuroToolbox.remove_duplicateTimestamps,reference(:,2),...
        'UniformOutput',false);
    
end
% Delete the progress bar
if show_progress
    delete(prog_dlg);
    clear prog_dlg
end