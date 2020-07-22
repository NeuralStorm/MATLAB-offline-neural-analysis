function [] = plot_corr(save_path, component_results, label_log)
    color_map = [0 0 0 % black
                1 0 0 % red
                0 0 1 % blue
                0 1 0 % green
                1 0 1 % magenta
                1 1 0]; % yellow

    unique_features = fieldnames(label_log);

    %% Create color_struct
    combined_feature_space = unique_features{1};
    color_log.label = label_log.(combined_feature_space).label;
    color_log.sig_channels = label_log.(combined_feature_space).sig_channels;
    for feature_i = 2:numel(unique_features)
        feature = unique_features{feature_i};
        combined_feature_space = [combined_feature_space, '_', feature];
        %TODO add label and sig_channels to color_log
        color_log.label = [color_log.label; label_log.(feature).label];
        color_log.sig_channels = [color_log.sig_channels; label_log.(feature).sig_channels];
    end
    [color_struct, region_list] = create_color_struct(color_map, combined_feature_space, color_log);

    figure
    %! Change from hard coded
    plot_rows = 3; plot_cols = 3; i = 1;
    %TODO add loop for multiple components
    for feature_i = 1:(numel(unique_features) - 1)
        feature = unique_features{feature_i};
        first_elec_set = component_results.(feature).elec_order;
        combined_feature_space = unique_features(feature_i + 1:end);
        for combined_feature_i = 1:numel(combined_feature_space)
            second_feature = combined_feature_space{combined_feature_i};
            second_elec_set = component_results.(second_feature).elec_order;
            [elec_intersect, first_i, second_i] = intersect(first_elec_set, second_elec_set);
            if isempty(elec_intersect)
                continue
            end
            %TODO build color list
            % intersect(elec_intersect
            scrollsubplot(plot_rows, plot_cols, i);
            scatter(component_results.(feature).coeff(first_i, 1), component_results.(second_feature).coeff(second_i, 1))
            xlabel(strrep(feature, '_', ' '))
            xtickformat('%.2f');
            ylabel(strrep(second_feature, '_', ' '))
            ytickformat('%.2f');
            i = i + 1;
        end
    end
    % hold off
end