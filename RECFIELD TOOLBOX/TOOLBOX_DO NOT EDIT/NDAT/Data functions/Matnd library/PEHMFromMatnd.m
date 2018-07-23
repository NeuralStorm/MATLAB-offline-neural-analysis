function [PEHM,options]=PEHMFromMatnd(filename,options)

%PEHM=bins x neuron x event
%default option is probability 

%copy filename in case is a networkfile
origfile=filename;
[p,f,ext]=fileparts(filename);
p=fileparts(which('Configure_path'));
filename=[p,filesep,f,ext];
copyfile(origfile,filename);  % if you get an error here, then set the current directory to the directory where your .matnd files are located. The program looks for the file in the current directory and returns and error if it cannot find the file. 
evflag = 1;
%setting options and defining variables
if isfield(options,'units')
else
    options.units='probability';
end
info=GetMatndInfo(filename);
if ~isfield(options,'chanunit')
    chunitflag=1;
    options.chanunit=info.chanunits;
end

if ~isfield(options,'evchannels')
    evflag=1;
    options.evchannels=info.evchannels;
    if sum(options.evchannels==100)   %changed from 17 to 100
        [options.evchannels,i]=setdiff(options.evchannels,[1:16]);
        options.evnames=info.evnames(i);
    end
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



if isfield(options,'wires')
else
    options.wires=0;
end


% start algorithm


if ~indiscriminate
    options.chanunit(options.chanunit(:,2)==0,:)=[];
end




load(filename,'-mat','Channels','Events');

% re-define "Events" with select trials if user-specified
if isfield(options,'trials')
Events = selectTrials_Events(Events,options);
end


if isfield(options,'intervals')
    load(filename,'-mat','Channels','Intervals');
    for i=1:length(Intervals)
        if strcmpi(Intervals(i).name,options.intervals)
            intervals=Intervals(i).intervals;
        end
    end
else
    intervals=[0,info.stopts];
end

if isfield(options,'evnames')
else
    options.evnames=info.evnames;
end



options=rmfield(options,'evchannels'); 
for s=1:length([options.evnames])
    % identifing events
    if iscell(options.evnames{s})
        evs=options.evnames{s};
    else
        evs=options.evnames(s);
    end
    temp=false(1,length({Events.name}));
    currts=[];
    for i=1:length(evs)
        temp=logical(temp+strcmpi({Events.name},evs{i}));
        currts=[currts;Events(strcmpi({Events.name},evs{i})).ts];
    end
    Trials{s}=length(currts);
    for t=1:Trials{s}
        if sum(currts(t)>intervals(currts(t)<intervals(:,2),1))==1
            savets(t,1)=1;
        end
    end
    currts=currts(boolean(savets));
    savets=[];
    Trials{s}=length(currts);
    Ts{s}=currts;
    
    options.evchannels{s}=[Events(temp).channel];

    options.EvTrials(s)=length(Ts{s});
    
end


bins=(-options.pretime:options.bin:options.posttime-options.bin);

% for each event type
for s=1:length(Ts)
    tempPEHM=zeros(length(bins),length(options.chanunit));
    h=1;
    for c=1:length(Channels)
        units=unique(Channels(c).unit(:,end))';
        if options.wires
            units=1;
            Channels(c).unit(Channels(c).unit(:,end)~=0,end)=1;
        end
        for u=units
            if sum(Channels(c).channel==options.chanunit((options.chanunit(:,2)==u)),1)==1
                tempPEHM(:,h)=PEHFromTs(Channels(c).ts(Channels(c).unit(:,end)==u)...
                    ,Ts{s},options)';
                options.anchan(h,1)=Channels(c).channel;
                options.anchan(h,2)=u;
                h=h+1;
                
            end
        end
    end
    tempPEHMc{s}=tempPEHM(:,[1:h-1]);
end

PEHM=full(tempPEHMc{1});


for s=2:length(Ts)
    PEHM=cat(3,PEHM,full(tempPEHMc{s}));
end

if chunitflag
    options=rmfield(options,'chanunit');
end
if evflag
    options=rmfield(options,'evchannels');
end
delete(filename)
