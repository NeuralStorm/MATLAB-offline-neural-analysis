function [] = plot_recfield(fig_h, x, y, fbl, lbl, threshold, bin_size, window_start)
    %% Plots elements from rec field analysis
    figure(fig_h);
    hold on
    if ~isnan(fbl)
        %red labelling
        fbl_i = round((fbl - window_start) / bin_size) + 1;
        lbl_i = round((lbl - fbl) / bin_size) + fbl_i - 1;
        psth_bar = bar(x(fbl_i:lbl_i), y(fbl_i:lbl_i),'BarWidth', 1);
        set(psth_bar,'FaceColor','r', 'EdgeAlpha', 0);

        %% Plot receptive field measures
        line([fbl fbl], ylim, 'Color', 'red', 'LineWidth', 0.75);
        line([lbl lbl], ylim, 'Color', 'red', 'LineWidth', 0.75);
    end
    plot(xlim,[threshold threshold], 'r', 'LineWidth', 0.75);
    hold off
end