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
            tot_pows = 1;
            split_powers = {curr_pow};
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
                tot_sub_regs = 1;
                split_regions = {region};
            end

            [~, tot_components] = size(component_results.(curr_pow).(region).coeff);
            %% Determine if there are too many rows/cols and reduces to make subplot bigger
            if (sub_cols * sub_rows) > tot_components
                plot_cols = round(tot_components / 2) + 1;
                plot_rows = tot_components - plot_cols;
                if plot_rows < 1
                    plot_rows = 1;
                end
            else
                plot_rows = sub_rows;
                plot_cols = (sub_cols + 1);
            end
            %% Create figure
            figure('visible', 'off')
            title_txt = strrep([curr_pow ' ' region], '_', ' ');
            sgtitle(title_txt);

            %% Plot PC variance
            scrollsubplot(plot_rows, plot_cols, 1);
            bar(component_results.(curr_pow).(region).component_variance, ...
                'EdgeColor', 'none');
            xlabel('PC #');
            ylabel('% Variance');
            title('Percent Variance Explained')

            pca_weights = component_results.(curr_pow).(region).coeff;
            plot_start = 2;
            plot_increment = 1;
            region_table = label_log.(curr_pow);
            plot_weights(pca_weights, ymax_scale, feature_filter, feature_value, ...
            color_map, multi_regs, tot_sub_regs, split_regions, region_table, multi_powers, tot_pows, split_powers, ...
            plot_rows, plot_cols, plot_start, plot_increment);

            filename = [num2str(session_num), '_', curr_pow, '_', region, '.fig'];
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
            savefig(gcf, fullfile(save_path, filename));
            close all
        end
    end
end