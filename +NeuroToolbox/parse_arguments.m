function [err,exception_message] = parse_arguments(names,classes,attributes,defaults,user_inputs)
%PARSE_ARGUMENTS  Parses parameter-value pairs for NeuroToolbox functions
% 
%     PARSE_ARGUMENTS is used by NeuroToolbox functions to ensure that the
%     parameter-value pairs input by the user are valid. The calling
%     function specifies a set of possible parameter names, the classes
%     those parameters can accept, attributes of those parameters, and the
%     default values to apply. PARSE_ARGUMENTS then creates variables in
%     the workspace of the calling function that correspond to each
%     parameter name, and returns an error code if necessary.
%     
%     Syntax:
%     
%         [ERR, EXCEPTION_MESSAGE] = PARSE_ARGUMENTS(NAMES,CLASSES, ...
%               ATTRIBUTES,DEFAULTS,USER_INPUTS)
%     
%     Outputs:
%     
%         ERR is an error flag. A value of 0 means there were no errors
%         caused by the user input. A value of 1 means there was at least
%         one error cause by user input.
% 
%         EXCEPTION_MESSAGE is a string that can be used by the calling
%         function to provide the user with more information about errors.
%         If there is no error (i.e. ERR is 0), then EXCEPTION_MESSAGE is
%         an empty array.
% 
%     Inputs:
%     
%         NAMES is a cell array in which each element is a string
%         representing a parameter name that is to be assigned as a
%         variable in the calling function workspace
% 
%         CLASSES is a cell array of strings containing the classes that
%         the corresponding parameter in NAMES may be. For a list, see the
%         documentation for the 'class' argument of VALIDATEATTRIBUTES. An
%         additional class that may be used here is 'cellstr', which is not
%         an actual class, but requires value of the parameter to be a cell
%         array of strings.
% 
%         ATTRIBUTES is a cell array of cell arrays containing attributes
%         (see the documentation on the 'attribute' argument to
%         VALIDATEATTRIBUTES) if the corresponding CLASS is not 'char' or
%         'cellstr'. If the corresponding CLASS is 'char' or 'cellstr',
%         then ATTRIBUTES contains a list of allowed values. An empty cell
%         indicates no restrictions on the value.
%
%         DEFAULTS is a cell array in which each element is the default
%         value of the corresponding parameter in NAMES. If a parameter
%         exists in NAMES, but not in INPUTS, then it is assigned the value
%         in DEFAULTS.
%
%         USER_INPUTS is a cell array containing the parameter-value pairs
%         input to the calling function (this is usually varargin). The
%         first (and every odd) element is a parameter name, and the second
%         (and every even element) is the value to assign to the previous
%         parameter name.
%     
%     
%     See also PARSE_SPIKE_REF, VALIDATEATTRIBUTES, INPUTPARSER.


% First, make sure the names, classes, attributes and defaults are valid
% All four must be same size
num_names = numel(names);
num_classes = numel(classes);
num_attributes = numel(attributes);
num_defaults = numel(defaults);
if ~isequal(num_names,num_classes,num_attributes,num_defaults)
    id = 'NeuroToolbox:parse_arguments:default_size_mismatch';
    message = 'Number of parameter names, classes, attributes, and default values must be the same. For help, type ''help parse_arguments''';
    exception = MException(id,message);
    throw(exception);
end

% Check for non-string names
name_str_flag = 1;
for i = 1:numel(names);
    if ~ischar(names{i})
        name_str_flag = 0;
    end
end
if ~name_str_flag
    id = 'NeuroToolbox:parse_arguments:non_string_name';
    message = 'One or more parameter names was of a class other than ''char''. For help, type ''help parse_arguments''';
    exception = MException(id,message);
    throw(exception);
end

% Construct the input scheme
p = create_input_scheme(names,classes,attributes);

% Check that defaults are valid
defaults = [names;defaults];
try
    p.parse(defaults{:});
    default_results = rmfield(p.Results,p.UsingDefaults);
catch ME
    id = 'NeuroToolbox:parse_arguments:bad_default';
    msg = ME.message;
    ME = MException(id,msg);
    throw(ME);
end

% Initially no error state
err = 0;
exception_message = [];

%%%%%%%%%%%%%%%%%%%%
%%% Parse inputs %%%
%%%%%%%%%%%%%%%%%%%%

try
    p.parse(user_inputs{:});
    user_results = rmfield(p.Results,p.UsingDefaults);
catch ME
    err = 1;
    exception_message = ME.message;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Assign the values in the calling function's workspace %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~err
    
    % Assign default values
    default_vals = struct2cell(default_results);
    default_names = fieldnames(default_results);
    for i = 1:numel(default_vals)
        assignin('caller',default_names{i},default_vals{i});
    end
    
    % Overwrite defaults with any user-specified values
    user_vals = struct2cell(user_results);
    user_names = fieldnames(user_results);
    for i = 1:numel(user_vals)
        assignin('caller',user_names{i},user_vals{i});
    end
    
end

end




function p = create_input_scheme(names,classes,attributes)

% Create the input scheme object
p = inputParser;

% Create the parameter for each input
for i = 1:numel(names)
   
    % For compatibility with older versions of MATLAB (the
    % inputParser/addParameter method was added in some version after
    % R2012a)
    if ~exist('inputParser/addParameter')
        oldflag = true;
    else
        oldflag = false;
    end
    
    % Depending on whether addParameter exists or not, call either
    % addParameter or addParamValue
    if oldflag
        if ~any(strcmp(classes{i},{'char','cellstr'}))
            if ~iscell(classes{i})
                addParamValue(p,names{i},1,@(X)(validateattributes(X,classes(i),attributes{i})));
            else
                addParamValue(p,names{i},1,@(X)(validateattributes(X,classes{i},attributes{i})));
            end
        elseif strcmp(classes{i},'char')
            addParamValue(p,names{i},1,@(X)(char_validate_string(names{i},X,attributes{i})));
        elseif strcmp(classes{i},'cellstr')
            addParamValue(p,names{i},1,@(X)(cellstr_validate_string(names{i},X,attributes{i})));
        end
    else
        if ~any(strcmp(classes{i},{'char','cellstr'}))
            if ~iscell(classes{i})
                addParameter(p,names{i},1,@(X)(validateattributes(X,classes(i),attributes{i})));
            else
                addParameter(p,names{i},1,@(X)(validateattributes(X,classes{i},attributes{i})));
            end
        elseif strcmp(classes{i},'char')
            addParameter(p,names{i},1,@(X)(char_validate_string(names{i},X,attributes{i})));
        elseif strcmp(classes{i},'cellstr')
            addParameter(p,names{i},1,@(X)(cellstr_validate_string(names{i},X,attributes{i})));
        end
    end
    
end

end






function char_validate_string(name,str,vals)

if ischar(str)
    % Throw error if input is not a valid value
    if ~isempty(vals)
        dummy = validatestring(str,vals);
    end
else
    id = 'NeuroToolbox:parse_arguments:char_validate_string:incorrect_value_class';
    msg = sprintf('Incorrect input class. Expected %s to be of type char, but received type %s.\n',name,class(str));
    ME = MException(id,msg);
    throw(ME);
end

end

function cellstr_validate_string(name,cellstr,vals)

if isa(cellstr,'cell')
    if ~isempty(cellstr)
        for i = 1:numel(cellstr)
            if ischar(cellstr{i})
                % Throw error if input contains invalid values
                if ~isempty(vals)
                    dummy = validatestring(cellstr{i},vals);
                end
            else
                % Throw error if input contains non-string elements
                id = 'NeuroToolbox:parse_arguments:cellstr_validate_string:incorrect_value_class';
                msg = sprintf('Expected input %s to contain class char, received %s',name,class(cellstr{i}));
                ME = MException(id,msg);
                throw(ME);
            end
        end
    end
else   
    % Throw error if input is not a cell array
    id = 'NeuroToolbox:parse_arguments:cellstr_validate_string:incorrect_value_class';
    msg = sprintf('Expected input %s to be a cell array of strings, but received %s\n',name,class(cellstr));
    ME = MException(id,msg);
    throw(ME);
end

end