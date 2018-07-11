classdef PSTH
    % NeuroToolbox.PSTHToolbox.PSTH: PSTH Class
    %
    %   The class 'PSTH' is the basis of the general-purpose PSTH toolbox
    %   developed by Mike Meyers. It contains information about the names and
    %   number of units, names and number of event types, the bins, the PSTH
    %   itself, and the binned trials
    %
    %
    %   Properties:
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.num_Units' - the number of units for which PSTHs
    %       exist in the current PSTH object.
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.unit_Names' - the names of units for which PSTHs
    %       exist in the current PSTH object. These are in the same order they
    %       appear in 'PSTH.PSTH_Array'
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.num_Events' - the number of event types for which
    %       PSTHs exist in the current PSTH object.
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.event_Names' - the names of event types for which
    %       PSTHs exist in the current PSTH object. These are in the same order
    %       they appear in 'PSTH.PSTH_Array'
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.bin_Size' - a scalar containing the bin size in
    %       seconds
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.window' - a row vector containing two elements. The
    %       elements are the beginning and end of the PSTH window in seconds
    %       relative to the reference event.
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.bin_Edges' - a row vector containing the edges of
    %       the bins. The nth bin contains spikes from time PSTH.bin_Edges(n) to
    %       PSTH.bin_Edges(n+1).
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.PSTH_Array' - a numel(PSTH.bin_Edges) by
    %       numel(Spikes) by numel(Reference) matrix (see constructor method
    %       inputs). Each row is a bin, each column is a unit, and each page is an
    %       event type. Each element is the probability of a spike (if
    %       PSTH.PSTH_Units is 'Probability') or the instantaneous firing rate (if
    %       PSTH.PSTH_Units is 'Rate').
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.Trials_Array' - a numel(PSTH.bin_Edges) by
    %       numel(Spikes) by numel(Reference) cell array (see constructor method
    %       inputs). Each row is a bin, each column is a unit, and each page is an
    %       event type. The contents of each cell are vectors containing the number
    %       of spikes or instantaneous firing rate (depending on PSTH.PSTH_Units)
    %       for each trial.
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.PSTH_Units' - A character string indicating the
    %       units of the values in 'PSTH.PSTH_Array' and 'PSTH.Trials_Array'. Can
    %       have one of two values: 'Probability', meaning that values in the
    %       arrays represent probability of a spike during the bin, or 'Rate',
    %       meaning that values in the arrays represent the instantaneous firing
    %       rate.
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.ICA' -  Logical. If true, the PSTH_Array and Single_Trial_Responses represent ICs instead of single-units
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.ICA_Ignore' -  Cell array of strings of unit names that were ignored while computing ICs
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.numcomp' - Integer. Number of ICs computed. Zero means # selected automatically
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.extended' - Logical. If true, uses "Extended ICA" (only applies when ICA is also true)
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.normalizePEM' - Logical. If true, the perievent matrix was normalized before computing ICs
    %
    %       'NeuroToolbox.PSTHToolbox.PSTH.smoothPEM' - Logical. If true, the perievent matrix was smoothed before computing ICs (and before normalization, if selected)
    %
    %
    %   Methods:
    %
    %       NeuroToolbox.PSTHToolbox.PSTH.PSTH - Class Constructor
    %       Returns an initialized PSTH object
    %
    %           Prototype function call: P = NeuroToolbox.PSTHToolbox.PSTH(Spikes, Reference, 'Parameter1_Name', Parameter1_Value, ...);
    %
    %           For help specific to using the constructor method, type: 'help
    %           NeuroToolbox.PSTHToolbox.PSTH.initialize_PSTH'
    %
    % See also NeuroToolbox.PSTHToolbox.PSTH.initialize_PSTH NeuroToolbox.PSTHToolbox.TemplateSet
    
    properties (SetAccess = private)
        Spikes; % The cell array of spike times
        Reference; % The cell array of reference event times
        PSTH_Parameters; % Saves the list of options entered after 'Spikes' and 'Reference' when creating this object. Used to ensure that trials to be classified are binned the same way as the templates. (when classifiers are used)
        
        num_Units; % Number of units in the current PSTH object
        unit_Names; % Names of units in same order as they appear in PSTH_Array
        num_Events; % Number of event types in the current PSTH object
        event_Names; % Names of events in same order as they appear in PSTH_Array
        bin_Size; % Bin size in seconds
        window; % PSTH window in seconds relative to reference
        bin_Edges; % A row vector containing the edges of the bins.
        PSTH_Array; % Matrix containing PSTHs (type 'help NeuroToolbox.PSTHToolbox.PSTH' for more)
        Single_Trial_Responses; % Matrix containing binned trials (type 'help NeuroToolbox.PSTHToolbox.PSTH' for more)
        event_key; % Column vector containing the coded event type for each row of Single_Trial_Responses (type 'help NeuroToolbox.PSTHToolbox.PSTH' for more)
        unit_key; % Row vector containing the coded unit number for each column of Single_Trial_Responses and PSTH_Array (type 'help NeuroToolbox.PSTHToolbox.PSTH' for more)
        PSTH_Units; % Units of the PSTH values (either 'Probability' or 'Firing Rate')
        Ignoring; % List of unit names that are being ignored by this object (case insensitive)        
        max_PunishRate; % Maximum ratio of punishment tilts experienced by rat over the course of the experiment  
    end
    
    methods
        function obj = PSTH(Spikes,Reference,varargin)
            % NeuroToolbox.PSTHToolbox.PSTH.PSTH: PSTH Class Constructor
            %
            % Passes all arguments to
            % NeuroToolbox.PSTHToolbox.PSTH.initialize_PSTH 
            % Proxy constructor to keep the class definition clean (there's a lot
            % of code in initialize_PSTH)
            obj = obj.initialize_PSTH(Spikes,Reference,varargin{:});
        end
        
        function Classifier = makeSU_Classifier(obj)
            % Create SU_Classifier object from PSTH
            Classifier = NeuroToolbox.PSTHToolbox.SU_Classifier(obj);
        end
        
        function Classifier = makeICA_Classifier(obj,varargin)
            % Create ICA_Classifier object from PSTH
            Classifier = NeuroToolbox.PSTHToolbox.ICA_Classifier(obj,varargin{:});
        end
        
        MNTS = getMNTS(obj,varargin)
        
        obj = change_ignore(obj,new_ignore,varargin)
        
    end
    
    methods (Static)
    
        out = smooth(matrix,samples,dim)
        out = demean(matrix,dim)
        out = normalize(matrix,dim)
        [PEM,bin_edges,unit_names,unit_key,event_names,event_key] = make_PEM(Spikes,Reference,varargin)
        MNTS = PEM_to_MNTS(PEM,unit_key)
        
    end
end