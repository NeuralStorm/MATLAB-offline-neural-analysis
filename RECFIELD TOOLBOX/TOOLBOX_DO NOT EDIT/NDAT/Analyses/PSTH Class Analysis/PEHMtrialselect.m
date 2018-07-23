function [ PEHM_select,Group_select] = PEHMtrialselect(filename,trials,PEHM,Group,options)
%UNTITLED2 Summary of this function goes here
%   This function creates new PEHM based on user defined trials
% filename-filename of file currently being analyzed
% trials- array of user-specified trials to create outputs from
% PEHM-perievent matrix to extract trials from



% load event timestamps
load(filename,'-mat','Events');

if isempty(Group)
    Group=options.CurrentEvents;
end

% extract event channels
[events,firstEvtInd,evtRows]=unique(Group);



if isfield(options,'trialsWithinEvent') && options.trialsWithinEvent
    %if select trials are within each event
    
    % find minimum number of trials
    noTrialsPerEvent_min=min(sum(events'==evtRows));
    
    % create matrix representing number of trials for each tilt type 
    trialMatrix=(repmat(firstEvtInd',noTrialsPerEvent_min,1)-1)+(1:noTrialsPerEvent_min)';
    
    % select user-specified trials for each tilt type 
    selectTrials=trialMatrix(trials',:);
    
    % create logical array to extract relevant trials 
    selectTrialLogical=false(length(evtRows),1);
    selectTrialLogical((selectTrials(:)),1)=true;
    
    % PEHM with select trials only
    PEHM_select=PEHM(selectTrialLogical,:);
    
    
    % Group with select trials only
    Group_select=Group(selectTrialLogical,:);
else
    %if select trials are within the entire experiment
    
    % sort event timestamps ascending
    [~,groupInd]=sort(vertcat(Events(events).ts));
    
    % PEHM with select trials only
    PEHM_select=PEHM(groupInd(trials),:);
    
    % Group with select trials only
    Group_select=Group(groupInd(trials),:);
    
end

end

