function [] = plot_brain_weights(save_path, dir_name, mesh_struct, elec_struct, ...
        component_results, label_log, min_components, feature_filter, ...
        feature_value, save_png)

    %% Purpose: Create subplot w/ electrode weights from pca plotted on brain mesh
    %% Input
    % save_path: path where subplots are saved
    % dir_name: name of directory used to create brain mesh plots
    % mesh_struct: struct w/ fields for left and right meshes
    %              Not all fields are list, only fields used in this function
    %              mesh is used to create 3D brain mesh plot
    %              mesh_filename: name must include left or right w/ fields
    %                             fields are auto generated after loading in pial
    %                             using fieldtrip or using fieldtrip .mat file
    % elect_struct: struct w/ info on electrode and anatomy
    %               Not all fields are list, only fields used in this function
    %               label: Cell array with electrode name. Must match names used when doing pca
    %               chanpos: x, y, z coordinate matrix for electrode placement
    %                        rows: electrode col: 3 (x, y, z)
    % component_results: struct w/ fields for each feature set ran through PCA --> created by calc_pca.m
    %                    Not all fields are list, only fields used in this function
    %                    feature_name: struct with fields
    %                                  coeff: NxN (N = tot features) matrix with coeff weights used to scale mnts into PC space
    %                                             Columns: Component Row: Feature
    %                                  elec_order: order of electrodes in feature space
    % label_log: struct with fieldnames for each feature space --> only used to get unique feature spaces for loop
    % min_components: Int: min componenets needed to make subplot
    % feature_filter: String with description for pcs
    %                 'all': keep all pcs after PCA
    %                 'pcs': Keep # of pcs set in feature_value
    %                 'percent_var': Use X# of PCs that meet set % in feature_value
    % feature_value: Int matched to feature_filter
    %                'all': left empty
    %                'pcs': Int for # of pcs to keep
    %                'percent_var': % of variance desired to be explained by pcs
    % save_png: Boolean: 1: save subplot as png as well 0: only save subplot as fig
    %% Output: There is no return. The graphs are saved directly to the path indicated by save_path

    %% Set up plotting parameters
    plot_rows = 2; plot_cols = 2;
    left_plot = 1; right_plot = 2; ventral_plot = 3; frontal_plot = 4;
    neutral_weight = [0 0 0]; % black
    neg_weight = [1 0 0]; % red
    pos_weight = [0 0 1]; % blue

    %% Get left and right brain mesh
    unique_mesh = fieldnames(mesh_struct);
    for mesh_i = 1:numel(unique_mesh)
        curr_mesh = unique_mesh{mesh_i};
        %% Determine orientation
        if contains(curr_mesh,'left')
            left_mesh = mesh_struct.(curr_mesh);
        elseif contains(curr_mesh,'right')
            right_mesh = mesh_struct.(curr_mesh);
        end
    end

    unique_spaces = fieldnames(label_log);
    parfor space_i = 1:numel(unique_spaces)
        curr_space = unique_spaces{space_i};

        coeff = component_results.(curr_space).coeff;
        %% Skip components with not enough features
        tot_components = size(coeff, 1);
        if tot_components < min_components
            continue
        elseif strcmpi(feature_filter, 'pcs') && feature_value < tot_components
            tot_components = feature_value;
            coeff = coeff(:, 1:feature_value);
        end

        for comp_i = 1:tot_components
            comp_coeff = coeff(:, comp_i);
            % Find electrode coordinates present in feature space
            [~, elec_cord_i] = ismember(component_results.(curr_space).elec_order, elec_struct.label);
            elec_pos = elec_struct.chanpos(elec_cord_i,:);

            %% Assign colors to color map
            color_map = zeros(size(coeff, 1), 3);
            pos_i = find(comp_coeff > 0);
            color_map(pos_i, :) = repmat(pos_weight, [numel(pos_i), 1]);
            neg_i = find(comp_coeff < 0);
            color_map(neg_i, :) = repmat(neg_weight, [numel(neg_i), 1]);
            neutral_i = find(comp_coeff == 0);
            color_map(neutral_i, :) = repmat(neutral_weight, [numel(neutral_i), 1]);

            elec_weights = rescale(abs(comp_coeff), 1, 250);

            %% Plotting
            space_fig = figure();
            %% Plot left view
            brain_view = [-90 0];
            scrollsubplot(plot_rows, plot_cols, left_plot);
            plot_brain(brain_view, left_mesh, right_mesh, elec_pos, elec_weights, color_map);

            %% Plot right view
            brain_view = [90 0];
            scrollsubplot(plot_rows, plot_cols, right_plot);
            plot_brain(brain_view, left_mesh, right_mesh, elec_pos, elec_weights, color_map);

            %% Plot ventral view
            brain_view = [180 -90];
            scrollsubplot(plot_rows, plot_cols, ventral_plot);
            plot_brain(brain_view, left_mesh, right_mesh, elec_pos, elec_weights, color_map);

            %% Plot frontal view
            brain_view = [0 0];
            scrollsubplot(plot_rows, plot_cols, frontal_plot);
            plot_brain(brain_view, left_mesh, right_mesh, elec_pos, elec_weights, color_map);

            %% Save subplot for feature space
            sgtitle([dir_name, ' PC ', num2str(comp_i), ' ', strrep(curr_space, '_', ' ')]);
            if save_png
                filename = [num2str(comp_i), '_', curr_space, '.png'];
                saveas(gcf, fullfile(save_path, filename));
            else
                filename = [num2str(comp_i), '_', curr_space, '.fig'];
                set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
                savefig(gcf, fullfile(save_path, filename));
            end
        end
    end
end

function [] = plot_brain(brain_view, left_mesh, right_mesh, elec_pos, elec_weights, color_map)
    ft_plot_mesh(left_mesh); ft_plot_mesh(right_mesh);
    alpha .2; hold on
    view(brain_view); material dull; lighting gouraud;
    scatter3(elec_pos(:,1), elec_pos(:,2), elec_pos(:,3), elec_weights, color_map, 'filled','MarkerEdgeColor','k')
end