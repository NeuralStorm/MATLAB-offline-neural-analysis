function [psth_figure] = plot_PSTH(psth, psth_name, event, event_window, baseline_start, baseline_end, response_start, response_end)
    psth_figure = figure('visible','off');
    figure(psth_figure);
    unit_handle = bar(event_window, psth,'BarWidth', 1);
    %get parameter from figure
    axObjs = psth_figure.Children;
    dataObjs = axObjs.Children;
    y_values = dataObjs(1).YData;
    %set y axis limit for psth or mnts
    if min(y_values)>=0
        ylim([0 1.1*max(y_values)+eps]);
    else
        ylim([1.1*min(y_values) 1.1*max(y_values)+eps]);
    end
    set(unit_handle, 'EdgeAlpha', 0);
    hold on
    line([baseline_start baseline_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
    line([baseline_end baseline_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
    line([response_start response_start], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
    line([response_end response_end], ylim, 'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
    hold off
    xtickformat('%.2f')
    text=['Normalized Histogram: ', psth_name, ' event: ', event];
    title(text);
    xlabel('Time (s)');
    ylabel('Count');
end