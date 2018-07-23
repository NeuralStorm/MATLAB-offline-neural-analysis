function [PEHMClass,Group, varargout]=PEHMClassFromMatnd(filename,options)

%PEHMClass=(trials*eventNum)x bins

%setting options and defining variables

options.units='counts';

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

if isfield(options,'firstspike')
else
    options.firstspike='all';
end

% start algorithm


if ~indiscriminate
    options.chanunit(options.chanunit(:,2)==0,:)=[];
end

if isfield(options,'stimback')
else
    options.stimback=0;
end


load(filename,'-mat','Channels','Events');


if isfield(options,'intervals')
    if ~strcmpi(options.intervals,'All')
        load(filename,'-mat','Channels','Intervals');
        for i=1:length(Intervals)
            if strcmpi(Intervals(i).name,options.intervals)
                intervals=Intervals(i).intervals;
            end
        end
    else
        intervals=[0,Events(end).ts(end)];
    end
    
else
    intervals=[0,Events(end).ts(end)];
end

c=1;


for s=1:length([Events.channel])
    if sum(Events(s).channel==options.evchannels)
        currts=Events(s).ts;
        Trials{c}=length(currts);
        for t=1:Trials{c}
            if sum(currts(t)>intervals(currts(t)<intervals(:,2),1))==1
                savets(t,1)=1;
            end
        end
        currts=currts(boolean(savets));
        savets=[];
        Trials{c}=length(currts);
        Ts{c}=currts;
        c=c+1;
    end
end



for s=1:length(Ts)
    tempPEHM=[];
    %UnitIdentifier=[];
    for c=1:length(Channels)
        for u=unique(Channels(c).unit(:,end))'
            if sum(Channels(c).channel==options.chanunit((options.chanunit(:,2)==u)),1)==1
                PEHMsingleunit=PEHMFromTs(...
                    Channels(c).ts(Channels(c).unit(:,end)==u),Ts{s},options);
                % tempUnitIdentifier=[c,u];
                if options.stimback
                    optionsn=options;
                    optionsn.pretime=options.posttime;
                    optionsn.posttime=options.pretime;
                    PEHMsingleunitb=PEHMFromTs(...
                    Channels(c).ts(Channels(c).unit(:,end)==u),Ts{s},optionsn);
                    PEHMsingleunit=cat(1,PEHMsingleunitb,PEHMsingleunit);
                end
                
                
                [tempPEHM]=[tempPEHM,PEHMsingleunit];
                %[UnitIdentifier]=[UnitIdentifier;tempUnitIdentifier];
            end
        end
    end
    tempPEHMc{s}=tempPEHM;
end

PEHMClass=tempPEHMc{1};
Group=ones(size(PEHMClass,1),1);
if options.stimback
    Group(1:size(PEHMClass,1)/2)=0;
end
for s=2:length(Ts)
    PEHMClass=cat(1,PEHMClass,tempPEHMc{s});
    groupt=ones(size(tempPEHMc{s},1),1)*s;
    if options.stimback
        groupt=ones(size(tempPEHMc{s},1),1)*1;
        groupt(1:size(tempPEHMc{s},1)/2)=0;
    end
    Group=cat(1,Group,groupt);
    
end
if min(Group)==0
    Group=Group+1;
end

if nargout==3
     varargout{1}=info;
elseif nargout>3
     disp('Output not specified beyond this range')
else
end
%         
        

