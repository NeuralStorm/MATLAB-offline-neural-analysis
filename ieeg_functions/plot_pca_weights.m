function [] = plot_pca_weights(component_results, label_log, feature_filter, ...
        feature_value, sub_rows, sub_cols)

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
            figure
            title_txt = strrep([curr_pow ' ' region], '_', ' ');
            sgtitle(title_txt);
            for comp_i = 1:tot_components
                comp_weights = pca_weights(:, comp_i);
                if tot_components > 1
                    scrollsubplot(plot_rows, plot_cols, comp_i);
                elseif tot_components == 0
                    continue
                end
                % b = bar(comp_weights, 'b');
                if multi_powers
                    tot_pow_pc = tot_chans / tot_pows;
                    splits = [0, tot_pow_pc:tot_pow_pc:(tot_chans - 1)];
                    if multi_regs
                        % Case: multi powers and regions
                        hold on
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
                                for k = reg_start:reg_end
                                    bar(k, comp_weights(k), 'FaceColor', color_map(color_counter, :));
                                end
                                reg_start = reg_end + 1;
                                if color_counter < tot_colors
                                    color_counter = color_counter + 1;
                                else
                                    color_counter = 1;
                                end
                            end
                        end
                        hold off
                    else
                        % Case: Multi powers, single region
                        bar(comp_weights, 'b');
                    end
                    %% Add power line marking
                    hold on
                    for split_i = 2:length(splits)
                        feature_split = splits(split_i);
                        % + .5 to center vertical line between bars
                        xline((feature_split + .5),'k');
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
                        for k = reg_start:reg_end
                            bar(k, comp_weights(k), 'FaceColor', color_map(color_counter, :));
                        end
                        reg_start = reg_end + 1;
                        if color_counter < tot_colors
                            color_counter = color_counter + 1;
                        else
                            color_counter = 1;
                        end
                    end
                else
                    bar(comp_weights, 'b');
                end








                % if multi_regs
                %     hold on
                %     if multi_powers
                %         tot_pow_pc = tot_chans / tot_pows;
                %         splits = [0, tot_pow_pc:tot_pow_pc:(tot_chans - 1)]
                %         for split_i = 1:(length(splits) - 1)
                %             color_counter = 1;
                %             feature_start = splits(split_i) + 1;
                %             reg_start = feature_start
                %             % feature_end = splits(split_i + 1);
                %             for reg_i = 1:tot_regs
                %                 sub_reg = split_regions{reg_i};
                %                 subreg_table = label_log.(curr_pow).(sub_reg);
                %                 [~, ind] = unique(subreg_table, 'rows');
                %                 subreg_table = subreg_table(ind, :);
                %                 tot_sub_chans = height(subreg_table)
                %                 reg_end = reg_start + tot_sub_chans - 1
                %                 for k = reg_start:reg_end
                %                     bar(k, comp_weights(k), 'FaceColor', color_map(color_counter, :));
                %                     % b(k).FaceColor = color_map(color_counter, :);
                %                 end
                %                 % bar(comp_weights(reg_start:reg_end), ...
                %                 %     'FaceColor', color_map(color_counter, :));
                %                 % 'finished bar'
                %                 % set(b(reg_start:reg_end), 'FaceColor', color_map(color_counter, :));
                %                 % b(reg_start:reg_end).FaceColor = color_map(color_counter, :);
                %                 reg_start = reg_end + 1
                %                 if color_counter < tot_colors
                %                     color_counter = color_counter + 1;
                %                 else
                %                     color_counter = 1;
                %                 end
                %             end
                %         end
                %     else
                %         %TODO
                %     end
                %     hold off
                % end
                % if multi_powers
                %     hold on
                %     tot_pow_pc = tot_chans / tot_pows;
                %     splits = tot_pow_pc:tot_pow_pc:(tot_chans - 1);
                %     for split_i = 1:length(splits)
                %         feature_split = splits(split_i);
                %         % + .5 to center vertical line between bars
                %         xline((feature_split + .5),'k');
                %     end
                %     hold off
                % end
                sub_title = strrep(['PC ' num2str(comp_i)], '_', ' ');
                title(sub_title)
            end
        end
    end
end