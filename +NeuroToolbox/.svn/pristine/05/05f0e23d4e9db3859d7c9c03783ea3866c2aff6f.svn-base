function obj = change_ignore(obj,new_ignore,varargin)

% Check whether all options are valid. If not, throw an exception
validOptions = {'show_progress'};
validOptionClasses = {'logical'};
validOptionAttributes = {{}};
defaultOptionValues = {false};
[err,msg] = NeuroToolbox.parse_arguments(validOptions,validOptionClasses,validOptionAttributes,defaultOptionValues,varargin);
if err
    id = ['NeuroToolbox:PSTHToolbox:PSTH:change_ignore:InvalidOptions',num2str(err)];
    msg = [msg,'\nFor more information on options, type ''help NeuroToolbox.PSTHToolbox.PSTH.change_ignore'''];
    exception = MException(id,msg);
    throw(exception);
end

% Find the original 'ignore' argument (if any)
args = obj.PSTH_Parameters;
Mask = strcmpi('ignore',args);

% and replace it
if any(Mask)
    args{find(Mask)+1} = new_ignore;
else
    args{end+1} = 'ignore';
    args{end+1} = new_ignore;
end

% append current 'show progress' argument
args{end+1} = 'show_progress';
args{end+1} = show_progress;

% Reinitialize and return the PSTH object
obj = obj.initialize_PSTH(obj.Spikes,obj.Reference,args{:});