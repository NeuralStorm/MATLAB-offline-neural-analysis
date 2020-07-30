function [] = plot_corr(save_path, component_results, label_log, ...
        feature_filter, feature_value, min_components)
    color_map = [0 0 0 % black
                1 0 0 % red
                0 0 1 % blue
                0 1 0 % green
                1 0 1 % magenta
                1 1 0]; % yellow
    %! Change from hard coded
    plot_rows = 3; plot_cols = 3; i = 1;
    %TODO add loop for multiple components

    unique_features = fieldnames(label_log);
    %% Create color_struct
    combined_feature_space = unique_features{1};
    color_log.label = label_log.(combined_feature_space).label;
    color_log.sig_channels = label_log.(combined_feature_space).sig_channels;
    for feature_i = 2:numel(unique_features)
        feature = unique_features{feature_i};
        combined_feature_space = [combined_feature_space, '_', feature];
        color_log.label = [color_log.label; label_log.(feature).label];
        color_log.sig_channels = [color_log.sig_channels; label_log.(feature).sig_channels];
    end
    [color_struct, ~] = create_color_struct(color_map, combined_feature_space, color_log);

    figure
    for space_one_i = 1:(numel(unique_features) - 1)
        space_one = unique_features{space_one_i};
        first_elec_set = component_results.(space_one).elec_order;
        first_weights = component_results.(space_one).coeff;
        [~, first_components] = size(first_weights);
        if first_components < min_components
            continue
        end
        if strcmpi(feature_filter, 'pcs') && feature_value < first_components
            %% Grabs desired number of principal components weights
            first_weights = first_weights(:, 1:feature_value);
        end
        remaining_spaces = unique_features(space_one_i + 1:end);
        for space_two_i = 1:numel(remaining_spaces)
            space_two = remaining_spaces{space_two_i};
            second_elec_set = component_results.(space_two).elec_order;
            second_weights = component_results.(space_two).coeff;
            [~, second_components] = size(second_weights);
            if second_components < min_components
                continue
            end
            if strcmpi(feature_filter, 'pcs') && feature_value < second_components
                %% Grabs desired number of principal components weights
                second_weights = second_weights(:, 1:feature_value);
            end
            [elec_intersect, first_i, second_i] = intersect(first_elec_set, second_elec_set);
            if isempty(elec_intersect) || numel(elec_intersect) < min_components
                continue
            end
            %TODO generalize for multiple components
            x_values = first_weights(first_i, 1);
            y_values = second_weights(second_i, 1);
            [~, label_i, ~] = intersect(color_log.sig_channels, elec_intersect);
            region_order = color_log.label(label_i);
            unique_regions = unique(region_order);
            size_list = ones(numel(region_order), 1) * 36; % 36 is default size
            color_list = zeros(numel(region_order), 3);
            for reg_i = 1:numel(unique_regions)
                region = unique_regions{reg_i};
                reg_color = color_struct.(region).color;
                reg_locs = ismember(region_order, region);
                color_list(reg_locs, :) = repmat(reg_color, [sum(reg_locs(:) == 1), 1]);
            end
            scrollsubplot(plot_rows, plot_cols, i);
            hold on
            scatter(x_values, y_values, size_list, color_list, 'filled');
            lsline
            R = corrcoef(x_values,y_values);
            Rsq = R(1,2).^2;
            title(['R^2: ', num2str(Rsq)])
            xlabel(strrep(space_one, '_', ' '))
            xtickformat('%.2f');
            ylabel(strrep(space_two, '_', ' '))
            ytickformat('%.2f');
            hold off
            i = i + 1;
        end
    end
    %TODO add color legend subplot
    %TODO save plots
end