function out=plx_header_nodll(filename)

% This fuction gather information from a specified plx file.
% out=get_plx_header(filename)
% input
% - filename : name of the nexfile to open
% - out : struct containing the information gathered from the nex file
%         .frchevad   [sampling frequency, channels number, event number, ad channel number]
%         .datearr    [year, month, day]
%         .duration   (length of the recording)
%         .tscounts   [counts of the timestamps as given in the definition of the plx files]
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
fseek(fid,136,'cof');
out.frchevad=fread(fid,[1,4],'int');
fseek(fid,8,'cof');
out.datearr=fread(fid,[1,3],'int');
fseek(fid,192,'bof');
out.duration=fread(fid,1,'double')/out.frchevad(1);
fseek(fid,256,'bof');
out.tscounts=(fread(fid,[5,130],'int'));
out.wfcounts=(fread(fid,[5,130],'int'));
out.evcounts=(fread(fid,[1,512],'int'));
fclose(fid);

out.arrvar=zeros(1,7)*0;
if max(max(out.tscounts))~=0
    out.arrvar(1)=1;
    [rowname,colname]=find(out.tscounts~=0);
end
if max(max(out.wfcounts))~=0
    out.arrvar(4)=1;
end
if max(max(out.evcounts(1:300)))~=1
    out.arrvar(2)=1;
    evlist=find(out.evcounts(1:300)~=0);
end
if max(max(out.evcounts(300:512)))~=0
    out.arrvar(6)=1;
    adlist=find(out.evcounts(300:512)~=0);
end

fid=fopen(filename);   
fseek(fid,7504,'bof');
for i=1:out.frchevad(2)
    out.sig(i).name=char(fread(fid,[1,32],'char'));   
    name=char(fread(fid,[1,32],'char'));
    fread(fid,[1,9],'int');
    % set the pointer to the beginning of the next sig channel
    fseek(fid,7504+i*1020,'bof');
end
fclose(fid);

fid=fopen(filename);   
fseek(fid,7504+out.frchevad(2)*1020,'bof');
for i=1:out.frchevad(3)
    out.event(i).name=char(fread(fid,[1,32],'char'));   
    
    
    % set the pointer to the beginning of the next sig channel
    fseek(fid,7504+out.frchevad(2)*1020+i*296,'bof');
end
fclose(fid);

fid=fopen(filename);   
fseek(fid,7504+out.frchevad(2)*1020+out.frchevad(3)*296,'bof');
for i=1:out.frchevad(4)
    out.adchannels(i).name=char(fread(fid,[1,32],'char'));   
    
    
    % set the pointer to the beginning of the next sig channel
    fseek(fid,7504+out.frchevad(2)*1020+out.frchevad(3)*296+i*296,'bof');
end
fclose(fid);



% [n,signame]=plx_chan_names(filename);
% [n,eventsname]=plx_event_names(filename);
% [n,adname]=plx_adchan_names(filename);
% 
% dummyvar=1;
% for i=1:length(rowname)
%     if rowname(i)~=1
%         out.signames{dummyvar,1}=rowname(i);
%         out.signames{dummyvar,2}=colname(i);
%         out.signames{dummyvar,3}=[signame(colname(i)-1,:),char(95+rowname(i))];
%         dummyvar=dummyvar+1;
%     end
% end
% dummyvar=1;
% for i=1:length(evlist)
%     if (evlist(i)-1)<100
%         out.eventnames{dummyvar,1}=evlist(i)-1;
%         out.eventnames{dummyvar,2}=eventsname(evlist(i)-1,:);
%         dummyvar=dummyvar+1;
%     elseif (evlist(i)-1)<=109
%         out.eventnames{dummyvar,1}=evlist(i)-1;
%         out.eventnames{dummyvar,2}=['Keyboard',num2str(evlist(i)-100)];
%         dummyvar=dummyvar+1;
%     elseif evlist(i)==259
%         out.eventnames{dummyvar,1}=evlist(i)-1;
%         out.eventnames{dummyvar,2}='Start';
%         dummyvar=dummyvar+1;
%         out.eventnames{dummyvar,1}=evlist(i+1)-1;
%         out.eventnames{dummyvar,2}='End';
%         dummyvar=dummyvar+1;
%     end
% end
% 
% dummyvar=1;
% for i=1:length(adlist)
%     out.adnames{dummyvar,1}=adlist(i)-1;
%     out.adnames{dummyvar,2}=adname(adlist(i)-1,:);
%     dummyvar=dummyvar+1;
% end
% 
