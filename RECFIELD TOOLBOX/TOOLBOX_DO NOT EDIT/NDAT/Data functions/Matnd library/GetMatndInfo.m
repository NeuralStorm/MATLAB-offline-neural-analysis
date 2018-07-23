function info=GetMatndInfo(filename)

infile=whos('-file',filename);
info.infilenum=[];
for i=0:6
    
    switch i
        
        case 0
            if sum(strcmpi({infile.name},'Channels')) 
                info.infilenum=[info.infilenum,i];
            end
        case 1
            if sum(strcmpi({infile.name},'Events'))
                info.infilenum=[info.infilenum,i];
            end
        case 2 
            if sum(strcmpi({infile.name},'Intervals'))
                info.infilenum=[info.infilenum,i];
            end
        case 3 
            if sum(strncmpi({infile.name},'Waveforms',9))>0
                info.infilenum=[info.infilenum,i];
            end
        case 4
            if sum(strcmpi({infile.name},'Population'))
                info.infilenum=[info.infilenum,i];
            end
        case 5
%             if sum(strcmpi({infile.name},'Continous'))
%                 info.infilenum=[info.infilenum,i];
%             end
        case 6 
            if sum(strcmpi({infile.name},'Marker'))
                info.infilenum=[info.infilenum,i];
            end
            
    end
end

% checking numbers of neurons

load(filename,'-mat','Channels','Events')

if sum(info.infilenum==0);
    units=[];
    channels=[];
    channame={};
    h=1;
    for c=1:length(Channels)
        for u=unique(Channels(c).unit(:,end))'
            channels(h,1)=Channels(c).channel;
            units(h,1)=u;
            name=Channels(c).name;
            name(double(name)==0)=[];
            channame(h,1)={[name,char(96+u)]};
            h=h+1;
        end
    end
    
    info.chanunits=[channels,units];
    info.channame=channame;
end

if sum(info.infilenum==1);
    channels=[];
    evnames={};
    ev=1;
    for s=1:length(Events)
        if Events(s).channel<258  && strcmpi(Events(s).name,'start')~=1 && strcmpi(Events(s).name,'stop')~=1
            
            channels=[channels ; Events(s).channel];
            evnames(ev,1)={Events(s).name};
            ev=ev+1;
        elseif Events(s).channel==258 || strcmpi(Events(s).name,'start')==1
            
            info.startts=Events(s).ts(end);
            
        elseif Events(s).channel==259 || strcmpi(Events(s).name,'stop')==1
            
            
            info.stopts=Events(s).ts(end);
        end
    end
    info.evchannels=channels;
    info.evnames=evnames;
end



