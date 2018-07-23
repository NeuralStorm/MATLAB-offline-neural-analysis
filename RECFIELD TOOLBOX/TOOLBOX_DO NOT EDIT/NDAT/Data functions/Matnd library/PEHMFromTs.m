function [PEHM,bins]=PEHMFromTs(neuts,evts,options)

bin=options.bin;
pretime=options.pretime;
posttime=options.posttime;

%assumes time in seconds

Trials=length(evts);
bins=(-pretime:bin:posttime);
nbins=length(bins);


if nbins~=(pretime+posttime)/bin
    intervallastbin=[bins(end),posttime];
end

PEHM=sparse(zeros(Trials,nbins));


for k=1:Trials
    
    matrcurr=round((neuts-evts(k))*100000)/(100000);
    
    new=find((matrcurr<posttime)&(matrcurr>=-pretime));
    if isempty(new)
    else
        check=matrcurr(new);
        [x,y]=histc(matrcurr(new),bins);
        PEHM(k,:)=x(1:length(bins));
    end
    
end


