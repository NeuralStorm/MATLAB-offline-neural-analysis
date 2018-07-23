function [PEH,bins,units]=PEHFromTs(neuts,evts,options)
%This function converts perievent history matrix into user specified units
%Also takes trials by bin "PEHM" and creates PSTH by summing across trials

%$Rev: 88 $
%$Author: Nate $
%$LastChangedDate: 2017-02-02 15:22:35 -0500 (Thu, 02 Feb 2017) $

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
        
        PEH=sum(PEHM)/Trials/options.bin;
end
