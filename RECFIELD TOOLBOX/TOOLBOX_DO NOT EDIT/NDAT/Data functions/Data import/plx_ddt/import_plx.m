function data=import_plx(filename,options)

% options.toimport=[0,1,3];
data.filename=filename;
if isfield(options,'header')
    [path,file,ext]=fileparts(filename);
    disp(['Reading just header data for file:',file])
else
    options.header=0;
end



%setting import options

header=plx_header(filename);
% importing timestamps

%if  isfield(options,'boolean')  to become a button 

    % acquire event names
    [n, ts, sv] =plx_event_ts(filename,257);   %for strobed events
    names=unique(sv);
    
    % convert event names to cell 
    names_cell=num2cell(names);
    
    % apply "Strobe" label
    names_cell=cellfun(@(x) ['Strobe00',num2str(x)],names_cell,...
        'UniformOutput',false);
    
    % if strobe events exist 
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
        
        % remove duplicate timestamps
        reference(:,2)=cellfun(@remove_duplicateTimestamps,reference(:,2),...
            'UniformOutput',false);
        
        % calculate the number of timestamps for each event
        count=cellfun(@length,reference(:,2));
        

        % create a new structure array
        headerNew.Events=cell2struct([reference(:,1),num2cell(names),...
            num2cell(count),reference(:,2)],...
            {'name','channel','count','ts'},2);
        
        % convert event channels into double array
        channels=[header.Events.channel];
        
        % find event channel indice values
        newChannelsind=find(channels<257);
        
        % redefine channel numbers in existing array
        newChannels=headerNew.Events(end).channel+...
            1:headerNew.Events(end).channel+...
            (length(newChannelsind));
        
        % apply updated channel definitions
        channels(newChannelsind)=newChannels;
        
        % convert channels into a cell array
        updatedChans=num2cell(channels');
        
        % replace original channels with updated in structure array
        [header.Events.channel]=updatedChans{:};
        
        % merge existing structure array with newly created one
        header.Events=[headerNew.Events',header.Events];
        
        % add a new field to options containing strobe ts information
        [options(:).strobe_tsinfo]=header.Events;
    else
        disp('No strobe events exist')
    end
%end

if options.header~=1
    header=plx_header_nodll(filename);
    if sum(options.toimport==0)==1
        % choosing channels
        if isfield(options,'channels')
            %channels=options.channels;
        else
            [units,channels]=find(header.tscounts~=0);
            options.channels=unique(channels-1);
        end
        if isfield(options,'indiscriminate')
            %indiscriminate=options.indiscriminate;
        else
            options.indiscriminate=true;
        end
        
       
    end
    
    % importing Events
    
    if sum(options.toimport==1)==1
        % choosing channels
        if isfield(options,'evchannels')
            %channels=options.channels;
        else
            [stimsel]=find(header.evcounts(1:256)~=0)-1;
            options.evchannels=stimsel;
        end
    end
    
    % importing Waveforms
    if sum(options.toimport==3)==1
        
        % choosing channels
        if isfield(options,'wfchannels')
            %channels=options.channels;
        else
            [units,channels]=find(header.wfcounts~=0);
            options.wfchannels=unique(channels-1);
        end
        if isfield(options,'wfindiscriminte')
            %indiscriminate=options.indiscriminate;
        else
            options.wfindiscriminate=true;
        end
        
       
    end
    
    
    path=fileparts(which('import_plx'));
%     if isunix
        
        addpath([path,filesep,'plxddt_nodll']);
        data=import_plx_Unix(filename, options);
%     else
%         
%         addpath([path,filesep,'plxddt_dll']);
%         data=import_plx_PC(filename, options);
%     end
else
    data=header;
end