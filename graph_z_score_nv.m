function [] = graph_z_score_nv(group_nv_path)
    load(group_nv_path, 'unit_table', 'unique_regions');
    all_z_norm_var = zeros(height(unit_table), 1);
    for region = 1:length(unique_regions)
        region_name = unique_regions{region};
        animal_names = unique(unit_table.complete_animal_name(:));
        for animal = 1:length(animal_names)
            current_animal = animal_names{animal};
            %% Calculate baseline avergae and standard deviation for each animal for each region
            baseline_avg = mean(unit_table.norm_var(strcmpi(unit_table.complete_animal_name, current_animal) ...
                & strcmpi(unit_table.region, region_name) & unit_table.exp_day == 0, 1));
            baseline_std = std(unit_table.norm_var(strcmpi(unit_table.complete_animal_name, current_animal) ...
                & strcmpi(unit_table.region, region_name) & unit_table.exp_day == 0, 1));
            all_neurons = unit_table.norm_var(strcmpi(unit_table.complete_animal_name, current_animal) ...
                & strcmpi(unit_table.region, region_name));
            z_neurons = (all_neurons - baseline_avg) / baseline_std;
            all_z_norm_var((strcmpi(unit_table.complete_animal_name, current_animal) & strcmpi(unit_table.region, region_name))) = z_neurons;
        end
    end

    new_unit_table = addvars(unit_table, all_z_norm_var);

    days = unique(unit_table.exp_day(:));
    % disp(days)
    learning_direct_z = [];
    learning_indirect_z = [];
    non_learning_direct_z = [];
    non_learning_indirect_z = [];
    control_z = [];
    for day = 1:length(days)
        current_day = days(day);
        
        z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'learning') & strcmpi(new_unit_table.region_type, 'direct') & new_unit_table.exp_day == current_day);
        avg_day_z = mean(z_score_values, 'omitnan');
        std_err_day_z = std(z_score_values, 'omitnan') / sqrt(length(z_score_values));
        learning_direct_z = [learning_direct_z; current_day, avg_day_z, std_err_day_z];

        z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'learning') & strcmpi(new_unit_table.region_type, 'indirect') & new_unit_table.exp_day == current_day);
        avg_day_z = mean(z_score_values, 'omitnan');
        std_err_day_z = std(z_score_values, 'omitnan') / sqrt(length(z_score_values));
        learning_indirect_z = [learning_indirect_z; current_day, avg_day_z, std_err_day_z];

        z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'non-learning') & strcmpi(new_unit_table.region_type, 'direct') & new_unit_table.exp_day == current_day);
        avg_day_z = mean(z_score_values, 'omitnan');
        std_err_day_z = std(z_score_values, 'omitnan') / sqrt(length(z_score_values));
        non_learning_direct_z = [non_learning_direct_z; current_day, avg_day_z, std_err_day_z];

        z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'non-learning') & strcmpi(new_unit_table.region_type, 'indirect') & new_unit_table.exp_day == current_day);
        avg_day_z = mean(z_score_values, 'omitnan');
        std_err_day_z = std(z_score_values, 'omitnan') / sqrt(length(z_score_values));
        non_learning_indirect_z = [non_learning_indirect_z; current_day, avg_day_z, std_err_day_z];

        z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'control') & new_unit_table.exp_day == current_day);
        avg_day_z = mean(z_score_values, 'omitnan');
        std_err_day_z = std(z_score_values, 'omitnan') / sqrt(length(z_score_values));
        control_z = [control_z; current_day, avg_day_z, std_err_day_z];

    end

    %% Learning early/late direct
    z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'learning') & strcmpi(new_unit_table.region_type, 'direct') & new_unit_table.exp_day >= 1 & new_unit_table.exp_day <= 5);
    early_learning_direct_avg = mean(z_score_values);
    early_learning_direct_std_err = std(z_score_values) / sqrt(length(z_score_values));

    z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'learning') & strcmpi(new_unit_table.region_type, 'direct') & new_unit_table.exp_day >= 21 & new_unit_table.exp_day <= 25);
    late_learning_direct_avg = mean(z_score_values);
    late_learning_direct_std_err = std(z_score_values) / sqrt(length(z_score_values));

    %% Learning early/late indirect
    z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'learning') & strcmpi(new_unit_table.region_type, 'indirect') & new_unit_table.exp_day >= 1 & new_unit_table.exp_day <= 5);
    early_learning_indirect_avg = mean(z_score_values);
    early_learning_indirect_std_err = std(z_score_values) / sqrt(length(z_score_values));

    z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'learning') & strcmpi(new_unit_table.region_type, 'indirect') & new_unit_table.exp_day >= 21 & new_unit_table.exp_day <= 25);
    late_learning_indirect_avg = mean(z_score_values);
    late_learning_indirect_std_err = std(z_score_values) / sqrt(length(z_score_values));

    %% Non-Learning early/late direct
    z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'non-learning') & strcmpi(new_unit_table.region_type, 'direct') & new_unit_table.exp_day >= 1 & new_unit_table.exp_day <= 5);
    early_non_learning_direct_avg = mean(z_score_values);
    early_non_learning_direct_std_err = std(z_score_values) / sqrt(length(z_score_values));

    z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'non-learning') & strcmpi(new_unit_table.region_type, 'direct') & new_unit_table.exp_day >= 21 & new_unit_table.exp_day <= 25);
    late_non_learning_direct_avg = mean(z_score_values);
    late_non_learning_direct_std_err = std(z_score_values) / sqrt(length(z_score_values));

    %% Non-Learning early/late indirect
    z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'non-learning') & strcmpi(new_unit_table.region_type, 'indirect') & new_unit_table.exp_day >= 1 & new_unit_table.exp_day <= 5);
    early_non_learning_indirect_avg = mean(z_score_values);
    early_non_learning_indirect_std_err = std(z_score_values) / sqrt(length(z_score_values));

    z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'non-learning') & strcmpi(new_unit_table.region_type, 'indirect') & new_unit_table.exp_day >= 21 & new_unit_table.exp_day <= 25);
    late_non_learning_indirect_avg = mean(z_score_values);
    late_non_learning_indirect_std_err = std(z_score_values) / sqrt(length(z_score_values));

    %% Control early/late
    z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'control') & strcmpi(new_unit_table.region_type, 'indirect') & new_unit_table.exp_day >= 1 & new_unit_table.exp_day <= 5);
    early_control_avg = mean(z_score_values);
    early_control_std_err = std(z_score_values) / sqrt(length(z_score_values));

    z_score_values = new_unit_table.all_z_norm_var(strcmpi(new_unit_table.animal_type, 'control') & strcmpi(new_unit_table.region_type, 'indirect') & new_unit_table.exp_day >= 21 & new_unit_table.exp_day <= 25);
    late_control_avg = mean(z_score_values);
    late_control_std_err = std(z_score_values) / sqrt(length(z_score_values));

    [file_path, ~, ~] = fileparts(group_nv_path);
    matfile = fullfile(file_path, 'z_unit_table.mat');
    save(matfile, 'new_unit_table', 'learning_direct_z', 'learning_indirect_z', 'non_learning_direct_z', 'non_learning_indirect_z', 'control_z');

    matfile = fullfile(file_path, 'z_unit_table.csv');
    writetable(new_unit_table, matfile, 'Delimiter', ',');



    % learning animals
    direct_x=learning_direct_z(:,1);  % x-values used in plotting 
    direct_y=learning_direct_z(:,2); % y-values used in plotting 
%  disp(learning_direct_nv);
    direct_e=learning_direct_z(:,3); % error bar-values used in plotting
    disp(direct_e)
    
    % learning animals
    indirect_x=learning_indirect_z(:,1); % x-values used in plotting 
    indirect_y=learning_indirect_z(:,2); % y-values used in plotting 
    indirect_e=learning_indirect_z(:,3); % error bar-values used in plotting 
    
    % control animals 
    control_x=control_z(:,1); % x-values used in plotting 
    control_y=control_z(:,2); % y-values used in plotting 
    control_e=control_z(:,3); % error bar-values used in plotting 

    %% Plot figure 

    % generate line with shading
    % close
    figure
    hold on;
    plot(direct_x, direct_y, 'Color', 'r', 'LineWidth', 4);
    plot(indirect_x, indirect_y, 'Color', 'b', 'LineWidth', 4);
    plot(control_x, control_y, 'Color', 'k', 'LineWidth', 4);
    transparency=0.2; % transparency of background
    [l,p] = boundedline(direct_x, direct_y, direct_e, ...
        indirect_x, indirect_y, indirect_e, 'b', control_x, control_y, control_e, ...
        'cmap', [[1 0 0]; [0 0 1]; [0 0 0]],...
        'transparency', transparency);


    % figure properties 
    innerlineWidth=3;  % width of mean line 

    % apply properties to all lines in figure 
    for lineProperty=1:length(l)
        l(lineProperty).LineWidth=innerlineWidth;
    end

    % axis labels 
    % ylabel('Performance Change');
    xlabel('Time (Days)');
    ylabel('Z-Score');
%  axis tight;
    ax = axis;

    learning_ylim =  ylim;

    %% Legend
    lg = legend('direct','indirect','Control');
    legend('boxoff');
    lg.Location = 'BestOutside';
    lg.Orientation = 'Horizontal';

    title('Learning Z-Score NV');

    ylim([-0.50 14.5]);
    yticks([-0.50, 0, 14.5]);
    ytickformat('%.2f')
    hold off
    graph_name = 'line_Z_learn.png';
    saveas(gcf, fullfile(file_path, graph_name));
    graph_name = 'line_Z_learn.svg';
    saveas(gcf, fullfile(file_path, graph_name));

    


    % non-learning animals
    direct_x=non_learning_direct_z(:,1);  % x-values used in plotting 
    direct_y=non_learning_direct_z(:,2); % y-values used in plotting 
    direct_e=non_learning_direct_z(:,3); % error bar-values used in plotting 
    
    % learning animals
    indirect_x=non_learning_indirect_z(:,1); % x-values used in plotting 
    indirect_y=non_learning_indirect_z(:,2); % y-values used in plotting 
    indirect_e=non_learning_indirect_z(:,3); % error bar-values used in plotting  

    non_learn_y_global_min = min([min(direct_y + direct_e), min(indirect_y + indirect_e), min(control_y + control_e)]);
    non_learn_y_global_max = max([max(direct_y + direct_e), max(indirect_y + indirect_e), max(control_y + control_e)]);
    non_learn_y_midpoint = (non_learn_y_global_min)/2;

    figure
    hold on;
    plot(direct_x, direct_y, 'Color', 'r', 'LineWidth', 4);
    plot(indirect_x, indirect_y, 'Color', 'b', 'LineWidth', 4);
    plot(control_x, control_y, 'Color', 'k', 'LineWidth', 4);
    transparency=0.2; % transparency of background
    [l,p] = boundedline(direct_x, direct_y, direct_e, ...
        indirect_x, indirect_y, indirect_e, 'b', control_x, control_y, control_e, ...
        'cmap', [[1 0 0]; [0 0 1]; [0 0 0]],...
        'transparency', transparency);


    % figure properties 
    innerlineWidth=3;  % width of mean line 

    % apply properties to all lines in figure 
    for lineProperty=1:length(l)
        l(lineProperty).LineWidth=innerlineWidth;
    end

    % axis labels 
    % ylabel('Performance Change');
    xlabel('Time (Days)');
    ylabel('Z-Score');
    axis tight;
    non_learning_ylims = ylim;
    ax = axis;
    %% Legend
    lg = legend('direct','indirect','Control');
    legend('boxoff');
    lg.Location = 'BestOutside';
    lg.Orientation = 'Horizontal';

    title('Non Learning Z-Score NV');
    ylim([-0.50 14.5]);
    yticks([-0.50, 0, 14.5]);
    ytickformat('%.2f')
    hold off
    graph_name = 'line_Z_non_learn.png';
    saveas(gcf, fullfile(file_path, graph_name));
    graph_name = 'line_Z_non_learn.svg';
    saveas(gcf, fullfile(file_path, graph_name));

    figure

    all_means = [early_learning_direct_avg early_learning_indirect_avg early_control_avg; late_learning_direct_avg late_learning_indirect_avg late_control_avg];
    all_std = [early_learning_direct_std_err early_learning_indirect_std_err early_control_std_err; late_learning_direct_std_err late_learning_indirect_std_err late_control_std_err];
    upper_bounds = all_means + all_std;
    lower_bounds = all_means - all_std;
    categories = categorical({'Early','Late'});

    ax = axes;
    b = bar(all_means, 'BarWidth', 1);
    xticks(ax,[1 2]);
    xticklabels(ax,{ 'Early', 'Late'});

    hold on;
    %% Adds error bars
    groups = size(all_means, 1);
    bars = size(all_means, 2);
    groupwidth = min(0.8, bars/(bars + 1.5));
    for k = 1:bars
        center = (1:groups) - groupwidth/2 + (2*k-1) * groupwidth / (2*bars);
        errorbar(center, all_means(:,k), all_std(:,k), 'k', 'linestyle', 'none');
    end
    current_graph = gca;
    current_graph.Clipping = 'off';



    %% Sets colors for bars
    for k = 1:size(all_means,2)
        if mod(k, 3) == 0
            b(k).FaceColor = [0 0 0];
            b(k-1).FaceColor = [0 0 1];
            b(k-2).FaceColor = [1 0 0];
        end
    end

    %% Creates Legends
    lg = legend('Direct','Indirect','Control');
    legend('boxoff');
    lg.Location = 'BestOutside';
    lg.Orientation = 'Horizontal';

    title('Learn Z Early Late');
    ylabel('Normalized Variance');
    % ylim(ax, [floor(learning_ylim(1)) ceil(learning_ylim(2))]);
    % yticks(ax, [floor(learning_ylim(1)) 0 ceil(learning_ylim(2))]);
    ylim([-0.50 14.5]);
    yticks([-0.50, 0, 14.5]);
    ytickformat('%.2f')
    hold off;
    graph_name = 'bar_z_learn.png';
    saveas(gcf, fullfile(file_path, graph_name));
    graph_name = 'bar_z_learn.svg';
    saveas(gcf, fullfile(file_path, graph_name));

    %% Nonlearn
    figure
    all_means = [early_non_learning_direct_avg early_non_learning_indirect_avg early_control_avg; late_non_learning_direct_avg late_non_learning_indirect_avg late_control_avg];
    all_std = [early_non_learning_direct_std_err early_non_learning_indirect_std_err early_control_std_err; late_non_learning_direct_std_err late_non_learning_indirect_std_err late_control_std_err];
    upper_bounds = all_means + all_std;
    lower_bounds = all_means - all_std;
    categories = categorical({'Early','Late'});

    ax = axes;
    b = bar(all_means, 'BarWidth', 1);
    xticks(ax,[1 2]);
    xticklabels(ax,{ 'Early', 'Late'});

    hold on;
    %% Adds error bars
    groups = size(all_means, 1);
    bars = size(all_means, 2);
    groupwidth = min(0.8, bars/(bars + 1.5));
    for k = 1:bars
        center = (1:groups) - groupwidth/2 + (2*k-1) * groupwidth / (2*bars);
        errorbar(center, all_means(:,k), all_std(:,k), 'k', 'linestyle', 'none');
    end
    current_graph = gca;
    current_graph.Clipping = 'off';



    %% Sets colors for bars
    for k = 1:size(all_means,2)
        if mod(k, 3) == 0
            b(k).FaceColor = [0 0 0];
            b(k-1).FaceColor = [0 0 1];
            b(k-2).FaceColor = [1 0 0];
        end
    end

    %% Creates Legends
    lg = legend('Direct','Indirect','Control');
    legend('boxoff');
    lg.Location = 'BestOutside';
    lg.Orientation = 'Horizontal';

    title('NONLearn Z');
    ylabel('Normalized Variance');
    % ylim(ax, [-0.50 (non_learning_ylims(2))]);
    % yticks(ax, [-0.50 0 (non_learning_ylims(2))]);
    ylim([-0.50 14.5]);
    yticks([-0.50, 0, 14.5]);
    ytickformat('%.2f')
    hold off;
    graph_name = 'bar_z_non_learn.png';
    saveas(gcf, fullfile(file_path, graph_name));
    graph_name = 'bar_z_non_learn.svg';
    saveas(gcf, fullfile(file_path, graph_name));

end