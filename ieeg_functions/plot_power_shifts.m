function [] = plot_power_shifts(label_log, sub_features, band_list, ...
        band_locs, tot_plots, weight_start, weight_increment, ...
        sub_rows, sub_cols)

    if numel(band_list) > 1
        %% Only make power transitions if there are more than 1 power
        band_splits = struct;
        shift_i = 0;
        for loc_i = 1:numel(band_locs)
            loc_bool = band_locs(loc_i);
            if loc_bool
                if shift_i ~= 0
                    band_shift = [bandname, '_', sub_features{loc_i}];
                    band_splits.(band_shift) = shift_i;
                end
                bandname = sub_features{loc_i};
            else
                region = sub_features{loc_i};
                tot_region_chans = numel(label_log.sig_channels(strcmpi(label_log.label, region)));
                shift_i = shift_i + tot_region_chans;
            end
        end
        unique_shifts = fieldnames(band_splits);

        %% Plot power shifts
        for comp_i = weight_start:weight_increment:tot_plots
            scrollsubplot(sub_rows, sub_cols, comp_i);
            hold on;
            for split_i = 1:numel(unique_shifts)
                power_shift = unique_shifts{split_i};
                % + .5 to center vertical line between bars
                xline((band_splits.(power_shift) + 0.5), 'k', ...
                    strrep(power_shift, '_', ' '), ...
                    'LabelOrientation', 'horizontal', ...
                    'LabelHorizontalAlignment', 'center', ...
                    'HandleVisibility', 'off');
            end
            hold off;
        end
    end
end