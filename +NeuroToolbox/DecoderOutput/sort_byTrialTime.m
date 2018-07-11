function sort_byTrialTime(obj)
% NeuroToolbox.DecoderOutput.sort_byTrialTime: DecoderOutput trial sorting method
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

% Sort the trial times and get the indices for reorganizing other data
[obj.Trial_Times,inds] = sort(obj.Trial_Times);

% Sort the rest of the data by trial times
obj.Decision = obj.Decision(inds);
obj.Event = obj.Event(inds);
obj.Classification_Parameter = obj.Classification_Parameter(inds,:);
obj.Decoder_Data = obj.Decoder_Data(inds,:);

end