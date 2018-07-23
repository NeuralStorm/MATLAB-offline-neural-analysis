function data = import_nex_nodll(filename,options,saveflag)


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
        header=nex_header(filename);
        allnames={header.Events.name}';
        options.evnames=allnames(options.evchannels);
    end
end
[path,name,ext]=fileparts(filename);
if isempty(path)
    savefilename=[name,'.matnd'];
else
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


%initializing data structure from header

data=nex_header(filename);
datafile=readNexFile(filename);
if(length(filename) == 0)
    [fname, pathname] = uigetfile('*.nex', 'Select a nex file');
    filename = strcat(pathname, fname);
end


% importing


argin={};
if sum(options.toimport==0)==1
    for c=1:length(datafile.neurons)
        el=regexpi(datafile.neurons{c}.name,'\d+[a,b,c,d,i]','match');
        chan=regexpi(el{1},'\d+','match');
        unit=regexpi(el{1},'\D','match');
        chan=str2num(chan{1});
        if unit{1}=='i'
            unit=0;
        else
            unit=double(unit{1})-96;
        end
        index=[data.Channels.channel]==chan;
        data.Channels(index).ts=[data.Channels(index).ts...
            ;datafile.neurons{c}.timestamps];
        nts=length(datafile.neurons{c}.timestamps);
        data.Channels(index).unit=[data.Channels(index).unit...
            ;repmat(unit,nts,1)];
        data.Channels(index).count=nts;
    end

    
    argin{end+1}='Channels';
end

if sum(options.toimport==1)==1
    ev=1;
    data=rmfield(data,'Events');
    for i=1:length(datafile.events)
        
        if sum(options.evchannels==i) || strcmpi(datafile.events{i}.name,'start')==1 || strcmpi(datafile.events{i}.name,'stop')==1
            data.Events(ev).ts=datafile.events{i}.timestamps;
            data.Events(ev).count=length(datafile.events{i}.timestamps);
            data.Events(ev).name=datafile.events{i}.name;
            data.Events(ev).channel=i;
            ev=ev+1;
        end
    end
    argin{end+1}='Events';
end

if sum(options.toimport==3)==1
    
    
  for c=1:length(datafile.waves)
        el=regexpi(datafile.waves{c}.name,'\d+[a,b,c,d,i]','match');
        chan=regexpi(el{1},'\d+','match');
        unit=regexpi(el{1},'\D','match');
        chan=str2num(chan{1});
        if unit{1}=='i'
            unit=0;
        else
            unit=double(unit{1})-96;
        end
        str=sprintf('Waveforms%03d',chan);
        data.(str).ts=[data.(str).ts...
            ;datafile.waves{c}.timestamps];
        nts=length(datafile.waves{c}.timestamps);
        data.(str).unit=[data.(str).unit...
            ;repmat(unit,nts,1)];
        data.(str).count=nts;
        data.(str).waves=[data.(str).waves...
            ;datafile.waves{c}.waveforms'];
    end
   
    
end

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