classdef ICA_Classifier < handle
    % NeuroToolbox.PSTHToolbox.TemplateSet: TemplateSet class
    %
    %   The class 'TemplateSet' is a subclass of the 'PSTH' class in the
    %   general-purpose PSTH toolbox developed by Mike Meyers. It has the
    %   same properties as the 'PSTH' class. Because the properties of the
    %   'PSTH' class have the setaccess attribute set to private, methods of
    %   the TemplateSet class cannot modify their values. They are set by the
    %   class constructor. For more information on the 'PSTH' class, type
    %   'help NeuroToolbox.PSTHToolbox.PSTH'
    %
    %   The purpose of the 'TemplateSet' class is to add the method
    %   'TemplateSet.classify', which classifies a trial (or set of trials)
    %   into one of the event types used to construct the object.
    %
    %   To generate a template set, call the TemplateSet class constructor
    %   using the following syntax:
    % 
    %   T = NeuroToolbox.PSTHToolbox.TemplateSet(Spikes,Reference,'Option1_Name',Option1_Val,'Option2_name',...);
    %           For more information on the inputs, see the PSTH class
    %           constructor help page 'help NeuroToolbox.PSTHToolbox.PSTH.PSTH'
    % 
    %   T is now a set of templates based on the data in 'Spikes' and
    %   'Reference' 
    % 
    %   Trials can be classified using the template set T using the following
    %   syntax:
    % 
    %   Classification = T.classify(ARGS)
    %
    %   DESCRIBE ARGS HERE
    %
    %   The classifier generates the binned trials for the inputs, and
    %   determines the euclidean distance (i.e. RMS error) between each
    %   trial and each template. Each trial is then classified as the event
    %   type of the template to which it is closest (least euclidean
    %   distance/RSS error). 
    % 
    % See also NeuroToolbox.PSTHToolbox.TemplateSet.classify,
    % NeuroToolbox.PSTHToolbox.PSTH

    
    properties (SetAccess = private)
        TemplateSource; % A copy of the PSTH object from which this classifier was built
        ICAWeights; % The ICA Weights structure
        ICA_Array; % TemplateSource.PSTH_Array, transformed into ICA space
        Single_Trial_ICA; % TemplateSource.Single_Trial_Responses transformed into ICA space
        IC_Key; % A row vector of length size(Single_Trial_ICA,2), coding which IC each column in Single_Trial_ICA belongs to
        IC_Names; % A cell array of IC names (IC_Key corresponds to element #)
    end
    
    methods
        
        % Constructor method - calls PSTH constructor. Saves options for
        % later use when creating a temporary PSTH object for trials to be
        % classified
        function obj = ICA_Classifier(TemplateSource,varargin)
            
            % Save the PSTH object this Classifier was built from
            obj.TemplateSource=TemplateSource;
            
            % Generate the ICA weights
            obj.getWeights(varargin{:});
            
            % Apply the weights to the templates
            obj.updatetemplates;
        end
        
        % Signature of the classify method. Uses 'smallest euclidean
        % distance' criterion to classify a trial or set of trials in terms
        % of the templates available in the current 'TemplateSet' object.
        DO = classify(obj,Spikes,Reference,varargin)
        
        getWeights(obj,varargin)
        updatetemplates(obj)
        
    end
    
    methods (Static)
        Weighted_PEM = apply_weights(W,PEM)
    end
    
end