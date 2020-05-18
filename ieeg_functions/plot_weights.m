function [] = plot_weights(pca_weights, ymax_scale, feature_filter, feature_value, ...
    color_map, multi_regs, tot_sub_regs, split_regions, region_table, multi_powers, tot_pows, split_powers, ...
    sub_rows, sub_cols, plot_counter, plot_incrememnt)

    [~, tot_colors] = size(color_map);

    y_max = max(max(pca_weights)) + (ymax_scale * max(max(pca_weights)));
    y_min = min(min(pca_weights));
    if max(max(pca_weights)) == y_min
        y_min = -y_min;
    end
    [tot_chans, tot_components] = size(pca_weights);
    if strcmpi(feature_filter, 'pcs')
        %% Grabs desired number of principal components weights
        if feature_value < tot_components
            tot_components = feature_value;
        end
    end
    for comp_i = 1:tot_components
        comp_weights = pca_weights(:, comp_i);
        scrollsubplot(sub_rows, sub_cols, plot_counter);
        if tot_components == 0
            continue
        end
        if multi_powers
            hold on
            tot_pow_pc = tot_chans / tot_pows;
            splits = [0, tot_pow_pc:tot_pow_pc:(tot_chans - 1)];
            if multi_regs
                % Case: multi powers and regions
                for split_i = 1:length(splits)
                    color_counter = 1;
                    feature_start = splits(split_i) + 1;
                    reg_start = feature_start;
                    for reg_i = 1:tot_sub_regs
                        sub_reg = split_regions{reg_i};
                        subreg_table = region_table.(sub_reg);
                        [~, ind] = unique(subreg_table, 'rows');
                        subreg_table = subreg_table(ind, :);
                        tot_sub_chans = height(subreg_table);
                        reg_end = reg_start + tot_sub_chans - 1;
                        bar(reg_start:reg_end, comp_weights(reg_start:reg_end), ...
                            'FaceColor', color_map(color_counter, :), ...
                            'EdgeColor', 'none');
                        reg_start = reg_end + 1;
                        if color_counter < tot_colors
                            color_counter = color_counter + 1;
                        else
                            color_counter = 1;
                        end
                    end
                end
            else
                % Case: Multi powers, single region
                bar(comp_weights, 'b', 'EdgeColor', 'none');
            end
            %% Add power line marking
            for split_i = 2:length(splits)
                feature_split = splits(split_i);
                % + .5 to center vertical line between bars
                xline((feature_split + .5), 'k', ...
                    [split_powers{split_i - 1}, ' ' split_powers{split_i}], ...
                    'LabelOrientation', 'horizontal', ...
                    'LabelHorizontalAlignment', 'center', ...
                    'HandleVisibility', 'off');
            end
            hold off
        elseif multi_regs
            %% Case multi regions only
            reg_start = 1;
            color_counter = 1;
            for reg_i = 1:tot_sub_regs
                sub_reg = split_regions{reg_i};
                subreg_table = region_table.(sub_reg);
                [~, ind] = unique(subreg_table, 'rows');
                subreg_table = subreg_table(ind, :);
                tot_sub_chans = height(subreg_table);
                reg_end = reg_start + tot_sub_chans - 1;
                bar(reg_start:reg_end, comp_weights(reg_start:reg_end), ...
                    'FaceColor', color_map(color_counter, :), ...
                    'EdgeColor', 'none');
                reg_start = reg_end + 1;
                if color_counter < tot_colors
                    color_counter = color_counter + 1;
                else
                    color_counter = 1;
                end
            end
        else
            hold on;
            bar(comp_weights, ...
                'FaceColor', color_map(1, :), ...
                'EdgeColor', 'none');
            hold off;
        end
        %% Creates Legends
        if multi_regs
            warning('off','all')
            lg = legend(split_regions);
            legend('boxoff');
            lg.Location = 'Best';
            lg.Orientation = 'Horizontal';
            warning('on','all')
        end

        ylim([y_min y_max]);
        xlabel('Electrode #');
        ylabel('Coefficient Weight');
        sub_title = strrep(['PC ' num2str(comp_i)], '_', ' ');
        title(sub_title)
        plot_counter = plot_counter + plot_incrememnt;
    end
end