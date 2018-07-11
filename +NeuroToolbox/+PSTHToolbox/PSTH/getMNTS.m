function MNTS = getMNTS(obj, varargin)
%GETMNTS Returns the single trial responses in the multineuron timeseries format
%   Format described in Laubach et al., 1999
%
%   Parameter name-value pairs: All may be arrays if treatment in several
%   dimensions desired. treatments will be applied to dimensions in the
%   order dimensions are listed. If array contains dimensions AND zero, the
%   treatment is performed along the specified dimension and zero is
%   ignored. If the array for demeanPEM or smoothPEM contains a three, any
%   twos are ignored (whole row will be demeaned/smoothed anyway).
%
%   All default to zero
%
%       smoothPEM - nonnegative integer <=2. Dimension(s) along which to
%           smooth the PEM, or zero to turn off smoothing. Three smooths
%           each unit individually (instead of the entire row)
%       demeanPEM - nonnegative integer <=3. Dimension(s) along which to
%          demean the PEM or zero to turn off demeaning. Three demeans each
%          unit individually (instead of the entire row)
%       normalizePEM - nonnegative integer <=2. Dimension(s) along which to
%           normalize the PEM, or zero to turn off normalization.
%       demeanMNTS - nonnegative integer <=2. Dimension(s) along which to
%          demean the multineuron timeseries, or zero to turn off
%          demeaning.
%       normalizeMNTS - nonnegative integer <=2. Dimension(s) along which
%          to normalize the multineuron timeseries, or zero to turn off
%          normalization.

% Check whether all options are valid. If not, throw an
% exception
validOptions = {'smoothPEM','demeanPEM','normalizePEM','demeanMNTS','normalizeMNTS'};
validOptionClasses = {'numeric','numeric','numeric','numeric','numeric'};
validOptionAttributes = {{'nonnegative','integer','<=',2},{'nonnegative','integer','<=',3},{'nonnegative','integer','<=',2},{'nonnegative','integer','<=',2},{'nonnegative','integer','<=',2}};
defaultOptionValues = {0,0,0,0,0};
[err,msg] = NeuroToolbox.parse_arguments(validOptions,validOptionClasses,validOptionAttributes,defaultOptionValues,varargin);
if err
    id = ['NeuroToolbox:PSTHToolbox:PSTH:getMNTS:InvalidOptions',num2str(err)];
    msg = [msg,'\nFor more information on options, type ''help NeuroToolbox.PSTHToolbox.PSTH.getMNTS'''];
    exception = MException(id,msg);
    throw(exception);
end

% Get the single trial responses
STRs = obj.Single_Trial_Responses;

% Optional PEM smoothing
if any(smoothPEM==3)
    % Override 2nd dimension if smooth by unit selected
    smoothPEM = smoothPEM(smoothPEM~=2);
end
if any(smoothPEM)
    for dim = unique(smoothPEM(smoothPEM~=0));
        % For each dimension
        if dim==3
            % Smooth by unit
            STRs_new = [];
            for i = unique(obj.unit_key)
                unit_STRs = STRs(:,obj.unit_key==i);
                unit_STRs = obj.smooth(unit_STRs,2);
                STRs_new = [STRs_new,unit_STRs];
            end
            STRs = STRs_new;
        else
            % Or smooth along entire dimension
            STRs = obj.smooth(STRs,dim);
        end
    end
end

% Optional PEM demeaning
if any(demeanPEM==3)
    % Override 2nd dimension if demean by unit selected
    demeanPEM = demeanPEM(demeanPEM~=2);
end
if any(demeanPEM)
    for dim = unique(demeanPEM(demeanPEM~=0));
        % For each dimension
        if dim==3
            % Demean by unit
            STRs_new = [];
            for i = unique(obj.unit_key)
                unit_STRs = STRs(:,obj.unit_key==i);
                unit_STRs = obj.demean(unit_STRs,2);
                STRs_new = [STRs_new,unit_STRs];
            end
            STRs = STRs_new;
        else
            % Or demean along entire dimension
            STRs = obj.demean(STRs,dim);
        end
    end
end

% Optional PEM normalization
if any(normalizePEM)
    for dim = unique(normalizePEM(normalizePEM~=0));
        STRs=obj.normalize(STRs,dim);
    end
end

% Reformatting
MNTS = [];
for i = unique(obj.unit_key)
    unit_STRs = STRs(:,obj.unit_key==i);
    unit_STRs = unit_STRs';
    newcol = unit_STRs(:);    
    MNTS = [MNTS,newcol];
end

% Optional MNTS demeaning
if any(demeanMNTS)
    for dim = unique(demeanMNTS(demeanMNTS~=0));
        MNTS=obj.demean(MNTS,dim);
    end
end

% Optional MNTS normalization
if any(normalizeMNTS)
    for dim = unique(normalizeMNTS(normalizeMNTS~=0));
        MNTS=obj.normalize(MNTS,dim);
    end
end

end