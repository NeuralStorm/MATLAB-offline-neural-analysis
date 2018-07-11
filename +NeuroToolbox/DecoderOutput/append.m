function DO = append(obj,Spikes,Reference,classifier_decision,template_event_names,true_event,...
    event_names,trial_times,classification_parameter,classification_parameter_name,...
    DS,decoder_data)

% IF DECODERSPEC OBJECTS DON'T MATCH if ~strcmp(obj.Algorithm_Name,in.Algorithm_Name)
% Throw an error
% else

% Merge the objects
obj.Decision = [obj.Decision;classifier_decision];
obj.Template_EventNames = union(obj.Template_EventNames,template_event_names);
obj.Event = [obj.Event;true_event];
obj.Classified_EventNames = union(obj.Classified_EventNames,event_names);
obj.Trial_Times = [obj.Trial_Times;trial_times];
obj.Classification_Parameter = [obj.Classification_Parameter;classification_parameter];
obj.Decoder_Data = [obj.Decoder_Data;decoder_data];
% obj.PunishCount=[obj.PunishCount;PunishCount];
% obj.RewardCount=[obj.RewardCount;RewardCount];
% obj.WaterCount=[obj.WaterCount;WaterCount];
% obj.generate_ConfMat; % No need to do this on each append...should speed
% things up some

% Find rows (in Spike_Times) that already exist in the decoder output,
% and merge input into those. Create the ones that don't yet exist
[inspikes_Exist,SpikeInds] = ismember(Spikes(:,1),obj.Spike_Times(:,1));
input_SpikeInds = find(inspikes_Exist);
for i = 1:numel(SpikeInds)
    if inspikes_Exist(i)
        obj.Spike_Times{SpikeInds(i),2} = [obj.Spike_Times{SpikeInds(i),2};Spikes{i,2}];
    end
end
obj.Spike_Times = [obj.Spike_Times;Spikes(~inspikes_Exist,:)];

% Find rows (in Event_Times) that already exist in the decoder output,
% and merge input into those. Create the ones that don't yet exist.
[inrefs_Exist,RefInds] = ismember(Reference(:,1),obj.Event_Times(:,1));
input_RefInds = find(inrefs_Exist);
for i = 1:numel(RefInds)
    if inrefs_Exist(i)
        obj.Event_Times{RefInds(i),2} = [obj.Event_Times{RefInds(i),2};Reference{i,2}];
    end
end
obj.Event_Times = [obj.Event_Times;Reference(~inrefs_Exist,:)];

DO = obj;