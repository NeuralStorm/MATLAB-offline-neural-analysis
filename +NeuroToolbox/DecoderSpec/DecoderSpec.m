classdef DecoderSpec
% CLASS DOCUMENTATION GOES HERE
%
% Note: This class right now is specific to the
% NeuroToolbox.PSTHToolbox.TemplateSet objects. Generalize it.
    
    properties (SetAccess = private)
        Template;
        BatchMode
        Ignore;
        SameDataset;
        DistanceMethod;
        DownsampleEvents;
    end
    
    methods
        function obj = DecoderSpec(Template,BatchMode,Ignore,SameDataset,DistanceMethod,DownsampleEvents)
            % CONSTRUCTOR DOCUMENTATION GOES HERE
            
            obj.Template = Template;
            obj.BatchMode = BatchMode;
            obj.Ignore = Ignore;
            obj.SameDataset = SameDataset;
            obj.DistanceMethod = DistanceMethod;
            obj.DownsampleEvents = DownsampleEvents;
        end
    end
    
end

