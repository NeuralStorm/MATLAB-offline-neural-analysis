function merge(obj,in)
% NeuroToolbox.DecoderOutput.Merge: DecoderOutput Merge method
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

% IF DECODERSPEC OBJECTS DON'T MATCH if ~strcmp(obj.Algorithm_Name,in.Algorithm_Name) 
    % Throw an error
% else
    % Merge the objects
    obj.Decision = [obj.Decision;in.Decision];
    obj.Template_EventNames = union(obj.Template_EventNames,in.Template_EventNames);
    obj.Event = [obj.Event;in.Event];
    obj.Classified_EventNames = union(obj.Classified_EventNames,in.Classified_EventNames);
    obj.Trial_Times = [obj.Trial_Times;in.Trial_Times];
    obj.Classification_Parameter = [obj.Classification_Parameter;in.Classification_Parameter];
    obj.Decoder_Data = [obj.Decoder_Data;in.Decoder_Data];
    obj.generate_ConfMat;
    
    % Find rows (in Spike_Times) that already exist in the decoder output,
    % and merge input into those. Create the ones that don't yet exist
    [inspikes_Exist,SpikeInds] = ismember(in.Spike_Times(:,1),obj.Spike_Times(:,1));
    input_SpikeInds = find(inspikes_Exist);
    for i = 1:numel(SpikeInds)
        if inspikes_Exist(i)
            obj.Spike_Times{SpikeInds(i),2} = [obj.Spike_Times{SpikeInds(i),2};in.Spike_Times{i,2}];
        end
    end
    obj.Spike_Times = [obj.Spike_Times;in.Spike_Times(~inspikes_Exist,:)];
    
    % Find rows (in Spike_Times) that already exist in the decoder output,
    % and merge input into those. Create the ones that don't yet exist.
    [inrefs_Exist,RefInds] = ismember(in.Event_Times(:,1),obj.Event_Times(:,1));
    input_RefInds = find(inrefs_Exist);
    for i = 1:numel(RefInds)
        if inrefs_Exist(i)
            obj.Event_Times{RefInds(i),2} = [obj.Event_Times{RefInds(i),2};in.Event_Times{i,2}];
        end
    end
    obj.Event_Times = [obj.Event_Times;in.Event_Times(~inrefs_Exist,:)];
    
end