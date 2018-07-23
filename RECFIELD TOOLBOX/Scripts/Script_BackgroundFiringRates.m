clear all;

clc;
% filename = '/home/anitha/Documents/Chronic Brain reorganization/Chronic Sensory Reorganization/110412.CSR002.TRM.WEEK0/110412.CSR002.TRM.WEEK0.matnd';

function [UnitFiringRateRegion1,UnitFiringRateRegion2] = BackgroundFiringRate(filename)
load(filename);
k = 1;
m = 1;
for i = 1:length(Channels)
 
    unitCnt = unique(Channels(1,i).unit);
    for j = 1:length(unitCnt)
        UnitFirings = Channels(1,i).ts(Channels(1,i).unit==unitCnt(j)) ;
        if Channels(1,i).channel<17
            UnitFiringRateRegion1(k) = length(UnitFirings)/UnitFirings(end);
            k= k+1;
        elseif Channels(1,i) >= 17
            UnitFiringRateRegion2(m) =length(UnitFirings)/UnitFirings(end);
            m = m+1;
        end
    end
    
end

