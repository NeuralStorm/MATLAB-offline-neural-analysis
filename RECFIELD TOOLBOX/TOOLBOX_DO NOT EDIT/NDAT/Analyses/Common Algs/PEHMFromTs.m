%$Rev: 89 $
%$Author: Nate $
%$LastChangedDate: 2017-02-02 15:25:43 -0500 (Thu, 02 Feb 2017) $


%"PEHM" structure=trialsxbins

function [PEHM,bins]=PEHMFromTs(neuts,evts,options)


if isfield(options,'firstspike')
else
    options.firstspike='all';
end


bin=options.bin;
pretime=options.pretime;
posttime=options.posttime;

%assumes time in seconds

Trials=length(evts);
bins=(-pretime:bin:posttime-bin);
nbins=length(bins);


if nbins~=(pretime+posttime)/bin
    intervallastbin=[bins(end),posttime];
end


% 
% tempoptions.firstspike=options.firstspike;
% tempoptions.response=options.response;


% PEHM  = createPEHM(neuts,evts, Trials,bins,tempoptions);


for k=1:Trials
    
    %matrcurr=round((neuts-evts(k))*100000)/(100000);
    matrcurr=(neuts-evts(k));
    
    %new=find((matrcurr<posttime)&(matrcurr>=-pretime));
    %matrcurr=matrcurr((matrcurr<posttime)&(matrcurr>=-pretime));
    if isempty(matrcurr)
    else
        [x]=histc(matrcurr,bins);
        
        switch options.firstspike
            
            case {'first'}
                
                firstsp=min(find(x(options.response)==1));
                x(setdiff([min(options.response):length(bins)],min(options.response)-1+firstsp))=0;                
                
            case {'subsequent'}
                
                firstsp=min(find(x(options.response)==1));
                x(min(options.response)-1+firstsp)=0;
                
            otherwise
                
        end
        PEHM(k,:)=x(1:length(bins));
    end
    
end
PEHM=sparse(PEHM);

