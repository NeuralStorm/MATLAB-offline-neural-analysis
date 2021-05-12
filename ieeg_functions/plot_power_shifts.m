function [] = plot_power_shifts(band_shift, plot_labels, weight_start, ...
        weight_increment, tot_plots, sub_rows, sub_cols, font_size)

    if ~isempty(band_shift)
        [tot_shifts, ~] = size(band_shift);
        for comp_i = weight_start:weight_increment:tot_plots
            scrollsubplot(sub_rows, sub_cols, comp_i);
            hold on
            for shift_i = 1:tot_shifts
                bandname_shift = band_shift{shift_i, 1};
                shift_loc = band_shift{shift_i, 2};
                % + .5 to center vertical line between bars
                if plot_labels
                    xl = xline((shift_loc + 0.5), 'k', ...
                        bandname_shift, ...
                        'LabelOrientation', 'horizontal', ...
                        'LabelHorizontalAlignment', 'left', ...
                        'HandleVisibility', 'off');
                    xl.FontSize = font_size;
                else
                    xl = xline((shift_loc + 0.5), 'k', ...
                        'LabelOrientation', 'horizontal', ...
                        'LabelHorizontalAlignment', 'left', ...
                        'HandleVisibility', 'off');
                    xl.FontSize = font_size;
                end
            end
            hold off
        end
    end
end