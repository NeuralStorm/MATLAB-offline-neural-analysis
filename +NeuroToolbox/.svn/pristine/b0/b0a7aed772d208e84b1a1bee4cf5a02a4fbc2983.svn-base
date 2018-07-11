function updatetemplates(obj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Put this into an 'applyweights' or 'updatetemplates' method
% Create the ICA templates by applying the weights to the templates...maybe
% put this in its own method for reuse when classifying...
obj.ICA_Array = obj.apply_weights(obj.ICAWeights,obj.TemplateSource.PSTH_Array);
obj.Single_Trial_ICA = obj.apply_weights(obj.ICAWeights,obj.TemplateSource.Single_Trial_Responses);

% Create a key for the ICA array.
obj.IC_Key = 1:size(obj.ICA_Array,2)/(numel(obj.TemplateSource.bin_Edges)-1);
obj.IC_Key = repmat(obj.IC_Key,numel(obj.TemplateSource.bin_Edges)-1,1);
obj.IC_Key = obj.IC_Key(:)';
obj.IC_Names = cellstr(strcat(repmat('IC',max(obj.IC_Key),1),num2str([1:max(obj.IC_Key)]')));

end

