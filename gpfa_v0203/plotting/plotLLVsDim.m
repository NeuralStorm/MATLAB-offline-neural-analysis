function res = plotLLVsDim(runIdx, varargin)
%
% res = plotLLVsDim(runIdx,...)
%
% Plot cross-validated data log-likelihood versus state dimensionality
% for GPFA
%
% INPUTS:
%
% runIdx - results files will be loaded from mat_results/runXXX, where
%          XXX is runIdx
%
% OUTPUTS:
%
% res    - data structure containing log-likelihood values shown in plot
%
% OPTIONAL ARGUMENTS:
%
% plotOn - logical that specifies whether or not to display plot
%
% @ 2013 Byron Yu -- byronyu@cmu.edu

  plotOn = true;
  assignopts(who, varargin);
  
  runDir = sprintf('mat_results/run%03d', runIdx);
  if ~isdir(runDir)
    fprintf('ERROR: %s does not exist.  Exiting...\n', runDir);
    return
  else    
    D = dir([runDir '/*.mat']);
  end

  if isempty(D)
    fprintf('ERROR: No valid files.  Exiting...\n');
    method = [];
    return;
  end

  for i = 1:length(D)
    P = parseFilename(D(i).name);
    
    D(i).method = P.method;
    D(i).xDim   = P.xDim;
    D(i).cvf    = P.cvf;
  end
 
  % Only continue processing GPFA files that have test trials
  isGPFA = ismember({D.method}, 'gpfa'); 
  D = D(isGPFA & [D.cvf]>0);

  if isempty(D)
    fprintf('ERROR: No valid files.  Exiting...\n');
    method = [];
    return;
  end
  
  for i = 1:length(D)    
    fprintf('Loading %s/%s...\n', runDir, D(i).name);
    ws = load(sprintf('%s/%s', runDir, D(i).name));
    
    D(i).LLtest    = ws.LLtest;
    D(i).numTrials = length(ws.seqTest);
  end
    
  res.name = 'gpfa';
  res.xDim = unique([D.xDim]);
  
  % Do for each unique state dimensionality
  for p = 1:length(res.xDim)
    Dp = D([D.xDim] == res.xDim(p));
      
    % Sum across cross-validation folds
    res.LLtest(p)    = sum([Dp.LLtest]);        
    res.numTrials(p) = sum([Dp.numTrials]);
  end
  
  if length(unique(res.numTrials)) ~= 1
    fprintf('ERROR: Number of test trials must be the same across\n');
    fprintf('all state dimensionalities.  Exiting...\n');
    return
  end
    
  % =========
  % Plotting
  % =========
  if plotOn
    col = 'k'; 
    
    figure;
    plot(res.xDim, res.LLtest, col);
    title('GPFA', 'fontsize', 12);
    xlabel('State dimensionality', 'fontsize', 14);
    ylabel('Cross-validated data log-likelihood', 'fontsize', 14);
  end
