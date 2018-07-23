function data=import_nex(filename,options)

% options.toimport=[0,1,3];
data.filename=filename;
if isfield(options,'header')
    [path,file,ext]=fileparts(filename);
    disp(['Reading just header data for file:',file])
else
    options.header=0;
end



%getting header

[header]=nex_header(filename);


% importing timestamps
if options.header~=1
    if sum(options.toimport==0)==1
        % choosing channels
        if isfield(options,'channels')
            %channels=options.channels;
        else
            channels=[header.Channels.channel];
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
    
    
    path=fileparts(which('import_nex'));
    
    
    addpath([path,filesep,'nex_basic']);
    data=import_nex_nodll(filename, options);
   
else
    data=header;
end