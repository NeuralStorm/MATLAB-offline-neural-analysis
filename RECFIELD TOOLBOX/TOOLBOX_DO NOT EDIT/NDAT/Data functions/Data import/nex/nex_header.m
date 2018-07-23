function out=nex_header(filename)

% This fuction gather information from a specified plx file.
% out=get_plx_header(filename)
% input
% - filename : name of the nexfile to open
% - out : struct containing the information gathered from the nex file
%         .frchevad   [sampling frequency, channels number, event number, ad channel number]
%         .datearr    [year, month, day]
%         .duration   (length of the recording)
%         .counts   [counts of the timestamps as given in the definition of the plx files]
%         .wfcounts   [counts of the waveforms timestamps as given in the definition of the plx files]
%         .evcounts   [counts of the events timestamps as given in the definition of the plx files]
%         .arrvar     boolean variable [neurons, events, interval, waveform, population, continous, marker]
%         .signames   3xsignum cell {row, col, name}
%         .eventnames 2xevents cell {event number, eventname}
%         .adnames    2xadchan cell {adchannum,ad chan name}
%
%
% 2006
% Alessandro Scaglione
% Drexel University
% version 1.0


fid=fopen(filename);
magic = fread(fid, 1, 'int32');
if magic ~= 827868494
    disp('Not valid nex file or file corrupted')
    disp('removing from the import')
    out=[];
    return
end
version = fread(fid, 1, 'int32');
comment = fread(fid, 256, 'char');
frchevad = fread(fid, 1, 'double');
tbeg = fread(fid, 1, 'int32');
tend = fread(fid, 1, 'int32');
out.duration=(tend - tbeg)/frchevad(1);
out.arrvar=zeros(1,7)*0;


nvar = fread(fid, 1, 'int32');
fseek(fid, 260, 'cof');
names = zeros(1, 64);
nc=1;
ec=1;
ic=1;
wc=1;
pc=1;
cc=1;
mc=1;


for i=1:nvar
    type(i) = fread(fid, 1, 'int32');
    varVersion(i) = fread(fid, 1, 'int32');
    name(i,:) = fread(fid, 64, '*char')';
    
    nname=name(i,:);
    %     % remove first zero and all characters after the first zero
    nname(end+1) = 0;
    nname = nname(1:min(find(nname==0))-1);
    if type(i)==0 || type(i)==3
        el=regexpi(nname,'\d+[a,b,c,d,i]','match');
        chan=regexpi(el{1},'\d+','match');
        unit=regexpi(el{1},'\D','match');
        chan=str2num(chan{1});
        nname=regexpi(nname,'\w+\d+','match');
        nname=nname{1};
        if unit{1}~='i'
            unit=double(unit{1})-96;
        else
            unit=0;
        end
    end
    offset(i) = fread(fid, 1, 'int32');
    n(i) = fread(fid, 1, 'int32');
    wireNumber(i) = fread(fid, 1, 'int32');
    unitNumber(i) = fread(fid, 1, 'int32');
    gain(i) = fread(fid, 1, 'int32');
    filter(i) = fread(fid, 1, 'int32');
    xPos(i) = fread(fid, 1, 'double');
    yPos(i) = fread(fid, 1, 'double');
    WFrequency(i) = fread(fid, 1, 'double'); % wf sampling fr.
    ADtoMV(i)  = fread(fid, 1, 'double'); % coeff to convert from AD values to Millivolts.
    NPointsWave(i) = fread(fid, 1, 'int32'); % number of points in each wave
    NMarkers(i) = fread(fid, 1, 'int32'); % how many values are associated with each marker
    MarkerLength(i) = fread(fid, 1, 'int32'); % how many characters are in each marker value
    MVOfffset(i) = fread(fid, 1, 'double'); % coeff to shift AD values in Millivolts: mv = raw*ADtoMV+MVOfffset
    dummy = fread(fid, 60, 'char');
    out.arrvar(type(i)+1)=1;
    switch type(i)
        
        case 0
            
            out.Channels(nc).name=nname;
            out.Channels(nc).count=n(i);
            out.Channels(nc).channel=chan;
            out.Channels(nc).ts=[];
            out.Channels(nc).unit=[];
            nc=nc+1;
            
        case 1
            out.Events(ec).name=nname;
            out.Events(ec).count=n(i);
            out.Events(ec).channel=ec;
            out.Events(ec).ts=[];
            
            ec=ec+1;
            
        case 2
            out.Intervals(ic).name=nname;
            out.Intervals(ic).count=n(i);
            ec=ec+1;
            
        case 3
            out.Waveforms(wc).name=nname;
            out.Waveforms(wc).count=n(i);
            out.Waveforms(wc).NpointsWave=NPointsWave(i);
            out.Waveforms(wc).channel=chan;
            out.Waveforms(wc).ts=[];
            out.Waveforms(wc).unit=[];
            out.Waveforms(wc).waves=[];
            wc=wc+1;
            
        case 4
            out.Population(pc).name=nname;
            out.Population(pc).count=n(i);
            pc=pc+1;
            
        case 5
            out.Continous(cc).name=nname;
            out.Continous(cc).count=n(i);
            cc=cc+1;
            
        case 6
            out.Marker(mc).name=nname;
            out.Marker(mc).count=n(i);
            mc=mc+1;
    end
end

%merging units on the same channel and deleting empty channels
if out.arrvar(1)
    [a,b,c]=unique([out.Channels.channel]);
    
    for i=1:length(b)
        out.Channels(b(i)).count=sum([out.Channels(a(i)==c).count]);
        out.Channels(b(i)).unitscount=sum(a(i)==c);
    end
    
    out.Channels=out.Channels(b);
end
if out.arrvar(4)
    %% repeating procedure for the Waveforms data
    [a,b,c]=unique([out.Waveforms.channel]);
    
    for i=1:length(b)
        out.Waveforms(b(i)).count=sum([out.Waveforms(a(i)==c).count]);
        out.Waveforms(b(i)).unitscount=sum(a(i)==c);
    end
    
    out.Waveforms=out.Waveforms(b);
    
    %% upgrading Waveforms Data
    
    for i=1:length(out.Waveforms)
        str=sprintf('Waveforms%03d',i);
        out.(str)=out.Waveforms(i);
    end
    out.Waveforms=[];
    out=rmfield(out,'Waveforms');
end



