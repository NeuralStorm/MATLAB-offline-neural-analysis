function [PEHM]=PEHMFromMatndTRM(filename,options)

%setting options and defining variables

options.units='probability';

if ~isfield(options,'chanunit')
    info=GetMatndInfo(filename);
    options.chanunit=info.chanunits;
end

if ~isfield(options,'evchannels')
    
    options.evchannels=info.evchannels;
end



if ~isfield(options,'region')
else
    chantorem=setdiff(unique(options.chanunit(:,1)),options.region);
    for r=1:length(chantorem)
        options.chanunit(options.chanunit(:,1)==chantorem(r),:)=[];
    end
end

if ~isfield(options,'indiscriminate')
    indiscriminate=0;
else
    indiscriminate=options.indiscriminate;
end


% start algorithm


if ~indiscriminate
    options.chanunit(options.chanunit(:,2)==0,:)=[];
end




load(filename,'-mat','Channels','Events','EventsNew');


if isfield(options,'intervals')
    if ~strcmpi(options.intervals,'All')
        load(filename,'-mat','Channels','Intervals');
        for i=1:length(Intervals)
            if strcmpi(Intervals(i).name,options.intervals)
                intervals=Intervals(i).intervals;
            end
        end
    else
        intervals=[0,Events(1,end).ts];
    end
else
    intervals=[0,Events(1,end).ts];
end

for s=1:length(options.evchannels)
    
    currts=EventsNew(1,s).ts;
    if currts ~= 0
        Trials{s}=length(currts);
        
        for t=1:Trials{s}
            if sum(currts(t)>intervals(currts(t)<intervals(:,2),1))==1
                savets(t,1)=1;
            end
        end
        currts=currts(boolean(savets));
        savets=[];
        Trials{s}=length(currts)
        Ts{s}=currts;
    end
end


bins=(-options.pretime:options.bin:options.posttime);
for s=1:length(Ts)
    tempPEHM=zeros(length(bins),length(options.chanunit));
    h=1;
    for c=1:length(Channels)
        for u=unique(Channels(c).unit)'
            if sum(Channels(c).channel==options.chanunit((options.chanunit(:,2)==u)),1)==1
                tempPEHM(:,h)=PEHFromTs(Channels(c).ts(Channels(c).unit==u)...
                    ,Ts{s},options)';
                h=h+1;
            end
        end
    end
    tempPEHMc{s}=tempPEHM;
end

PEHM=full(tempPEHMc{1});
for s=2:length(Ts)
    PEHM=cat(3,PEHM,full(tempPEHMc{s}));
end



