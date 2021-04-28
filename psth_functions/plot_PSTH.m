function [psth_figure] = plot_PSTH(x, y)
    psth_figure = figure;
    figure(psth_figure);
    bar_h = bar(x, y,'BarWidth', 1);
    set(bar_h, 'EdgeAlpha', 0);
    xtickformat('%.2f');
    xlabel('Time');
    ylabel('Magnitude');
end