function [neuronsIn, eventTS] = plx2mat3(plxDir, plxName,varargin)
%Inputs
% plxDir=where .plx files are stored
% plxName=name of .plx file
% varargin=program will assume all event data stored in boolean/strobe
% values format; needs to be decoder folder path

%note: this code can be optimized; you use plx_event_ts twice 


[OpenedFileName, Version, Freq, Comment, Trodalness, NPW, PreThresh,...
    SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration,...
    DateTime] = plx_information([plxDir,plxName]);

[nspk,spk_names] = plx_chan_names(OpenedFileName);
[tscounts, wfcounts, evcounts] = plx_info(OpenedFileName,1);

%% neuronsIn first
subchan = ['a','b','c','d'];
neuronsIn{1,1} = [];
neuronsIn{1,2} = [];
% if(sum(tscounts(1,:))==0)
tscounts(1,:) = [];
% end
for i = 1:length(tscounts)
    
    p = find(tscounts(:,i));
    if length(p)>=1
        for j = 1:length(p)
            disp(['Loading ',spk_names(i-1,:),subchan(p(j))])
            [n, ts] = plx_ts(OpenedFileName, i-1, p(j));
            [nw, npw, tsw, wave] = plx_waves(OpenedFileName, i-1, p(j));
            neuronsIn(end+1,1) = cellstr([spk_names(i-1,:),subchan(p(j))]);
            neuronsIn{end,2} = ts;
            neuronsIn{end,3} = wave;
        end
    end
end
neuronsIn(1,:) = [];
frequency = Freq;
    %% Strobed/boolean value event timestamps
if nargin>2
    
    % change directory to decoder folder to access functions
    cd(varargin{1})
    
    % generate complete path to file
    opened_file_name = [plxDir, '/', plxName];
    
    % get all event names
    [n, ts, sv] =plx_event_ts(opened_file_name,257);   %for strobed events
    names=unique(sv);
    
    names_cell=num2cell(names);
    
    % convert into event names
    names_cell=cellfun(@(x) ['Event00',num2str(x)],names_cell,...
        'UniformOutput',false);
    
    % if the channel has associated timestamps
    if n>0
        
        % group reference timestamps
        referenceTS=accumarray(sv,ts,[],@(x) {x});
        referenceTS=referenceTS(~cellfun(@isempty,referenceTS));
        
        % create reference matrix
        reference=[names_cell, referenceTS];
        
        % mask for empty references (i.e. no timestamps)
        referenceMask=~cellfun('isempty',reference);
        
        % remove empty references
        reference=reference(referenceMask(:,2),:);
        
        % sort all timestamp values acsending
        sortedTS=cellfun(@sort,reference(:,2),'UniformOutput',false);
        
        % remove duplicates
        sortedTS_noDuplicates=cellfun(@NeuroToolbox.remove_duplicateTimestamps,sortedTS,...
            'UniformOutput',false);
        
        % replace non-sorted timestamps with duplicates removed timestamps
        eventTS=[reference(:,1),sortedTS_noDuplicates];
        
    end

    %% Traditional event timestamps (digital line per event)
else
    %%
    [~,names] = plx_event_names([plxDir,plxName]); % get event shit
    %%
    eventlist=(1:1:16);   %all possible tilt events (added so code can handle up to 16 tilt types modularly)
    for i=1:length(eventlist)
        if i<10
            tiltEvent=['Event00',num2str(eventlist(i))];
        else
            tiltEvent=['Event0',num2str(eventlist(i))];
        end
        %tiltEvent = 'Event005';
        tEchan = strmatch(tiltEvent,names);
        [~,eventTSnew,~] = plx_event_ts([plxDir,plxName],tEchan); % get event timestamps...shit
        eventTS{1,i}=tiltEvent;
        if length(eventTSnew)>1    %changed to 1 from 2
            eventTS{2,i}=eventTSnew;
        else
            eventTS{2,i}=[];
        end
    end
    
end