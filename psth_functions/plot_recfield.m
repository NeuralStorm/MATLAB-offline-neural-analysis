function [] = plot_recfield(psth, first_bin_latency, last_bin_latency, threshold, ...
        figure_handle, bin_size, pre_time)
    %% Plots elements from rec field analysis
    figure(figure_handle);
    hold on
    if ~isnan(first_bin_latency)
        %red labelling
        sig_start_index = round((first_bin_latency + abs(pre_time)) / bin_size);
        sig_end_index = round((last_bin_latency + abs(pre_time)) / bin_size);
        psth_bar = bar(first_bin_latency:bin_size:last_bin_latency, ...
            psth(sig_start_index:sig_end_index),'BarWidth', 1);
        set(psth_bar,'FaceColor','r', 'EdgeAlpha', 0);

        %% Plot receptive field measures
        plot(xlim,[threshold threshold], 'r', 'LineWidth', 0.75);
        line([first_bin_latency first_bin_latency], ylim, 'Color', 'red', 'LineWidth', 0.75);
        line([last_bin_latency last_bin_latency], ylim, 'Color', 'red', 'LineWidth', 0.75);
    else
        plot(xlim,[threshold threshold], 'r', 'LineWidth', 0.75);
    end
    hold off
end