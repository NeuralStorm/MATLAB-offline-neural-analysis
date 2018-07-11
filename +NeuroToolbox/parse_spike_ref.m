function [spikes,reference] = parse_spike_ref(spikes,reference,varargin)
%PARSE_SPIKE_REF Parses 'spikes' and 'reference' for the NeuroToolbox package
% 
%     This function parses the standard 'spikes' and 'reference' inputs
%     used by the NeuroToolbox package to import neural spike times and
%     reference event times.
%
%     The inputs can be in either the cell array or the numeric array
%     format (see below). Inputs in the numeric array format are
%     interpreted as timestamps coming from a single source (unit or
%     reference event). If either input is in a format other than one of
%     these two, an error is generated.
%
%     Cell array format:
%
%       'name 1'    array_of_timestamps_1
%       'name 2'    array_of_timestamps_2
%       'name 3'    array_of_timestamps_3
%            etc.
%
%     Numeric array format:
%
%       Any shape/size array of timestamps in seconds. If the SPIKES input
%       is in this format, then it is assumed to represent the timestamps
%       from the unit named 'sig001a', and if REFERENCE is in this format,
%       it is assumed to represent the timestamps from 'event001'. Both are
%       reformatted into the cell array format.
%     
%     Syntax:
%     
%         [SPIKES,REFERENCE] = PARSE_SPIKE_REF(SPIKES,REFERENCE)
%
%         PARSE_SPIKE_REF(…,’parameter_1’,value_1,'parameter_2',value_2…)
%         append parameter-value pairs after the required arguments. You
%         can list several pairs in series. See Parameter-value pairs
%         section below for a list of parameters that can be used.
%     
%     Outputs:
%     
%         SPIKES is the processed unit activity input. It is in the cell
%         array format. If the input was in the numeric array format, then
%         the name of the unit used in the output is 'sig001a'
% 
%         REFERENCE is the processed reference event input. It is in the
%         cell array format. If the input was in the numeric array format,
%         then the name of the event used in the output is 'event001'
%     
%     Inputs:
%     
%         SPIKES contains information about unit activity. It is in either
%         the cell array or numeric array format described above. The names
%         in the first column of the cell array format represent the name
%         of the unit with which the timestamps in the corresponding array
%         in the second column are associated.
% 
%         REFERENCE contains information about reference events. It is in
%         either the cell array or numeric array format described above.
%         The names in the first column of the cell array format represent
%         the name of the event with which the timestamps in the
%         corresponding array in the second column are associated.
%     
%     Parameter-value pairs:
%     
%         Parameter-value pairs can be used after the required inputs to
%         specify the following parameters. Enter the name as a string
%         followed by the value for that parameter. The following
%         parameters are valid
% 
%         ‘match_units’ – Forces the output to list the activity of some
%         list of units. Provide a cell array of strings here where each
%         element is the name of a unit that must be present in the output.
%         If the units are present in the input, then they are just
%         re-ordered to match the order specified here. If units are
%         missing in the input, then they are created in the output with no
%         associated timestamps. If units are present in the input that are
%         not present in this list, they are removed from the output. An
%         empty cell array does not do any matching (i.e. does not change
%         the input at all). The default is an empty array.
%           Example:
%               [Spikes,Reference]=PARSE_SPIKE_REF(Spikes,Reference, ...
%                                      'match_units',{'sig001a','sig005a'})
%     
%     
%     See also PARSE_ARGUMENTS.

% Parse arguments
parameters = {'match_units'};
parameter_classes = {'cell'};
parameter_attributes = {{}};
parameter_defaults = {{}};
[err,msg] = NeuroToolbox.parse_arguments(parameters,parameter_classes,parameter_attributes,parameter_defaults,varargin);
if err
    id = ['NeuroToolbox:parse_spike_ref:invalid_parameter',num2str(err)];
    msg = [msg,'\nFor more information, type ''help NeuroToolbox.parse_spike_ref'''];
    exception = MException(id,msg);
    throw(exception);
end

% Formatting non-cell-array inputs as cell-arrays
% If they are not simple numeric matrices of timestamps, throw
% an error
if ~iscell(spikes)
    if ~isnumeric(spikes)
        exception = MException('NeuroToolbox:parse_spike_ref:invalid_spikes','Invalid ''Spikes'' argument. Must be either a cell array or numeric array. Type ''help NeuroToolbox.parse_spike_ref'' for more.');
        throw(exception);
    else
        spikes = {'sig001a',spikes};
    end
end
if ~iscell(reference)
    if ~isnumeric(reference)
        exception = MException('NeuroToolbox:parse_spike_ref:invalid_reference','Invalid ''Reference'' argument. Must be either a cell array or numeric array. Type ''help NeuroToolbox.parse_spike_ref'' for more.');
        throw(exception);
    else
        reference = {'event001',reference};
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matching unit names if told to do so
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(match_units)
    
    % First step in matching units: Ignore units in input if not present
    % in match_units
    new_spikes = cell(size(match_units,1),size(spikes,2));
    [matched_unit_mask, matched_unit_inds] = ismember(spikes(:,1),match_units(:,1));
    new_spikes(matched_unit_inds(matched_unit_mask),:) = spikes(matched_unit_mask,:);
    
    % Second step in matching units: Add units to input data (with no spikes)
    % if they are present in match_units but missing in the input
    new_spikes(:,1) = match_units(:,1);
    
    % Third step in matching units: Once the units in match_units and input
    % are identical, make sure they are in same order
    [~,inds]=ismember(lower(new_spikes(:,1)),lower(match_units(:,1)));
    new_spikes = new_spikes(inds,:);
    
    % Reassign Spikes
    spikes = new_spikes;
end

end