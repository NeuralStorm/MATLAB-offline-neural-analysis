function [PEH,bins,units]=PEHFromTs(neuts,evts,options)

%assumes time in seconds

if isfield(options,'units')
    units=options.units;
else
    units='probability';
end

[PEHM,bins]=PEHMFromTs(neuts,evts,options);

Trials=size(PEHM,1);

switch units
    
    case 'probability'
        
        PEH=sum(PEHM)/Trials;
        
    case 'counts'
        
        PEH=sum(PEHM);
        
    case 'hz'
        
        PEH=sum(PEHM)/Trials/bin;
end