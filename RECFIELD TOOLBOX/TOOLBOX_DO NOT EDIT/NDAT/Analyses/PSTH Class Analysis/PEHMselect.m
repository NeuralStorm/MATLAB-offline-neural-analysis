function [ PEHM_select,Group_select] = PEHMselect(filename,trials,PEHM,Group)
%UNTITLED2 Summary of this function goes here
%   This function creates new PEHM based on user defined trials
% filename-filename of file currently being analyzed
% trials- array of user-specified trials to create outputs from
% PEHM-perievent matrix to extract trials from 



% load event timestamps
load(filename,'-mat','Events');

% extract event channels 
events=unique(Group);

% sort event timestamps ascending
[~,groupInd]=sort(vertcat(Events(events).ts));

% PEHM with select trials only
PEHM_select=PEHM(groupInd(trials),:);

% Group with select trials only 
Group_select=Group(groupInd(trials),:);

end

