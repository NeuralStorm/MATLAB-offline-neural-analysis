function [] = plot_corr(save_path, component_results, label_log, ...
        feature_filter, feature_value, min_components, corr_components, ...
        subplot_shrinking, legend_loc)
    color_map = [0 0 0 % black
                1 0 0 % red
                0 0 1 % blue
                0 1 0 % green
                1 0 1 % magenta
                1 1 0]; % yellow
    %! Change from hard coded
    plot_rows = 3; plot_cols = 3;
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

    parfor comp_i = 1:corr_components
        figure
        sgtitle(['Component ', num2str(comp_i)]);
        i = 1;
        legend_struct = struct;
        for space_one_i = 1:(numel(unique_features) - 1)
            space_one = unique_features{space_one_i};
            first_elec_set = component_results.(space_one).elec_order;
            first_weights = component_results.(space_one).coeff;
            [~, first_components] = size(first_weights);
            if first_components < min_components || first_components < comp_i
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
                if second_components < min_components || second_components < comp_i
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
                x_values = first_weights(first_i, comp_i);
                y_values = second_weights(second_i, comp_i);
                [~, label_i, ~] = intersect(color_log.sig_channels, elec_intersect);
                region_order = color_log.label(label_i);
                unique_regions = unique(region_order);
                scrollsubplot(plot_rows, plot_cols, i);
                hold on
                color_list = zeros(numel(region_order), 3);
                legend_info = [];
                for reg_i = 1:numel(unique_regions)
                    region = unique_regions{reg_i};
                    reg_color = color_struct.(region).color;
                    reg_locs = ismember(region_order, region);
                    s = scatter(x_values(reg_locs), y_values(reg_locs), ...
                        'MarkerFaceColor', reg_color, 'MarkerEdgeColor', 'none');
                    legend_info = [legend_info, s];
                    if ~isfield(legend_struct, region)
                        legend_struct.(region) = s;
                    end
                end
                [~, y_fit] = get_linear_fit(x_values, y_values); 
                plot(x_values, y_fit, '-');
                %% R2 calculation
                R = corrcoef(x_values,y_values);
                Rsq = R(1,2).^2;
                %% Axis and title set up
                title(['R^2: ', num2str(Rsq)])
                xlabel(strrep(space_one, '_', ' '))
                xtickformat('%.2f');
                ylabel(strrep(space_two, '_', ' '))
                ytickformat('%.2f');
                %% legend set up
                lg = legend(legend_info, unique_regions);
                lg.Orientation = 'Horizontal';
                lg.Location = legend_loc;
                %% shrink height of graphs slightly to stop overlap of text in fullscreen
                ax_vals = gca;
                ax_vals.Position(4) = ax_vals.Position(4) - subplot_shrinking;
                hold off
                i = i + 1;
            end
        end
        if i > 1
            filename = ['component_corr_', num2str(comp_i), '.fig'];
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
            savefig(gcf, fullfile(save_path, filename));
        end
        close all
    end
end