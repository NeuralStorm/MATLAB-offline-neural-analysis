classdef DecoderOutput < handle
    % NeuroToolbox.DecoderOutput: DecoderOutput class for the NeuroToolbox Package
    %
    %   The class 'DecoderOutput' of the NeuroToolbox ...
    %
    %   Properties:
    %
    %       'NeuroToolbox.DecoderOutput.Decision' - The decision of the
    %       decoder (in what format)
    %
    %       'NeuroToolbox.DecoderOutput.Template_EventNames' - The list of
    %       event names in the template dataset. Used when computing the
    %       confusion matrix.
    %
    %       'NeuroToolbox.DecoderOutput.Event' - The event that truly
    %       occurred (in what format)
    %
    %       'NeuroToolbox.DecoderOutput.Classified_EventNames' - The list
    %       of event names in the dataset that was classified. Used when
    %       computing the confusion matrix.
    %
    %       'NeuroToolbox.DecoderOutput.Classification_Parameter' - The
    %       matrix of the parameters used for classification. Rows
    %       represent trials and columns represent events in the template
    %       set (correspond to the values in 'Template_EventNames'.
    %
    %       'NeuroToolbox.DecoderOutput.Classification_Parameter_Name' - A
    %       string containing the name of the classification parameters.
    %
    %       'NeuroToolbox.DecoderOutput.Algorithm_Name' - A string
    %       containing the name of the algorithm used to perform
    %       classification.
    %
    %   Methods:
    %
    %       NeuroToolbox.DecoderOutput.DecoderOutput - Class Constructor
    %       Returns an initialized DecoderOutput object.
    %
    %           Prototype function call: PLACE PROTOTYPE CALL HERE
    %
    %           For help specific to using the constructor method, type:
    %           'help NeuroToolbox.DecoderOutput.DecoderOutput'
    %
    %       NeuroToolbox.DecoderOutput.generate_ConfMat...
    %       Rec Field Analysis...
    %       Performance...
    %
    % See also NeuroToolbox.DecoderOutput.DecoderOutput,
    % NeuroToolbox.PSTHToolbox.TemplateSet,
    % NeuroToolbox.PSTHToolbox.TemplateSet.classify
    
    properties (SetAccess = private)
        Spike_Times; % The raw spike timestamps in the standard 'NeuroToolbox Format' (see NeuroToolbox.PLX_to_ToolboxFormat)
        Event_Times; % The raw event timestamps in the standard 'NeuroToolbox Format' (see NeuroToolbox.PLX_to_ToolboxFormat)
        Decision; % The output of the classifier
        Template_EventNames; % List of the event types in the template dataset
        Event; % The event that truly occurred
        Classified_EventNames; % List of the event types in dataset that was classified
        Trial_Times; % List of the trial timestamps corresponding to each row of Decision and Event
        Classification_Parameter; % The parameter upon which classification was based (e.g. Euclidean Distance)
        Classification_Parameter_Name; % The name of the parameter upon which classification was based
        Confusion_Matrix; % The confusion matrix, must be generated using the generate_ConfMat method
        DecoderSpec; % An object containing values specifying the algorithm and parameters used to generate this output
        Decoder_Data; % Any data specific to the decoder being used that should be stored (e.g. single trial responses in a single-unit PSTH classifier)
        Max_PunishRate; % Maximum number of trials out of total trials that the rat would be punished
        PunishCount; % Number of trials the animal has been punished with punish tilts
        RewardCount; % Number of trials the animal has been rewarded with reward tilts
        WaterCount; % Number of trials the animal has been rewarded with a water reward
       
    end
    
    methods
        
        function obj = DecoderOutput(Spike_Times,Event_Times,Decision,Template_EventNames,Event,Classified_EventNames,Trial_Times,Classification_Parameter,Classification_Parameter_Name,DecoderSpec,Decoder_Data)
                    
            % NeuroToolbox.DecoderOutput.DecoderOutput: DecoderOutput class constructor
            %
            %   The class 'DecoderOutput' of the NeuroToolbox ...
            %
            %
            %   Prototype function call to the constructor:
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
            % See also NeuroToolbox.DecoderOutput,
            % NeuroToolbox.PSTHToolbox.TemplateSet,
            % NeuroToolbox.PSTHToolbox.TemplateSet.classify
        
            % Error-check input arguments
            validOptionNames = {'Spike_Times','Event_Times','Decision','Template_EventNames','Event',...
                'Classified_EventNames','Trial_Times','Classification_Parameter',...
                'Classification_Parameter_Name','DecoderSpec'};
            validOptionClass = {'cell','cell','cellstr','cellstr','cellstr','cellstr',...
                'numeric','numeric','char','NeuroToolbox.DecoderSpec',...
                };
            validOptionAttributes = {{},{},{},{},{},{},{'real'},{},{},{}};
            defaultDSObj = NeuroToolbox.DecoderSpec(0,0,0,0,0,0);
            defaultOptionVals = {{1},{1},{'a'},{'a'},{'a'},{'a'},1,1,'a',defaultDSObj}; % These all get ignored b/c inputs includes all variables
            vals = cellfun(@eval,validOptionNames,'UniformOutput',false);
            inputs = [validOptionNames;vals];
            inputs = inputs(:);
            [err,msg] = NeuroToolbox.parse_arguments(validOptionNames,...
                validOptionClass,validOptionAttributes,defaultOptionVals,inputs);
            if err
                id = 'NeuroToolbox:DecoderOutput:invalid_option';
                ME = MException(id,msg);
                throw(ME);
            end
            
            % Make sure classified event types match input event types
            if ~all(ismember(lower(Event_Times(:,1)),lower(Classified_EventNames)))
                % This error is weird.... this whole thing is weird (having
                % event types in two different places)..... work on this
                id = 'NeuroToolbox:PSTHToolbox:DecoderOutput:Error_EventNames';
                msg = 'Error with event names... see line 113 of DecoderOutput.m';
                ME = MException(id,msg);
                throw(ME);
            end
            
            % Store inputs in class properties
            obj.Spike_Times = Spike_Times;
            obj.Event_Times = Event_Times;
            obj.Decision = Decision;
            obj.Template_EventNames = Template_EventNames;
            obj.Event = Event;
            obj.Classified_EventNames = Classified_EventNames;
            obj.Trial_Times = Trial_Times;
            obj.Classification_Parameter = Classification_Parameter;
            obj.Classification_Parameter_Name = Classification_Parameter_Name;
            obj.DecoderSpec = DecoderSpec;
            obj.Confusion_Matrix = [];
            obj.Decoder_Data = Decoder_Data;
            obj.Max_PunishRate=[]; 
            obj.PunishCount=[];
            obj.RewardCount=[];
            obj.WaterCount=[];
            
        end
        generate_ConfMat(obj)
        sort_byTrialTime(obj)
        merge(obj,in)
        reward_punishRate(obj,PunishCount,RewardCount,WaterCount,...
                    Max_PunishRate)
        DO = append(obj,Spikes,Reference,classifier_decision,...
            template_event_names,true_event,event_names,...
            trial_times,classification_parameter,...
            classification_parameter_name,DS,decoder_data,punishCount,...
            rewardCount,waterCount)
    end
    
end

