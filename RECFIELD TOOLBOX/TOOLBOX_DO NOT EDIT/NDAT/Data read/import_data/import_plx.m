function data=import_plx(filename,options)


data.filename=filename;




%setting import options

header=plx_header_nodll(filename);
% importing timestamps

if sum(options.toimport==0)==1
    % choosing channels
    if isfield(options,'channels')
        %channels=options.channels;
    else
        [units,channels]=find(header.tscounts~=0);
        options.units=units-1;
        options.channels=channels-1;
    end
    if isfield(options,'indiscriminte')
        %indiscriminate=options.indiscriminate;
    else
        options.indiscriminate=true;
    end
    
    if options.indiscriminate
    else
        pos=find(units==0);
        units(pos)=[];
        channels(pos)=[];
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
        options.wfunits=units-1;
        options.wfchannels=channels-1;
    end
    if isfield(options,'wfindiscriminte')
        %indiscriminate=options.indiscriminate;
    else
        options.wfindiscriminate=true;
    end
    
    if options.wfindiscriminate
    else
        pos=find(units==0);
        units(pos)=[];
        channels(pos)=[];
    end
end


path=fileparts(which('import_data'));
if isunix
    
    addpath([path,filesep,'plxddt_nodll']);
    data=import_plx_Unix(filename, options);
else
    
    addpath([path,filesep,'plxddt_dll']);
    data=import_plx_PC(filename, options);
end