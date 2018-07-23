% clear all;
% 
% clc;
% filename = '/home/anitha/Documents/Chronic Brain reorganization/Chronic Sensory Reorganization/110412.CSR002.TRM.WEEK0/110412.CSR002.TRM.WEEK0.matnd';

%% Get the background firing rates of neurons in 2 regions based on the
%% entire recording. 
function [UnitFiringRateRegion1,UnitFiringRateRegion2] = BackgroundFiringRate(filename)   %varargout was unitfiringrate2
%Eric tried a modification that included "varargout" as output instead of
%UnitFiringRateRegion2 and everything below "added" (line 31 and below)
UnitFiringRateRegion1=[];  %nate added
UnitFiringRateRegion2=[];  %nate added


load(filename,'-mat');
k = 1;
m = 1;
for i = 1:length(Channels)
 
    unitCnt = unique(Channels(1,i).unit);
    for j = 1:length(unitCnt)
        UnitFirings = Channels(1,i).ts(Channels(1,i).unit==unitCnt(j)) ;
        if Channels(1,i).channel<17
            UnitFiringRateRegion1(k) = length(UnitFirings)/UnitFirings(end);   
            k= k+1;
        elseif Channels(1,i).channel >= 17
            UnitFiringRateRegion2(m) =length(UnitFirings)/UnitFirings(end);
            m = m+1;
        end
    end
    
end

%%added
% if(exist('UnitFiringRateRegion2','var'))   
%     varargout =UnitFiringRateRegion2;
% end

