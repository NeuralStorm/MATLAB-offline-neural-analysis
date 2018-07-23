function data=import_plx_PC(filename,options)

data=createdatastruct(300);
data.filename=filename;


path=fileparts(which('import_data'));
addpath([path,filesep,'plxddt_dll']);
%get general file informations
header=plx_header_nodll(filename);

if sum(options.toimport==0)==1
% importing timestamps
% choosing channels
    if isfield(options,'Channels')
        channels=options.channels;
    else
        [units,channels]=find(header.tscounts~=0);
        units=units-1;
        channels=channels-1;
    end
    if isfield(options,'Indiscriminte')
        indiscriminate=options.indiscriminate;
    else
        indiscriminate=true;
    end
    if indiscriminate
    else
        pos=find(units==0);
        units(pos)=[];
        channels(pos)=[];
    end
    
    tic;Neurons=plx_ts(filename, channels, units);toc
    
end