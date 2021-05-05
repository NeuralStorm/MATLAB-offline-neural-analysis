function [results] = plot_corr(save_path, component_results, chan_group_log, ...
        feature_filter, feature_value, min_components, corr_components, ...
        sub_rows, sub_columns, subplot_shrinking, legend_loc)

    %% Purpose: Create subplot with correlations across intersection
    %           of channel sets across different feature spaces.
    %           linear line of best fit and r2 of correlation also given
    %% Input
    % save_path: path where subplots are saved
    % component_results: struct w/ fields for each feature set ran through PCA
    %                    Relevent fields used for analysis listed below. Struct automatically made when calc_pca.m is ran
    %                    feature_name: struct with fields
    %                                  coeff: NxN (N = tot features) matrix with coeff weights used to scale mnts into PC space
    %                                             Columns: Component Row: Feature
    %                                  orig_chan_order: C x 1 cell array, C = tot channels. Order of electrodes fed into PCA
    % chan_group_log: table with columns (relevant columns shown only)
    %            'channel': String with name of channel
    %            'label': String: associated region or grouping of electrodes
    % feature_filter: String with description for pcs
    %                 'all': keep all pcs after PCA
    %                 'pcs': Keep # of pcs set in feature_value
    %                 'percent_var': Use X# of PCs that meet set % in feature_value
    % feature_value: Int matched to feature_filter
    %                'all': left empty
    %                'pcs': Int for # of pcs to keep
    %                'percent_var': % of variance desired to be explained by pcs
    % min_components: Int: min componenets needed to make subplot
    % corr_components: Int: Max possible components plotted
    % sub_rows: Int: desired rows to be shown on subplot
    % sub_coloumns: Int: desired cols to be shown on subplot
    % subplot_shrinking: Float: How much should the subplot shrink to give spacing for axis labels and title (typically > 0.1)
    % legend_loc: String: where to place legend. See Matlab's legend documentation for list of all possible locations
    %% Output: There is no return. The graphs are saved directly to the path indicated by save_path

    color_map = [0 0 0 % black
                256 0 0 % red
                0 0 256 % blue
                0 255 0 % green
                102 0 204 % magenta
                255 128 0] ./ 256; % yellow

    %% Create color_struct
    unique_features = unique(chan_group_log.chan_group);
    combined_feature_space = unique_features{1};
    color_log.chan_group = chan_group_log.chan_group;
    color_log.channel = chan_group_log.channel;
    for feature_i = 2:numel(unique_features)
        feature = unique_features{feature_i};
        combined_feature_space = [combined_feature_space, '_', feature];
    end
    [color_struct, ~] = create_color_struct(color_map, color_log);

    rsq_out = cell(corr_components, 1);
    parfor comp_i = 1:corr_components
        %% Parallel process to go through component correlation plotting
        figure
        sgtitle(['Component ', num2str(comp_i)]);
        subplot_i = 1;
        r_struct = struct;
        comp_rsq_out = [];
        for space_one_i = 1:(numel(unique_features) - 1)
            %% Take electrodes from first feature space
            space_one = unique_features{space_one_i};
            first_elec_set = component_results.(space_one).orig_chan_order;
            first_elec_set = erase(first_elec_set, [space_one, '_']);
            first_weights = component_results.(space_one).coeff;
            [~, first_components] = size(first_weights);
            if first_components < min_components || first_components < comp_i
                %% Skip to next feature space if not enough components to plot
                continue
            end
            if strcmpi(feature_filter, 'pcs') && feature_value < first_components
                %% Grabs desired number of principal components weights
                first_weights = first_weights(:, 1:feature_value);
            end
            remaining_spaces = unique_features(space_one_i + 1:end);
            for space_two_i = 1:numel(remaining_spaces)
                %% Compare first feature space to remaining feature spaces via intersection of electrodes
                space_two = remaining_spaces{space_two_i};
                second_elec_set = component_results.(space_two).orig_chan_order;
                second_elec_set = erase(second_elec_set, [space_two, '_']);
                second_weights = component_results.(space_two).coeff;
                [~, second_components] = size(second_weights);
                if second_components < min_components || second_components < comp_i
                    %% Skip to next feature space if not enough components to plot
                    continue
                end
                if strcmpi(feature_filter, 'pcs') && feature_value < second_components
                    %% Grabs desired number of principal components weights
                    second_weights = second_weights(:, 1:feature_value);
                end
                [elec_intersect, first_i, second_i] = intersect(first_elec_set, second_elec_set);
                %% Skip to next feature space if not enough components to plot
                if isempty(elec_intersect) || numel(elec_intersect) < min_components
                    continue
                end
                %% Grab coeff weights from first (x) and second (y) feature space
                x_values = first_weights(first_i, comp_i);
                y_values = second_weights(second_i, comp_i);
                [~, label_i, ~] = intersect(color_log.channel, elec_intersect);
                region_order = color_log.chan_group(label_i);
                unique_regions = unique(region_order);
                scrollsubplot(sub_rows, sub_columns, subplot_i);
                hold on
                for reg_i = 1:numel(unique_regions)
                    %% Plot scatter for each unique region in intersection
                    region = unique_regions{reg_i};
                    reg_color = color_struct.(region).color;
                    reg_locs = ismember(region_order, region);
                    scatter(x_values(reg_locs), y_values(reg_locs), ...
                        'MarkerFaceColor', reg_color, 'MarkerEdgeColor', 'none');
                end
                [~, y_fit] = get_linear_fit(x_values, y_values); 
                plot(x_values, y_fit, '-');
                %% R2 calculation
                R = corrcoef(x_values,y_values);
                Rsq = R(1,2).^2;
                %% Store info in table
                comp_rsq_out = [comp_rsq_out; {comp_i}, {numel(elec_intersect)}, ...
                    {space_one}, {space_two}, {Rsq}];
                %% Axis and title set up
                title(['R^2: ', num2str(Rsq)])
                xlabel(strrep(space_one, '_', ' '))
                xtickformat('%.2f');
                ylabel(strrep(space_two, '_', ' '))
                ytickformat('%.2f');
                %% legend set up
                lg = legend(unique_regions);
                lg.Orientation = 'Horizontal';
                lg.Location = legend_loc;
                %% shrink height of graphs slightly to stop overlap of text in fullscreen
                ax_vals = gca;
                ax_vals.Position(4) = ax_vals.Position(4) - subplot_shrinking;
                hold off
                subplot_i = subplot_i + 1;
                %% r2 storage
                if ~isfield(r_struct, space_one)
                    r_vals = nan(1, numel(unique_features));
                    r_table = array2table(r_vals, 'VariableNames', unique_features);
                    r_struct.(space_one) = r_table;
                    r_struct.(space_one).(space_one) = 1;
                    r_struct.(space_one).(space_two) = Rsq;
                else
                    r_struct.(space_one).(space_two) = Rsq;
                end
                if ~isfield(r_struct, space_two)
                    r_vals = nan(1, numel(unique_features));
                    r_table = array2table(r_vals, 'VariableNames', unique_features);
                    r_struct.(space_two) = r_table;
                    r_struct.(space_two).(space_two) = 1;
                    r_struct.(space_two).(space_one) = Rsq;
                else
                    r_struct.(space_two).(space_one) = Rsq;
                end
            end
        end
        if subplot_i > 1
            % Only saved if at least one subplot was made
            filename = ['component_corr_', num2str(comp_i), '.fig'];
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
            savefig(gcf, fullfile(save_path, filename));

            %% Create heatmap of correlation values
            figure
            r_fields = fieldnames(r_struct);
            first_feat = r_struct.(r_fields{1});
            r_table = first_feat;
            for feature_i = 2:numel(r_fields)
                %% Compile separate feature tables into one to create heatmap
                feature = r_fields{feature_i};
                if ~isfield(r_struct, feature)
                    continue
                end
                feature_table = r_struct.(feature);
                r_table = [r_table; feature_table];
            end
            r_table = movevars(r_table, r_fields, 'Before', 1);
            %% Turn r^2 table to array and create heatmap
            r_matrix = table2array(r_table);
            r_matrix = r_matrix(:, ~all(isnan(r_matrix)));
            heatmap(r_fields, r_fields, r_matrix);
            colormap hot
            %% Save heatmap
            filename = ['heatmap_component_corr_', num2str(comp_i), '.png'];
            saveas(gcf, fullfile(save_path, filename));
            filename = ['heatmap_component_corr_', num2str(comp_i), '.fig'];
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
            savefig(gcf, fullfile(save_path, filename));
        end
        close all
        rsq_out{comp_i} = comp_rsq_out;
    end

    %% Unroll components stored in rsq_out
    results = [];
    for comp_i = 1:(corr_components)
        comp_info = rsq_out{comp_i};
        if isempty(comp_info)
            continue
        end
        results = [results; comp_info];
    end
end