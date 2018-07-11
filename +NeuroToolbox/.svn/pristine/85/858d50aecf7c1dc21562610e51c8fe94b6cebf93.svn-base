classdef SU_Classifier
    %SU_CLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        TemplateSource; % A copy of the PSTH object from which this classifier was built
    end
    
    methods
        
        % Constructor function
        function obj = SU_Classifier(TemplateSource)
            obj.TemplateSource=TemplateSource;
        end
        
        % Signature of the classify method.
        DO = classify(obj,Spikes,Reference,varargin)
        
    end
    
end

