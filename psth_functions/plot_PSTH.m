function [unit_figure] = plot_PSTH(current_neuron,current_neuron_name,current_event,event_window)
    unit_figure = figure('visible','off');
    figure(unit_figure);
    unit_handle = bar(event_window, current_neuron,'BarWidth', 1);
    set(unit_handle, 'EdgeAlpha', 0);
    xtickformat('%.2f')
    text=['Normalized Histogram: ', current_neuron_name, ' event: ', current_event];
    title(text);
    xlabel('Time (s)');
    ylabel('Count');
    

end