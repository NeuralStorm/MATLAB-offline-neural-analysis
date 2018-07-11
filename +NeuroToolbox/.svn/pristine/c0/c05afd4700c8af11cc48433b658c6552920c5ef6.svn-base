function getWeights(obj,varargin)
%GETWEIGHTS Summary of this function goes here
%   Detailed explanation goes here
%
%   numcomp = 0 uses SVD to determine # of components to use
%   defaults are set to those used by Laubach 1999

% Check whether all options are valid. If not, throw an
% exception
validOptions = {'smoothPEM','demeanPEM','normalizePEM','demeanMNTS','normalizeMNTS','numcomp','sphering','extended','verbose'};
validOptionClasses = {'numeric','numeric','numeric','numeric','numeric','numeric','logical','numeric','char'};
validOptionAttributes = {{'nonnegative','integer','<=',2},{'nonnegative','integer','<=',3},{'nonnegative','integer','<=',2},{'nonnegative','integer','<=',2},{'nonnegative','integer','<=',2},{'positive','integer'},{},{'integer'},{'on','off'}};
defaultOptionValues = {3,0,0,1,1,0,true,1,'off'};
[err,msg] = NeuroToolbox.parse_arguments(validOptions,validOptionClasses,validOptionAttributes,defaultOptionValues,varargin);
if err
    id = ['NeuroToolbox:PSTHToolbox:PSTH:getMNTS:InvalidOptions',num2str(err)];
    msg = [msg,'\nFor more information on options, type ''help NeuroToolbox.PSTHToolbox.PSTH.getMNTS'''];
    exception = MException(id,msg);
    throw(exception);
end

% Check out automatically picking ncomps? Also rewrite
% ICAWeightedBinCounts to apply the plain weights array output by runica...

% Get the multineuron timeseries, and default to the behavior of neuroICA.
MNTS = obj.TemplateSource.getMNTS('smoothPEM',smoothPEM,'demeanPEM',demeanPEM,'normalizePEM',normalizePEM,'demeanMNTS',demeanMNTS,'normalizeMNTS',normalizeMNTS);
if numcomp == 0
    % If selected, use singular-value decomposition to determine number of
    % components to compute
    norm_MNTS = NeuroToolbox.PSTHToolbox.PSTH.normalize(MNTS,1);
    MNTS_cov = cov(norm_MNTS);
    eigs = eig(MNTS_cov);
    numcomp = sum(eigs>1);
end
if sphering, sphering='on'; else sphering='off'; end
[Weights,Sphere] = runica(MNTS','ncomps',numcomp,'pca',numcomp,'sphering',sphering,'extended',extended,'verbose',verbose);
W = Weights*Sphere;
obj.ICAWeights = W;
end