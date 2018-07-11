function generate_ConfMat(obj)
% NeuroToolbox.DecoderOutput.generate_ConfMat: DecoderOutput Generate_ConfMat method
%
%   The class 'DecoderOutput' of the NeuroToolbox ...
%
%
%   Prototype function call:
%
%   PLACE PROTOTYPE CALL HERE
%
%   Outputs:
%
%       PLACE OUTPUTS HERE
%
%   Inputs:
%
%       PLACE INPUTS HERE
%
% See also 

% Get a coded decision and a key. Merge key with list of all template event
% types.
[DecisionKey,~,CodedDecision] = unique(lower(obj.Decision));
MergedDecisionKey = union(lower(obj.Template_EventNames),DecisionKey,'stable');
[~,MergedCodedDecision] = ismember(DecisionKey(CodedDecision),MergedDecisionKey);

% Get a coded event and a key. Merge key with list of all template event
% types.
[EventKey,~,CodedEvent] = unique(lower(obj.Event));
MergedEventKey = union(lower(obj.Template_EventNames),EventKey,'stable');
[~,MergedCodedEvent] = ismember(EventKey(CodedEvent),MergedEventKey);

if numel(MergedDecisionKey)>numel(DecisionKey)
    % Throw an error (the decoder output an event name that was not
    % included in the 'Template_EventNames' array)
end

% Generate the confusion matrix
subs = [MergedCodedEvent,MergedCodedDecision];
vals =ones(size(subs,1),1);
ConfMat = accumarray(subs,vals,[numel(MergedEventKey),numel(MergedDecisionKey)]);

% Compute totals & concatenate
ConfMat(:,end+1) = sum(ConfMat,2);
ConfMat(end+1,:) = sum(ConfMat,1);
MergedEventKey(end+1) = {'Total'};
MergedDecisionKey(end+1) = {'Total'};

% If all event types match, get accuracy
if isempty(setdiff(lower(MergedDecisionKey),lower(MergedEventKey)))
    
    % Row and columnwise accuracies
    RowAcc = diag(ConfMat)./ConfMat(:,end);
    RowAcc(end) = 0;
    ColAcc = diag(ConfMat)'./ConfMat(end,:);
    ColAcc(end) = 0;
    
    % Overall performance
    TotalCorrectTrials = sum(diag(ConfMat(1:end-1,1:end-1)));
    TotalTrials = ConfMat(end,end);
    OverallPerformance = TotalCorrectTrials/TotalTrials;
    
    % Concatenate arrays
    ConfMat(:,end+1) = RowAcc;
    ConfMat(end+1,:) = [ColAcc,OverallPerformance];
    
    % Add column and row labels
    MergedEventKey(end+1) = {'Accuracy'};
    MergedDecisionKey(end+1) = {'Accuracy'};
end

% Populate the object with the confusion matrix
output = mat2dataset(ConfMat,'ObsNames',MergedEventKey,'VarNames',MergedDecisionKey);
obj.Confusion_Matrix = output;