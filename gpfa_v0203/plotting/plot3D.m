function plot3D(seq, xspec, plot_dimensions, varargin)
%
% plot3D(seq, xspec, ...)
%
% Plot neural trajectories in a three-dimensional space.
%
% INPUTS:
%
% seq        - data structure containing extracted trajectories
% xspec      - field name of trajectories in 'seq' to be plotted 
%              (e.g., 'xorth' or 'xsm')
%
% OPTIONAL ARGUMENTS:
%
% dimsToPlot - selects three dimensions in seq.(xspec) to plot 
%              (default: 1:3)
% nPlotMax   - maximum number of trials to plot (default: 20)
% redTrials  - vector of trialIds whose trajectories are plotted in red
%              (default: [])
%
% @ 2009 Byron Yu -- byronyu@stanford.edu

  dimsToPlot = 1:3;
  nPlotMax   = 20;
  redTrials  = [];
  assignopts(who, varargin);

  % if size(seq(1).(xspec), 1) < 3
  %   fprintf('ERROR: Trajectories have less than 3 dimensions.\n');
  %   return
  % end

  f = figure('visible','on');
  pos = get(gcf, 'position');
  set(f, 'position', [pos(1) pos(2) 1.3*pos(3) 1.3*pos(4)]);
  
  for n = 1:min(length(seq), nPlotMax)
    dat = seq(n).(xspec)(dimsToPlot,:);
    T   = seq(n).T;
        
    if ismember(seq(n).trialId, redTrials)
      col = [1 0 0]; % red
      lw  = 3;
    else
      col = 0.2 * [1 1 1]; % gray
      lw = 1;
    end

    if plot_dimensions == 2
      h = plot(dat(1,:), dat(2,:), '-', 'linewidth', lw);
      currentColor = get(h, 'Color'); % Gets color of each line being plotted
      hold on;
      
      % Creates star marker of when trial starts (*), triangle where decision
      % was made (^,)and at the end (o)
      plot(dat(1,1), dat(2,1), '*', 'linewidth', lw, 'MarkerFaceColor', currentColor, 'MarkerEdgeColor', currentColor);
      plot(dat(1,5), dat(2,5), '^', 'linewidth', lw, 'MarkerFaceColor', currentColor, 'MarkerEdgeColor', currentColor);
      %     set(h, {'MarkerFaceColor'}, get(h, 'Color'));
      plot(dat(1,end), dat(2,end), 'o', 'linewidth', lw, 'MarkerFaceColor', currentColor, 'MarkerEdgeColor', currentColor);
      %     set(g, {'MarkerFaceColor'}, get(g, 'Color'));
    elseif plot_dimensions == 3
      % 7/9/2018
      h = plot3(dat(1,:), dat(2,:), dat(3,:), '-', 'linewidth', lw);
      currentColor = get(h, 'Color'); % Gets color of each line being plotted
      hold on;
      
      % Creates star marker of when trial starts (*), triangle where decision
      % was made (^,)and at the end (o)
      plot3(dat(1,1), dat(2,1), dat(3,1), '*', 'linewidth', lw, 'MarkerFaceColor', currentColor, 'MarkerEdgeColor', currentColor);
      plot3(dat(1,5), dat(2,5), dat(3,5), '^', 'linewidth', lw, 'MarkerFaceColor', currentColor, 'MarkerEdgeColor', currentColor);
      %     set(h, {'MarkerFaceColor'}, get(h, 'Color'));
      plot3(dat(1,end), dat(2,end), dat(3,end), 'o', 'linewidth', lw, 'MarkerFaceColor', currentColor, 'MarkerEdgeColor', currentColor);
      %     set(g, {'MarkerFaceColor'}, get(g, 'Color'));
    else
      error()
    end
    
  end

  axis equal;
  if plot_dimensions == 2
    if isequal(xspec, 'xorth')
      str1 = sprintf('$$\\tilde{\\mathbf x}_{%d,:}$$', dimsToPlot(1));
      str2 = sprintf('$$\\tilde{\\mathbf x}_{%d,:}$$', dimsToPlot(2));
    else
      str1 = sprintf('$${\\mathbf x}_{%d,:}$$', dimsToPlot(1));
      str2 = sprintf('$${\\mathbf x}_{%d,:}$$', dimsToPlot(2));
    end
    xlabel(str1, 'interpreter', 'latex', 'fontsize', 24);
    ylabel(str2, 'interpreter', 'latex', 'fontsize', 24);
  elseif plot_dimensions == 3
    if isequal(xspec, 'xorth')
      str1 = sprintf('$$\\tilde{\\mathbf x}_{%d,:}$$', dimsToPlot(1));
      str2 = sprintf('$$\\tilde{\\mathbf x}_{%d,:}$$', dimsToPlot(2));
      str3 = sprintf('$$\\tilde{\\mathbf x}_{%d,:}$$', dimsToPlot(3));
    else
      str1 = sprintf('$${\\mathbf x}_{%d,:}$$', dimsToPlot(1));
      str2 = sprintf('$${\\mathbf x}_{%d,:}$$', dimsToPlot(2));
      str3 = sprintf('$${\\mathbf x}_{%d,:}$$', dimsToPlot(3));
    end
    xlabel(str1, 'interpreter', 'latex', 'fontsize', 24);
    ylabel(str2, 'interpreter', 'latex', 'fontsize', 24);
    zlabel(str3, 'interpreter', 'latex', 'fontsize', 24);
  else
    error()
  end