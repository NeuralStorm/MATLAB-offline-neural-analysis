function [tot_plots] = plot_weights(pca_weights, ymax_scale, color_struct, ...
        sub_rows, sub_cols, plot_counter, plot_increment)
    %TODO rename to plot_feature_weights()

    y_max = max(max(pca_weights)) + (ymax_scale * max(max(pca_weights)));
    y_min = min(min(pca_weights));
    if max(max(pca_weights)) == y_min
        y_min = -y_min;
    end
    [~, tot_components] = size(pca_weights);
    unique_regions = fieldnames(color_struct);
    for comp_i = 1:tot_components
        comp_weights = pca_weights(:, comp_i);
        scrollsubplot(sub_rows, sub_cols, plot_counter);
        hold on
        if tot_components == 0
            continue
        end
        for region_i = 1:numel(unique_regions)
            region = unique_regions{region_i};
            reg_i = color_struct.(region).indices;
            bar(reg_i, comp_weights(reg_i), ...
                'FaceColor', color_struct.(region).color, ...
                'EdgeColor', 'none');
        end
        lg = legend(unique_regions);
        legend('boxoff');
        lg.Location = 'Best';
        lg.Orientation = 'Horizontal';

        ylim([y_min y_max]);
        xlabel('Electrode #');
        ylabel('Coefficient Weight');
        sub_title = strrep(['PC ' num2str(comp_i)], '_', ' ');
        title(sub_title)
        hold off
        plot_counter = plot_counter + plot_increment;
    end
    tot_plots = plot_counter - 1;
end