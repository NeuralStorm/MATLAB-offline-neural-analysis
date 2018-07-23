function out=plx_header(filename)

% This fuction gather information from a specified plx file.
% out=get_plx_header(filename)
% input
% - filename : name of the nexfile to open
% - out : struct containing the information gathered from the plx file
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
try

fid=fopen(filename);
fseek(fid,136,'cof');
frchevad=fread(fid,[1,4],'int');
fseek(fid,8,'cof');
datearr=fread(fid,[1,3],'int');
fseek(fid,192,'bof');
out.duration=fread(fid,1,'double')/frchevad(1);
fseek(fid,256,'bof');
tscounts=(fread(fid,[5,130],'int'));
wfcounts=(fread(fid,[5,130],'int'));
evcounts=(fread(fid,[1,512],'int'));
fclose(fid);

out.arrvar=zeros(1,7)*0;
if max(max(tscounts))~=0
    out.arrvar(1)=1;
    [rowname,colname]=find(tscounts~=0);
end
if max(max(wfcounts))~=0
    out.arrvar(4)=1;
end
if max(max(evcounts(1:300)))~=0
    out.arrvar(2)=1;
    evlist=find(evcounts(1:300)~=0);
end
if max(max(evcounts(300:512)))~=0
    out.arrvar(6)=1;
    adlist=find(evcounts(300:512)~=0);
end

fid=fopen(filename);   
fseek(fid,7504,'bof');
nc=1;
wc=1;
for i=1:frchevad(2)
    name=regexpi(char(fread(fid,[1,32],'char')),'\w+','match');
    char(fread(fid,[1,32],'char'));
    vals=fread(fid,[1,9],'int');
    
    
    out.Channels(nc).name=name{1};
    out.Channels(nc).count=sum(tscounts(2:vals(end)+1,vals(1)+1));
    out.Channels(nc).unitscount=vals(end);
    out.Channels(nc).channel=vals(1);
    out.Channels(nc).ts=[];
    out.Channels(nc).unit=[];
    nc=nc+1;
    if sum(wfcounts(2:vals(end)+1,vals(1)+1))~=0
        str=sprintf('Waveforms%03d',wc);
        out.(str).name=name;
        out.(str).wfcount=sum(wfcounts(2:vals(end)+1,vals(1)+1));
        out.(str).unitscount=vals(end);
        out.(str).channel=vals(1);
        out.(str).ts=[];
        out.(str).unit=[];
        out.(str).waves=[];
        wc=wc+1;
    end
    
    % set the pointer to the beginning of the next sig channel
    fseek(fid,7504+i*1020,'bof');
end
fclose(fid);

fid=fopen(filename);   
fseek(fid,7504+frchevad(2)*1020,'bof');
nev=1;
for i=1:frchevad(3)
    name=regexpi(char(fread(fid,[1,32],'char')),'\w+','match');
    vals=fread(fid,[1],'int');
    if evcounts(vals+1)~=0;
        out.Events(nev).name=name{1};
        out.Events(nev).channel=vals;
        out.Events(nev).count=evcounts(vals+1);
        out.Events(nev).ts=[];
        nev=nev+1;
    end
    % set the pointer to the beginning of the next sig channel
    fseek(fid,7504+frchevad(2)*1020+i*296,'bof');
end
fclose(fid);

fid=fopen(filename);   
fseek(fid,7504+frchevad(2)*1020+frchevad(3)*296,'bof');
cn=1;
for i=1:frchevad(4)
    name=char(fread(fid,[1,32],'char'));
    vals=fread(fid,[1,4],'int');
    if vals(end)~=0
        out.Countinous(cn).name=name;
        out.Countinous(cn).channel=vals(1);
        out.Countinous(cn).count=evcounts(300+vals(1));
        cn=cn+1;
    end
    % set the pointer to the beginning of the next sig channel
    fseek(fid,7504+frchevad(2)*1020+frchevad(3)*296+i*296,'bof');
end
fclose(fid);
catch
    out=[];
    disp('File corrupted or unreadable')
end


