function DO = classify(obj,Spikes,Reference,varargin)
% THIS VERSION OF THIS FUNCTION IS FOR THE PURPOSES OF NATE'S PRELIMINARY
% DATA ANALYSIS ONLY. THE OUTPUT SHOULD BE CLEANED UP AND THE FUNCTION'S
% DOCUMENTATION NEEDS TO BE WRITTEN
%
% 'Classifier_Decision', 'True_Event' and 'Euclidean_Distances'
%       Each row corresponds to a trial (or if BatchMode is off, an average
%       response to a reference type). 'Classifier_Decision' and
%       'True_Event' are what they say. They are cell arrays containing the
%       name of the event. 'Euclidean_Distances' has (num_template_events)
%       columns, and gives the euclidean distance from the trial/average
%       response to the template for the event named in the corresponding
%       column of 'Template_Event_Names'
%
% call it like this:
% DO = X.classify(Spikes,Reference,'BatchMode',true,'SameDataset',true,'DistanceMethod','euclidean');
%
% If BatchMode is set to true, then inputs with more than one reference
% event will be classified on a trial-by-trial basis. If false, then the
% average response to each reference event type is calculated, and then the
% average response is classified.
%
% SameDataset should be set to true if you are classifying the
% trials of the dataset used to compute the templates. Before computing the
% Euclidean distances, it removes the trial from its corresponding
% template.
%
% DistanceMethod is the method to use when computing distance. Default is
% euclidean. 
%
% NOTE TO SELF: use pdist to compute distance differently and add a
% 'distance type' parameter - done 2/20/15
%
% ANOTHER NOTE: Add the option to remove the current trial from the
% template (if the template contains current trial. Need a switch for this)
% done 2/20/15

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if options input are valid. If not, throw an exception
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    validOptions = {'BatchMode','SameDataset','DistanceMethod','showProgress','DownsampleEvents','append_to'};
    validOptionClasses = {'logical','logical','char','logical','numeric',{'NeuroToolbox.DecoderOutput','logical'}};
    validDistMethods = {'euclidean','seuclidean','cityblock','minkowski',...
        'chebychev','mahalanobis','cosine','correlation','spearman',...
        'hamming','jaccard'};
    validOptionAttributes = {{},{},validDistMethods,{},{'positive','scalar','real','integer'},{}};
    defaultOptionVals = {true,false,'euclidean',false,1,false};
    [err,msg] = NeuroToolbox.parse_arguments(validOptions,validOptionClasses,validOptionAttributes,defaultOptionVals,varargin);
    if err
        id = ['NeuroToolbox:PSTHToolbox:TemplateSet:classify:InvalidOptions',num2str(err)];
        msg = [msg,'\nFor more information on options, type ''help NeuroToolbox.PSTHToolbox.TemplateSet.classify'''];
        exception = MException(id,msg);
        throw(exception);
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse input data and match units to template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [Spikes,Reference] = NeuroToolbox.parse_spike_ref(Spikes,Reference,'match_units',obj.TemplateSource.Spikes);

    % Remove any reference events with no timestamps
    empty_Reference_Mask = cellfun(@isempty,Reference(:,2));
    Reference = Reference(~empty_Reference_Mask,:);
    
    % Remove any ignored units
    ignored_Units_Mask = ismember(lower(Spikes(:,1)),lower(obj.TemplateSource.Ignoring));
    Spikes = Spikes(~ignored_Units_Mask,:);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate a PEM and PSTH from the data to be classified. The PEM or the
% PSTH will be compared with the current templates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    try
        % If templates truncated last bin, then so should trials classified
        options = obj.TemplateSource.PSTH_Parameters;
        tlb_exist = intersect(options(1:2:end),{'truncate_last_bin'});
        if ~isempty(tlb_exist);
            truncate_last_bin = options{find(strcmp(options,'truncate_last_bin'))+1};
        else
            truncate_last_bin = false;
        end
        
        % Compute the PEM to be classified
        [PEM,bin_edges,unit_names,unit_key,event_names,event_key] = ...
            obj.TemplateSource.make_PEM(Spikes,Reference,...
            'PEM_window',obj.TemplateSource.window,...
            'bin_size',obj.TemplateSource.bin_Size,...
            'ignore',obj.TemplateSource.Ignoring,...
            'truncate_last_bin',truncate_last_bin,...
            'show_progress',showProgress,...
            'downsample_events',DownsampleEvents);
        
        % Average bins across trials to produce PSTH
        if numel(event_key)>1
            input_PSTH_array = grpstats(PEM,event_key);
        else
            input_PSTH_array = PEM;
        end
        
    catch exception
        % Relay any errors in creating the PEM and PSTH from the data to be classified.
        rethrow(exception);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize a key for the euclidean distance columns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Template_Event_Names = obj.TemplateSource.event_Names';

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract data to classify
%%%%%%%%%%%%%%%%%%%%%%%%%%

    % If BatchMode is on, a 'trial' is defined as a single trial
    if BatchMode
        getTrialSet = @(EvType)(PEM(event_key==EvType,:));
        getRow = @(Array,row)(Array(row,:));
        getTrial = @(EvType,Trial)(getRow(getTrialSet(EvType),Trial));
        getNumTrial_byEvType = @(EvType)(sum(event_key==EvType));
        
    % If BatchMode is off, a 'trial' is defined as the average response to
    % an event type
    elseif ~BatchMode
        getTrialSet = @(EvType)(input_PSTH_array(EvType,:));
        getTrial = @(EvType,Trial)(getTrialSet(EvType));
        getNumTrial_byEvType = @(EvType)(1);
        
    end

%%%%%%%%%%%%%%%%%%%
% Classify the data
%%%%%%%%%%%%%%%%%%%

    % Initialize a trial counter
    trialnum = 1;
    
    % Initialize the trial timestamp array
    trial_times = [];

    % Initialize the progress bar
    if showProgress
        totalTrials = 0;
        for input_Event_Type = 1:numel(event_names)
            totalTrials = totalTrials + getNumTrial_byEvType(input_Event_Type);
        end
        msg = sprintf('Classifying trial %d/%d',0,totalTrials);
        progBar = waitbar(0,msg,'CloseRequestFcn',@(varargin)(0));
    end
    
    try % Error catching so progress bar can be deleted if an error is encountered
    
    % For each input reference event type
    for input_Event_Type = 1:numel(event_names)
        numTrials = getNumTrial_byEvType(input_Event_Type);
        

        % For each trial
        for trial = 1:numTrials
            
            % Find the time of this trial
            RefLoc = find(strcmpi(event_names{input_Event_Type},Reference(:,1)),1,'first');
            trial_times(trialnum,1) = Reference{RefLoc,2}((trial-1)*DownsampleEvents+1);

            % Get this trial's spike counts and initialize the new row
            % of the distance array for this trial
            trial_Response = getTrial(input_Event_Type,trial);
            Distances(trialnum,:)=zeros(1,size(obj.TemplateSource.PSTH_Array,1));

            % For each template reference event type
            for Template_Event_Type = 1:size(obj.TemplateSource.PSTH_Array,1)

                % Get the template for this event type
                template = obj.TemplateSource.PSTH_Array(Template_Event_Type,:);
                
                % If 'SameDataset' is on and the current
                % trial is a trial of the same type as the template, then
                % remove the trial from the template.
                if SameDataset && Template_Event_Type == input_Event_Type
                    template = (template - (trial_Response/numTrials)) * numTrials/(numTrials-1);
                end
                
                % Compute the distance metric
                Distance = pdist([template;trial_Response],DistanceMethod);
                Distances(trialnum,Template_Event_Type) = Distance;
            end

            % And classify the trial based on the minimum distance
            [~,classification_index] = min(Distances(trialnum,:));
            Classifier_Decision(trialnum,1) = Template_Event_Names(classification_index);

            % Also return the true event name
            True_Event(trialnum,1) = event_names(input_Event_Type);

            % Increment trial counter
            trialnum = trialnum+1;
            
            % Update the progress bar
            if showProgress
                msg = sprintf('Classifying trial %d/%d',trialnum,totalTrials);
                waitbar(trialnum/totalTrials,progBar,msg);
            end
            
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Construct/Merge Decoder Output object to be returned
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isa(append_to,'NeuroToolbox.DecoderOutput')
        % create new DO
        % Decoder Spec object
        DS = NeuroToolbox.DecoderSpec(obj,BatchMode,...
            obj.TemplateSource.Ignoring,...
            SameDataset,DistanceMethod,DownsampleEvents);
        % Decoder Output object
        DO = NeuroToolbox.DecoderOutput(Spikes,Reference,...
            Classifier_Decision,Template_Event_Names,...
            True_Event,event_names',trial_times,...
            Distances,DistanceMethod,DS,PEM);
    else
        % append trial to DO
        DO = append_to.append(Spikes,Reference,Classifier_Decision,...
            Template_Event_Names,True_Event,event_names',trial_times,...
            Distances,DistanceMethod,[],PEM);
    end

    % Delete the progress bar
    if showProgress
        delete(progBar)
        clear progBar
    end
    
    catch ME % If an error does occur, report it in the progress bar and relay the exception
        if showProgress
            set(progBar,'CloseRequestFcn',@(varargin)(delete(gcf)));
            waitbar(0,progBar,'ERROR');
        end
        rethrow(ME)
    end
    
end