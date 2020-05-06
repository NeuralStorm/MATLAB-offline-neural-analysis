function [] = plot_pca_weights(save_path, component_results, label_log, feature_filter, ...
        feature_value, ymax_scale, sub_rows, sub_cols, session_num)

    color_map = [0 0 0 % black
                1 0 0 % red
                0 0 1 % blue
                0 1 0 % green
                1 0 1 % magenta
                1 1 0]; % yellow
    [~, tot_colors] = size(color_map);

    unique_powers = fieldnames(label_log);
    for pow_i = 1:length(unique_powers)
        curr_pow = unique_powers{pow_i};
        %% Shade different powers in plot
        if contains(curr_pow, '_')
            multi_powers = true;
            split_powers = strsplit(curr_pow, '_');
            tot_pows = length(split_powers);
        else
            multi_powers = false;
        end

        unique_regions = fieldnames(label_log.(curr_pow));
        for region_i = 1:length(unique_regions)
            region = unique_regions{region_i};
            if contains(region, '_')
                split_regions = strsplit(region, '_');
                tot_sub_regs = length(split_regions);
                multi_regs = true;
            else
                multi_regs = false;
            end
            pca_weights = component_results.(curr_pow).(region).coeff;
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
            %% Determine if there are too many rows/cols and reduces to make subplot bigger
            if (sub_cols * sub_rows) > tot_components
                plot_rows = round(tot_components / 2);
                plot_cols = tot_components - plot_rows;
            else
                plot_rows = sub_rows;
                plot_cols = sub_cols;
            end
            %% Create figure
            figure('visible', 'off')
            title_txt = strrep([curr_pow ' ' region], '_', ' ');
            sgtitle(title_txt);
            for comp_i = 1:tot_components
                comp_weights = pca_weights(:, comp_i);
                if tot_components > 1
                    scrollsubplot(plot_rows, plot_cols, comp_i);
                elseif tot_components == 0
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
                                subreg_table = label_log.(curr_pow).(sub_reg);
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
                    %TODO: Case multi regions only
                    reg_start = 1;
                    color_counter = 1;
                    for reg_i = 1:tot_sub_regs
                        sub_reg = split_regions{reg_i};
                        subreg_table = label_log.(curr_pow).(sub_reg);
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
                    bar(comp_weights, ...
                        'FaceColor', color_map(1, :), ...
                        'EdgeColor', 'none');
                end
                %% Creates Legends
                if multi_regs
                    warning('off','all')
                    lg = legend(split_regions);
                    legend('boxoff');
                    lg.Location = 'BestOutside';
                    lg.Orientation = 'Horizontal';
                    warning('on','all')
                end

                ylim([y_min y_max]);
                xlabel('Electrode #');
                ylabel('Coefficient Weight');
                sub_title = strrep(['PC ' num2str(comp_i)], '_', ' ');
                title(sub_title)
            end
            filename = [num2str(session_num), '_', curr_pow, '_', region, '.fig'];
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
            savefig(gcf, fullfile(save_path, filename));
            close all
        end
    end
end