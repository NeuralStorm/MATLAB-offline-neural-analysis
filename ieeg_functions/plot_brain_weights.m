function [] = plot_brain_weights(save_path, mesh_struct, elec_struct, component_results, ...
        label_log, min_components, feature_filter, feature_value)

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
            [~, ia, ~] = intersect(elec_struct.label, component_results.(curr_space).elec_order);
            elec_pos = elec_struct.chanpos(ia,:);
    
            color_map = zeros(size(coeff, 1), 3);
            for r = 1:numel(comp_coeff)
                if comp_coeff(r) > 0
                    color_map(r, :) = pos_weight;
                elseif comp_coeff(r) < 0
                    color_map(r, :) = neg_weight;
                elseif comp_coeff(r) == 0
                    color_map(r, :) = neutral_weight;
                end
            end
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
            filename = [num2str(comp_i), '_', curr_space, '.fig'];
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
            savefig(gcf, fullfile(save_path, filename));
        end
    end
end

function [] = plot_brain(brain_view, left_mesh, right_mesh, elec_pos, elec_weights, color_map)
    ft_plot_mesh(left_mesh); ft_plot_mesh(right_mesh);
    alpha .2; hold on
    view(brain_view); material dull; lighting gouraud;
    scatter3(elec_pos(:,1), elec_pos(:,2), elec_pos(:,3), elec_weights, color_map, 'filled','MarkerEdgeColor','k')
end