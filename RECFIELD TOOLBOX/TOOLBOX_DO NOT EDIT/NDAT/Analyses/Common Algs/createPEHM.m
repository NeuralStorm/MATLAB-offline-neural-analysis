function [ PEHM ] = createPEHM(neuts,evts, Trials,bins,options) %#codegen

PEHM=ones(1,length(bins));

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
                
               
                
                firstsp=find((x(options.response)==1),1);
                
                x(setdiff(min(options.response):length(bins),min(options.response)-1+firstsp))=0;                
                
            case {'subsequent'}
                
                firstsp=find((x(options.response)==1),1);
                x(min(options.response)-1+firstsp)=0;
                
            otherwise
                
        end
        %PEHM(k,:)=x(1:length(bins));
        
        xnew=x(1:length(bins))';
        
        PEHM=[PEHM;xnew];
    end
    
end

PEHM(1,:)=[];

end

