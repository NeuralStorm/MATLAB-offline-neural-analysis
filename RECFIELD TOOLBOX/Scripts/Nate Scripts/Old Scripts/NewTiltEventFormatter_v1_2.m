%Nathaniel Bridges

%Description: takes in output from GUI import and formats for the
%PSTH_Classification Analysis script

%update:  more flexible to differnt number of tilt events, converted into a
%function 

%update date: 3/25/15

%update: everything in setup is defined by an input to the function for
%modularity between Ravi and Nate's computer

function y = NewTiltEventFormatter_v1_2(options)
%% Setup
clc;
datadir=options.datadir; 
addpath(genpath(datadir));
savdir=options.savdir; 

%% Import Data
disp('Importing data...')
[filename,pathname,filterindex]=uigetfile([datadir,'*matnd']);
data=load([pathname,filename],'-mat','Explab','Channels','Events');
Channels=data.Channels;
Events=data.Events;
Explab=data.Explab;
clear data
disp('Data import finished')
%% 1st Timestmps
tiltnum=size(Events,2)-2;

%Move "start" and "end" data to the end of the matrix
Events(2*tiltnum+1).name=Events(tiltnum+1).name;
Events(2*tiltnum+2).name=Events(tiltnum+2).name;  

Events(2*tiltnum+1).channel=2*tiltnum+1;
Events(2*tiltnum+2).channel=2*tiltnum+2;

Events(2*tiltnum+1).ts=Events(tiltnum+1).ts;
Events(2*tiltnum+2).ts=Events(tiltnum+2).ts;

for i=1:tiltnum
    
    %Names
    %Events(i).name=tilt_names{i};   was intended for defined tilt anems
    Events(i+tiltnum).name=[Events(i).name,'_background'];   %names for background events
    
    %Channels
    Events(i).channel=i;
    Events(i+tiltnum).channel=i+tiltnum;
    
    %Timestamps
    ts_temp=Events(i).ts(1:options.timestampnum:end);
    Events(i).ts=[];
    Events(i).ts=ts_temp;
    Events(i+tiltnum).ts=ts_temp-options.background; %subtracting 1 second for background event ts
    
end


%% Save Files
cd(savdir)
save(filename,'Events','Channels','Explab')
disp('Event conversion finished and saved')
