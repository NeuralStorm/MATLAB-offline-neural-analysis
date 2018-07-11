function obj = initialize_PSTH(obj,Spikes,Reference,varargin)
% NeuroToolbox.PSTHToolbox.PSTH.initialize_PSTH: Initialize a PSTH object
%
%   Proxy constructor method - keeps computations outside the class
%   definition file. The constructor method
%   NeuroToolbox.PSTHToolbox.PSTH.PSTH passes all of its input arguments to
%   this method and then returns the object this method returns.
%
%   The class 'PSTH' is the basis of the general-purpose PSTH toolkit
%   developed by Mike Meyers. It contains information about the names and
%   number of units, names and number of event types, the bins, the PSTH
%   itself, and the binned trials
%
%
%   Prototype function call to the constructor:
%
%   P = NeuroToolbox.PSTHToolbox.PSTH(Spikes, Reference, 'Parameter1_Name', Parameter1_Value, ...);
%
%   Outputs:
%
%       'P' - An initialized PSTH object. For information on the PSTH class,
%       type 'help NeuroToolbox.PSTHToolbox.PSTH'
%
%   Inputs:
%
%       'Spikes' - a cell array in which each row corresponds to a unit. The
%       first column is the unit name, and the second column contains arrays of
%       spike times (the shape of the contents does not matter). Any columns
%       past the third are ignored. Empty arrays are supported in the second
%       column to indicate that a cell did not fire at all during a recording.
%
%       'Reference' - a cell array in which each row corresponds to an event
%       type. The first column is the event name and the second column contains
%       an arrays of reference times to which the spike times in 'Spikes' will
%       be compared (the shape of the contents does not matter). Any columns
%       past the third are ignored. Event types which have no corresponding
%       timestamps (i.e. empty arrays in the second column) are ignored.
%
%       If either 'Spikes' or 'Reference' is not a cell array, it will be
%       treated as the contents of the first row, i.e. that all times listed
%       originate from the same unit or event. The name will be either
%       'Sig001a' for Spikes or 'Event001' for Reference.
%
%       This function supports parameter-value pair inputs, i.e. it should be
%       called using the following syntax:
%       PSTH(Spikes,References,'Parameter1_name',Parameter1_value,'Parameter2_name',Parameter2_value,...);
%
%       The following is a list of all possible parameters:
%
%           'PreTime' - Time (in seconds) relative to the reference at which
%           the PSTHs begin. Default is -0.2
%
%           'PostTime' - Time (in seconds) relative to the reference at which
%           the PSTHs end. Default is 0.2. If the difference
%           between window(1) and PostTime is not an integer
%           multiple of BinSize, then the PSTHs end at the
%           first bin which has an upper edge exceeding
%           PostTime.
%
%           'BinSize' - Size (in seconds) of the bins to use when generating
%           the PSTH. Default is 0.05
%
%           'Units' - Units in which to return PSTH. 'Probability' returns PSTH
%           in spike count units (i.e. total spikes in bin / number of trials).
%           'Rate' returns PSTH in firing rate units of spikes/second (i.e.
%           total spikes in bin / (number of trials * bin size) ). Default is
%           'Count'
%
%           'ShowProgress' - A logical value. If true, a
%           loading bar is displayed, otherwise the PSTH is
%           generated without any output to the user. Default
%           is false.
%
%           'DownsampleEvents' - The factor by which to downsample event
%           timestamps (e.g. if there are four timestamps per trial
%           corresponding to different phases). Default is 1 (no
%           downsampling)
%
%           'TruncateLastBin' - FOR DEBUGGING USE ONLY: When
%           this parameter is set to true, the last bin is
%           truncated at PostTime, rather than extending past
%           PostTime to the end of the bin. A warning is issued
%           to discourage regular use of this setting. Note:
%           This produces nonuniform binsizes, and will give
%           incorrect values when 'Units' is set to 'Rate'
%
% See also NeuroToolbox.PSTHToolbox.PSTH NeuroToolbox.PSTHToolbox.TemplateSet


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% First few lines are error checking   %%%%%%
%%%%%% Scroll down to another comment block %%%%%%
%%%%%% Like this one for the algorithm      %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check output arguments. Don't waste time if none, error if too many.
if nargout<1
    return;
elseif nargout>1
    exception = MException('NeuroToolbox:PSTHToolbox:PSTH:initialize_PSTH:UnknownOutputArgs','Too many output arguments. Output is an initialized PSTH object. For help, type ''help NeuroToolbox.PSTHToolbox.PSTH''.\n');
    throw(exception);
end

% Check whether all options are valid. If not, throw an
% exception
validOptions = {'ignore','PSTH_window','bin_size','Units','truncate_last_bin','show_progress','downsample_events','max_PunishRate'};
validOptionClasses = {'cellstr','numeric','numeric','char','logical','logical','numeric','numeric'};
validOptionAttributes = {{},{'real','numel',2,'increasing'},{'real','positive','scalar'},{'Count','Rate'},{},{},{'real','positive','scalar','integer'},{'real','positive','scalar'}};
defaultOptionValues = {{},[-0.2,0.2],0.05,'Count',false,false,1,0.3};
[err,msg] = NeuroToolbox.parse_arguments(validOptions,validOptionClasses,validOptionAttributes,defaultOptionValues,varargin);
if err
    id = ['NeuroToolbox:PSTHToolbox:PSTH:InvalidOptions',num2str(err)];
    msg = [msg,'\nFor more information on options, type ''help NeuroToolbox.PSTHToolbox.PSTH'''];
    exception = MException(id,msg);
    throw(exception);
end

% Store original inputs
obj.Spikes = Spikes;
obj.Reference = Reference;
Mask = strcmpi('show_progress',varargin);
Mask( find(Mask) + 1) = 1;
Mask2 = strcmpi('downsample_events',varargin);
Mask2( find(Mask2) + 1) = 1;
Mask = Mask | Mask2;
varargin = varargin(~Mask);
obj.PSTH_Parameters = varargin;


% Parse input data
[Spikes,Reference] = NeuroToolbox.parse_spike_ref(Spikes,Reference);

% Remove any reference events with no timestamps
empty_Reference_Mask = cellfun(@isempty,Reference(:,2));
Reference = Reference(~empty_Reference_Mask,:);

% Remove any ignored units
ignored_Units_Mask = ismember(lower(Spikes(:,1)),lower(ignore));
Spikes = Spikes(~ignored_Units_Mask,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% PSTH Algorithm %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Call to make_PEM
[PEM,bin_edges,unit_names,unit_key,event_names,event_key] = ...
    obj.make_PEM(Spikes,Reference,'PEM_window',PSTH_window,'bin_size',bin_size,...
    'ignore',ignore,'truncate_last_bin',truncate_last_bin,...
    'show_progress',show_progress,'downsample_events',downsample_events);
    
    % Average bins across trials to produce PSTH
    if numel(event_key)>1
        PSTHArray = grpstats(PEM,event_key);
    else
        PSTHArray = PEM;
    end
    
    % Convert to firing rate units if option is selected
    if strcmpi(Units,'rate')
        PSTHArray = PSTHArray/bin_size;
        PEM = PEM/bin_size;
    end
    
    % Initialize the PSTH object to contain the PSTH array, bin edges, number
    % of units, number of event types, and array of trials.
    obj.num_Units = numel(Spikes);
    obj.num_Events = numel(Reference);
    obj.bin_Size = bin_size;
    obj.window = PSTH_window;
    obj.bin_Edges = bin_edges;
    obj.PSTH_Array = PSTHArray;
    obj.Single_Trial_Responses = PEM;
    obj.event_key = event_key;
    obj.unit_key = unit_key;
    obj.unit_Names = unit_names;
    obj.event_Names = event_names;
    obj.PSTH_Units = Units;
    obj.Ignoring = ignore;
    obj.max_PunishRate=max_PunishRate;

end