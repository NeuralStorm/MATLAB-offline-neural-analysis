function [] = plot_pca_weights(save_path, component_results, label_log, feature_filter, ...
        feature_value, ymax_scale, sub_rows, sub_cols, session_num)
    %TODO rename to plot_power_features()

    color_map = [0 0 0 % black
                1 0 0 % red
                0 0 1 % blue
                0 1 0 % green
                1 0 1 % magenta
                1 1 0]; % yellow
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

        %% Find powers feature
        sub_features = strsplit(feature, '_');
        band_locs = ~ismember(sub_features, label_log.(feature).label);
        band_list = sub_features(band_locs);

        %% Create color struct for each unique region in feature
        [color_struct, ~] = create_color_struct(color_map, ...
            feature, label_log.(feature));

        %% Plot out weights for each pc
        tot_plots = plot_weights(pca_weights, ymax_scale, color_struct, ...
            plot_rows, plot_cols, plot_start, plot_increment);

        %% Add vertical lines denoting shift in power
        plot_power_shifts(label_log.(feature), sub_features, band_list, ...
            band_locs, tot_plots, plot_start, plot_increment, ...
            plot_rows, plot_cols);

        %% save subplot
        filename = ['test_', num2str(session_num), '_', feature, '.fig'];
        set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
        savefig(gcf, fullfile(save_path, filename));
        close all
    end
end