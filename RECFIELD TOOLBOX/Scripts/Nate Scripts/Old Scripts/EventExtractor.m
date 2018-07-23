%Nathaniel Bridges

%Tilt Events Extractor
clc;
close all;
clear all;

%Load Tilt Type csv
TiltType=load('C:\Users\Nate\Documents\RTNC\RTNC001\OpenLoop 1_12_06_13\RTNC001_classify.AmpDur.Week0_12.06.2013_12.41_48_TiltTypes.csv');
%Find Event Timestamps
%work on this later
ts=Events(1).ts;

%Extract and Label Timestamp Types
tiltstart=ts(1:4:end);
tiltend=ts(2:4:end);
return_init=ts(3:4:end);
return_end=ts(4:4:end);

%Extract 

i=1:4
events(:,i).type=find(TiltType==i)
end



