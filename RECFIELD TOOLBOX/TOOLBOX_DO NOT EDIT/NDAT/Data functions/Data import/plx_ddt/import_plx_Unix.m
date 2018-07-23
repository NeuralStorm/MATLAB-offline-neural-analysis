function data = import_plx_Unix(filename,options,saveflag)


data=[];
if nargin<2
    options.toimport=[0,1];
end
if nargin<3
    saveflag=1;
end
if sum(options.toimport==1)
    if isfield(options,'evnames')
    else
        info=plx_header_nodll(filename);
        allnames={info.event.name}';
        options.evnames=allnames(options.evchannels);
    end
end
[path,name,ext]=fileparts(filename);
if isempty(path)
    savefilename=[name,'.matnd'];
else
%     path = '/home/anitha/Documents/Sciatic Nerve Lesion/NPP013/030812.NPP013.SOM.PAIN'  ;
% changed by Anitha - to save in a different place from where the plx files are.
    savefilename=[path,filesep,name,'.matnd'];
end

if exist(savefilename)
    exit=true;
    infile=whos('-file',savefilename);
    for i=options.toimport
        switch i
            
            case 0
                exit = sum(strcmpi({infile.name},'Channels')) && exit;
            case 1
                exit = sum(strcmpi({infile.name},'Events')) && exit;
            case 3
                exit = sum(cell2mat(regexpi({infile.name},'Waveforms'))) && exit;
            case 5
                exit = exist([path,name,'.ddt']) && exit;
                
        end
    end
    
    if exit
        disp(['Variables to import already imported']);
        return
        
    end
    
end


%initializing data structure

data=createdatastruct(300,options.toimport);


if(length(filename) == 0)
    [fname, pathname] = uigetfile('*.plx', 'Select a plx file');
    filename = strcat(pathname, fname);
end





%disp(strcat('file = ', filename));

% read file header
header=plx_header_nodll(filename);



%initializing variable to import e=1 double('a') char(96)
argin={};
if sum(options.toimport==0)==1
    
    for e=1:length(options.channels)
        data.Channels(e).ts=zeros(sum(header.tscounts(:,...
            options.channels(e)+1)),1);
        data.Channels(e).unit=zeros(sum(header.tscounts(:,...
            options.channels(e)+1)),1);
        data.Channels(e).name=[header.sig(options.channels(e)).name];
        data.Channels(e).channel=options.channels(e);
        %service variables
        tscountu(options.channels(e))=sparse(1);
        tscountnum(options.channels(e))=sparse(e);
        %to the save function
        
    end
    argin{end+1}='Channels';
end

if sum(options.toimport==1)==1
    
    %adding Start and Stop Events
    options.evchannels=[options.evchannels,[258,259]];
    
    for e=1:length(options.evchannels)
        data.Events(e).ts=zeros(header.evcounts(options.evchannels(e)+1),1);
        
        if isfield(options,'evnames') && options.evchannels(e)<258 ;
            
            name=options.evnames{e};
            
        elseif options.evchannels(e)<258
            name=header.event(options.evchannels(e)).name;
        end
        
        if options.evchannels(e)==258
            name='Start';
        elseif options.evchannels(e)==259
            name='Stop';
        end
        
        data.Events(e).name=name;
        evcountu(options.evchannels(e))=sparse(1);
        evcountnum(options.evchannels(e))=sparse(e);
        data.Events(e).channel=...
            options.evchannels(e);
        
    end
    argin{end+1}='Events';
end

if sum(options.toimport==3)==1
    
    for e=1:length(options.channels)
        data.Waveforms(e).ts=zeros(sum(header.wfcounts(:,...
            options.channels(e)+1)),1);
        data.Waveforms(e).unit=zeros(sum(header.wfcounts(:,...
            options.channels(e)+1)),1);
        data.Waveforms(e).name=[header.sig(options.channels(e)).name];
        data.Waveforms(e).waves=int16(zeros(sum(header.wfcounts(:,...
            options.channels(e)+1)),32));
        data.Waveforms(e).channel=options.channels(e);
        %service variables
        wfcountu(options.channels(e))=sparse(1);
        wfcountnum(options.channels(e))=sparse(e);
        %to save
        argwavname(e)={sprintf('Waveforms%03.0f',e)};
    end
    
end
freq=header.frchevad(1);

tic
%open the file for read
fid = fopen(filename, 'r');
if(fid == -1)
    disp('cannot open file');
    return
end
%set pointer at beginnig of channel header
fseek(fid,7504,'bof');
% skip variable headers
fseek(fid, 1020*header.frchevad(2) + 296*header.frchevad(3)...
    + 296*header.frchevad(4), 'cof');
% [unit,channel]=find(tscounts~=0);
% tscountu=sparse(max(unit),max(channel)-1);
% tscountnum=tscountu;

% read the data


while feof(fid) == 0
    arrvar=fread(fid, 8, 'ubit16');
    % 	type = fread(fid, 1, 'int16');
    % 	upperbyte = fread(fid, 1, 'int16');
    % 	timestamp = fread(fid, 1, 'int32');
    % 	channel = fread(fid, 1, 'int16');
    % 	unit = fread(fid, 1, 'int16');
    % 	nwf = fread(fid, 1, 'int16');
    % 	nwords = fread(fid, 1, 'int16');
    if isempty(arrvar)
        break
    end
    %     type = arrvar(1);
    %     upperbyte = arrvar(2);
    %     timestamp = upperbyte*2^32+arrvar(4)*2^16+arrvar(3);
    %     channel = arrvar(5);
    %     unit = arrvar(6);
    %     nwf = arrvar(7);
    %     nwords = arrvar(8);
    %     toread = nwords;
    if arrvar(8) > 0
        wf = fread(fid, arrvar(8), 'int16');
        %         fseek(fid,arrvar(8)*2,0);
    end
    if arrvar(1) == 1
        if sum(arrvar(5) == options.channels) ==1
            
            if sum(options.toimport==0)
                data.Channels(tscountnum(arrvar(5))).ts...
                    (tscountu(arrvar(5)),1)=...
                    (arrvar(2)*2^32+arrvar(4)*2^16+arrvar(3))/freq;
                data.Channels(tscountnum(arrvar(5))).unit...
                    (tscountu(arrvar(5)),1)=...
                    arrvar(6);
                tscountu(arrvar(5))=...
                    tscountu(arrvar(5))+1;
            end
            if sum(options.toimport==3)==1
                if sum(arrvar(5) == options.wfchannels) ==1
                    if arrvar(8) > 0
                        data.Waveforms(wfcountnum(arrvar(5))).ts...
                            (wfcountu(arrvar(5)),1)=...
                            (arrvar(2)*2^32+arrvar(4)*2^16+arrvar(3))/freq;
                        data.Waveforms(wfcountnum(arrvar(5))).unit...
                            (wfcountu(arrvar(5)),1)=...
                            arrvar(6);
                        data.Waveforms(wfcountnum(arrvar(5))).waves...
                            (wfcountu(arrvar(5)),1:size(wf))=...
                            wf;
                        wfcountu(arrvar(5))=wfcountu(arrvar(5))+1;
                    end
                end
            end
            
            
            
        end
    elseif arrvar(1)==4 %&& ~isfield(options,'strobe_tsinfo') 
        if sum(options.toimport==1)
            if sum(arrvar(5) == options.evchannels) >=1
                data.Events(evcountnum(1,arrvar(5))).ts...
                    (evcountu(arrvar(5)),1)=...
                    (arrvar(2)*2^32+arrvar(4)*2^16+arrvar(3))/freq;
                evcountu(1,arrvar(5))=...
                    evcountu(1,arrvar(5))+1;
            end
        end
    end
    
    
    if feof(fid) == 1
        break
    end
    
end
%disp(strcat('number of timestamps = ', num2str(n)));

if isfield(options,'strobe_tsinfo')
    
    for ts=1:length(strfind([options.strobe_tsinfo.name]...
            ,'Strobe00'))
        data.Events(ts).ts=options.strobe_tsinfo(ts).ts;
    end
    
    
end

fclose(fid);
toc
%saving matlab file
if saveflag
%     if length(data.Events(1).ts)<50
%         1;
%     end
    if exist(savefilename)
        dataex=load(savefilename,'-mat');
        if isfield(dataex,'Waveforms')
            dataex=rmfield(dataex,'Waveforms');
            save(savefilename,'-struct','dataex');
        end
        argin{end+1}='-append';
        lastargwf{1}='-append';
    else
        lastargwf{1}='';
    end
    if sum(options.toimport~=3)
        save(savefilename,'-struct','data',argin{:})
        lastargwf{1}='-append';
    end
    if sum(options.toimport==3)==1
        for wfch=1:length(argwavname)
            eval([argwavname{wfch},'=','data.Waveforms(',num2str(wfch),');']);
            if wfch~=1
                lastargwf={'-append'};
            end
            save(savefilename,argwavname{wfch},lastargwf{:});
        end
    end
end