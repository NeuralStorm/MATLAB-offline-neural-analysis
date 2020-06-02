function [] = plot_pca_weights(save_path, component_results, label_log, feature_filter, ...
        feature_value, ymax_scale, sub_rows, sub_cols, session_num)
    %TODO rename to plot_power_features()

    color_map = [0 0 0 % black
                1 0 0 % red
                0 0 1 % blue
                0 1 0 % green
                1 0 1 % magenta
                1 1 0]; % yellow
    [tot_colors, ~] = size(color_map);
    plot_start = 2;
    plot_increment = 1;

    unique_features = fieldnames(component_results);
    unique_features = unique_features(~ismember(unique_features, 'all_events'));

    for feature_i = 1:numel(unique_features)
        feature = unique_features{feature_i};

        %% Establish rows & cols for scrollsubplot, create figure, and title
        pca_weights = component_results.(feature).coeff;
        [~, tot_components] = size(pca_weights);
        if strcmpi(feature_filter, 'pcs') && feature_value < tot_components
            %% Grabs desired number of principal components weights
            tot_components = feature_value;
        end
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
        title_txt = strrep(feature, '_', ' ');
        sgtitle(title_txt);

        %% Plot PC variance
        scrollsubplot(plot_rows, plot_cols, 1);
        bar(component_results.(feature).component_variance, ...
            'EdgeColor', 'none');
        xlabel('PC #');
        ylabel('% Variance');
        title('Percent Variance Explained')

        %% Find powers and regions in feature
        sub_features = strsplit(feature, '_');
        band_locs = ~ismember(sub_features, label_log.(feature).label);
        band_list = sub_features(band_locs);
        region_list = sub_features(~band_locs);

        %% Set color map pairing for each unique region that appears
        color_struct = struct;
        color_i = 1;
        coeff_i = 1;
        for region_i = 1:numel(region_list)
            region = region_list{region_i};
            if isfield(color_struct, region)
                tot_region_chans = color_struct.(region).tot_region_chans;
                color_struct.(region).indices = [color_struct.(region).indices, coeff_i:(coeff_i + tot_region_chans - 1)];
                coeff_i = coeff_i + tot_region_chans;
            else
                %% Set indices in coefficients
                tot_region_chans = numel(label_log.(feature).sig_channels(strcmpi(label_log.(feature).label, region)));
                color_struct.(region).tot_region_chans = tot_region_chans;
                color_struct.(region).indices = coeff_i:(coeff_i + tot_region_chans - 1);
                coeff_i = coeff_i + tot_region_chans;
                %% set region color
                color_struct.(region).color = color_map(color_i, :);
                if color_i == tot_colors
                    color_i = 1;
                else
                    color_i = color_i + 1;
                end
            end
        end
        tot_plots = plot_weights(pca_weights, ymax_scale, color_struct, ...
            plot_rows, plot_cols, plot_start, plot_increment);

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
                    tot_region_chans = numel(label_log.(feature).sig_channels(strcmpi(label_log.(feature).label, region)));
                    shift_i = shift_i + tot_region_chans;
                end
            end
            unique_shifts = fieldnames(band_splits);

            %% Plot power shifts
            for comp_i = 2:tot_plots
                scrollsubplot(plot_rows, plot_cols, comp_i);
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

        %% save subplot
        filename = ['test_', num2str(session_num), '_', feature, '.fig'];
        set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
        savefig(gcf, fullfile(save_path, filename));
        close all
    end
end