function [PEM,bin_edges,unit_names,unit_key,event_names,event_key] = make_PEM(Spikes,Reference,varargin)
%MAKE_PEM Summary of this function goes here
%   Detailed explanation goes here

% Parse data
[Spikes,Reference]=NeuroToolbox.parse_spike_ref(Spikes,Reference);

% Parse arguments
validOptions = {'PEM_window','bin_size','ignore','truncate_last_bin','show_progress','downsample_events'};
validOptionClasses = {'numeric','numeric','cellstr','logical','logical','numeric'};
validOptionAttributes = {{'real','numel',2,'increasing'},{'real','positive','scalar'},{},{},{},{'positive','scalar','integer'}};
defaultOptionValues = {[-0.200 0.200],.010,{},false,false,1};
[err,msg] = NeuroToolbox.parse_arguments(validOptions,validOptionClasses,validOptionAttributes,defaultOptionValues,varargin);
if err
    id = ['NeuroToolbox:PSTHToolbox:PSTH:make_PEM:InvalidOptions',num2str(err)];
    msg = [msg,'\nFor more information on options, type ''help NeuroToolbox.PSTHToolbox.PSTH.make_PEM'''];
    exception = MException(id,msg);
    throw(exception);
end

% Set up bins
bin_edges = PEM_window(1):bin_size:PEM_window(end);

% Create the last bin if PEM_window(end) is a non-integer multiple of
% bin_size greater than PEM_window(1)
if bin_edges(end)<PEM_window(end)
    
    % If truncate_last_bin is set true, set the upper bin edge
    % equal to PEM_window(end) and issue a warning that this is for
    % use with debugging only.
    if truncate_last_bin
        bin_edges(end+1) = PEM_window(end);
        WarningStr = 'The ''truncate_last_bin'' parameter is set to true. This setting causes nonuniform bin sizes (the last bin is truncated to the specified upper end of PEM_window, regardless of bin_size). This is for debugging use ONLY, and will cause incorrect values when used with the ''Units'' parameter set to ''Rate''';
        warning(WarningStr);
        % If truncate_last_bin is set false, set the upper bin edge
        % as the upper edge of the first bin which will exceed
        % PEM_window(end)
    else
        bin_edges(end+1) = bin_edges(end) + bin_size;
    end
end

% Ignore units

% Get unit names and spike names
unit_names = Spikes(:,1);
event_names = Reference(:,1);
Spikes = Spikes(:,2);
Reference = Reference(:,2);

% Create unit key
unit_nums = 1:numel(Spikes);
num_bins = numel(bin_edges)-1;
unit_key = repmat(unit_nums,num_bins,1);
unit_key = unit_key(:)';

% initialize PEM array and event key
PEM = [];
event_key = [];

% Get time of last reference event (for adding dummy spikes if
% necessary
Max_Ref_Times_By_Event = cellfun(@(X)(max(X(:))),Reference(:));
Max_Ref_Time = max(Max_Ref_Times_By_Event);

% Initialize progress bar and get total # of PSTHs being generated
if show_progress
    numPEM = numel(Spikes)*numel(Reference);
    progBar = waitbar(0,'Generating PEMs: 0%','CloseRequestFcn',@(varargin)(0));
end

try % Error catching so that progress bar can be deleted if an error occurs
    for SpikeSource = 1:numel(Spikes) % For each unit
        
        % Initialize unit response matrix
        Unit_PEM = [];
        
        % If no spikes present, add one outside the PEM_window of any
        % reference events. This avoids histc producing an empty
        % matrix (instead fills with zeros) and thereby prevents
        % the PSTH from populating with NaNs for this unit.
        if isempty(Spikes{SpikeSource});
            Spikes{SpikeSource}(1) = Max_Ref_Time + 10*PEM_window(end);
        end
        
        for ReferenceSource = 1:numel(Reference) % For each event type
            for trial = 1:downsample_events:numel(Reference{ReferenceSource}) % For each trial
                
                % Offset spike times to reference event
                offset_times = Spikes{SpikeSource} - Reference{ReferenceSource}(trial)*ones(size(Spikes{SpikeSource}));
                
                % Count spikes within each bin
                binned_trial = histc(offset_times,bin_edges);
                
                % cut off last bin (histc returns last bin as values MATCHING
                % the last 'edge' i.e. not a true bin)
                binned_trial(end) = [];
                
                Unit_PEM(end+1,:) = binned_trial';
                if SpikeSource == 1
                    event_key(end+1,1) = ReferenceSource;
                end
                
            end
            
            % Update progress bar
            if show_progress
                newPrct = ((SpikeSource-1)*numel(Reference)+ReferenceSource)/numPEM;
                newMsg = sprintf('Generating PEMs: %d%%',round(newPrct*100));
                waitbar(newPrct,progBar,newMsg);
            end
            
        end
        
        % Append the unit to the single trial response array
        PEM = [PEM,Unit_PEM];
        
    end
    
    % Sort the PEM by event type
    [event_key,sort_ind] = sort(event_key);
    PEM = PEM(sort_ind,:);
    
    % Delete the progress bar
    if show_progress
        delete(progBar)
        clear progBar
    end
    
catch ME % If an error does occur, report it in the progress bar and relay the exception
    if show_progress
        set(progBar,'CloseRequestFcn',@(varargin)(delete(progBar)));
        waitbar(0,progBar,'ERROR');
    end
    throw(ME);
    
end

end

