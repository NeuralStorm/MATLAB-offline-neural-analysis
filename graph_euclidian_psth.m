function [] = graph_euclidian_psth(original_path, euclidian_path)
    
    euclidian_table = readtable(euclidian_path);


    x_bounds = [];
    y_bounds = [];

    %% Direct learning
    best_direct_learning_fig = figure('visible', 'on');

    early_prac_3_best = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal, 'PRAC03') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));
    disp(early_prac_3_best)
    late_prac_3_best = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal, 'PRAC03') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));

    early_ravi_19_best = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal, 'RAVI019') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));
    late_ravi_19_best = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal, 'RAVI019') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));

    early_ravi_20_best = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal, 'RAVI020') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));
    late_ravi_20_best = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal, 'RAVI020') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));

    early_tnc_16_best = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal, 'TNC16') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));
    late_tnc_16_best = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal, 'TNC16') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));
        
    hold on
    
    plot(early_prac_3_best, late_prac_3_best, 'dr', 'MarkerFaceColor', 'r', ...
        'DisplayName', 'Prac03 FRL');
    plot(early_ravi_19_best, late_ravi_19_best, 'sb', 'MarkerFaceColor', 'b', ...
        'DisplayName', 'RAVI19 LFS');
    plot(early_ravi_20_best, late_ravi_20_best, 'pg', 'MarkerFaceColor', 'g', ...
        'DisplayName', 'RAVI20 FRL');
    plot(early_tnc_16_best, late_tnc_16_best, 'ok', 'MarkerFaceColor', 'k', ...
        'DisplayName', 'TNC16 SRL');
    title('Direct best event learning');
    xlabel('Early (day 0)');
    ylabel('Best');

    r = refline(1,0);
    r.Annotation.LegendInformation.IconDisplayStyle = 'off';

    lg = legend;
    lg.Location = 'BestOutside';
    lg.Orientation = 'Horizontal';
    graph_name = ['direct_best_event_learning.png'];
    saveas(gcf, fullfile(original_path, graph_name));

    hold off

    
    % %% Direct learning
    direct_learning_fig = figure('visible', 'on');
    early_fast_slow_names = euclidian_table.animal(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));

    early_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));
    % early_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));

    early_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));
    % early_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));

    late_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));
    % late_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));

    late_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));
    % late_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));

    early_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));
    % early_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));

    early_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));
    % early_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));

    late_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));
    % late_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));


    late_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));
    % late_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));


        
    hold on
    for animal = 1:length(early_fast_slow_names)
        animal_name = early_fast_slow_names{animal};
        p = plot(early_right_fast_slow(animal), late_right_fast_slow(animal), 'Marker', 'd', 'LineStyle','none', ...
            'DisplayName', [animal_name, ' right fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        % e = errorbar(early_right_fast_slow(animal), late_right_fast_slow(animal), late_right_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        c = get(p,'Color');
        p = plot(early_left_fast_slow(animal), late_left_fast_slow(animal), 'Marker', 's', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' left fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_left_fast_slow(animal), late_left_fast_slow(animal), late_left_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_fast_right_left(animal), late_fast_right_left(animal), 'Marker', 'o', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_fast_right_left(animal), late_fast_right_left(animal), late_fast_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_slow_right_left(animal), late_slow_right_left(animal), 'Marker', 'p', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_slow_right_left(animal), late_slow_right_left(animal), late_slow_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        x_bounds = [x_bounds, xlim];
        y_bounds = [y_bounds, ylim];
        title('Direct learning');
        xlabel('Early (day 0)');
        ylabel('Best');
    end
    r = refline(1,0);
    r.Annotation.LegendInformation.IconDisplayStyle = 'off';
    hold off

    %% Direct non learning
    direct_non_learning_fig = figure('visible', 'on');

    early_fast_slow_names = euclidian_table.animal(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));
    
    early_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));
    % early_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));

    early_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));
    % early_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));

    late_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));
    % late_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));

    late_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));
    % late_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));

    early_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));
    % early_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));

    early_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));
    % early_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'direct'));

    late_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));
    % late_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));


    late_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));
    % late_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'direct'));
        
    hold on
    for animal = 1:length(early_fast_slow_names)
        animal_name = early_fast_slow_names{animal};
        p = plot(early_right_fast_slow(animal), late_right_fast_slow(animal), 'Marker', 'd', 'LineStyle','none', ...
            'DisplayName', [animal_name, ' right fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        % e = errorbar(early_right_fast_slow(animal), late_right_fast_slow(animal), late_right_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        c = get(p,'Color');
        p = plot(early_left_fast_slow(animal), late_left_fast_slow(animal), 'Marker', 's', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' left fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_left_fast_slow(animal), late_left_fast_slow(animal), late_left_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_fast_right_left(animal), late_fast_right_left(animal), 'Marker', 'o', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_fast_right_left(animal), late_fast_right_left(animal), late_fast_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_slow_right_left(animal), late_slow_right_left(animal), 'Marker', 'p', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_slow_right_left(animal), late_slow_right_left(animal), late_slow_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        x_bounds = [x_bounds, xlim];
        y_bounds = [y_bounds, ylim];
        title('Direct non-learning');
        xlabel('Early (day 0)');
        ylabel('Best');
    end
    r = refline(1,0);
    r.Annotation.LegendInformation.IconDisplayStyle = 'off';
    hold off
    
    %% indirect learning
    indirect_learning_fig = figure('visible', 'on');
    early_fast_slow_names = euclidian_table.animal(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    
    early_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    % early_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));

    early_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    % early_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));

    late_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
    % late_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));

    late_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
    % late_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));

    early_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    % early_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));

    early_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    % early_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));

    late_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
    % late_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));


    late_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
    % late_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
        
    hold on
    for animal = 1:length(early_fast_slow_names)
        animal_name = early_fast_slow_names{animal};
        p = plot(early_right_fast_slow(animal), late_right_fast_slow(animal), 'Marker', 'd', 'LineStyle','none', ...
            'DisplayName', [animal_name, ' right fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        % e = errorbar(early_right_fast_slow(animal), late_right_fast_slow(animal), late_right_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        c = get(p,'Color');
        p = plot(early_left_fast_slow(animal), late_left_fast_slow(animal), 'Marker', 's', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' left fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_left_fast_slow(animal), late_left_fast_slow(animal), late_left_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_fast_right_left(animal), late_fast_right_left(animal), 'Marker', 'o', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_fast_right_left(animal), late_fast_right_left(animal), late_fast_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_slow_right_left(animal), late_slow_right_left(animal), 'Marker', 'p', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_slow_right_left(animal), late_slow_right_left(animal), late_slow_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        x_bounds = [x_bounds, xlim];
        y_bounds = [y_bounds, ylim];
        title('Indirect learning');
        xlabel('Early (day 0)');
        ylabel('Best');
    end
    r = refline(1,0);
    r.Annotation.LegendInformation.IconDisplayStyle = 'off';
    hold off
    %% indirect non learning

    indirect_non_learning_fig = figure('visible', 'on');
    early_fast_slow_names = euclidian_table.animal(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
   
    early_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    % early_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));

    early_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    % early_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));

    late_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
    % late_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));

    late_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
    % late_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));

    early_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    % early_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));

    early_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    % early_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));

    late_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
    % late_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));


    late_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
    % late_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'non_learning') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
        
    hold on
    for animal = 1:length(early_fast_slow_names)
        animal_name = early_fast_slow_names{animal};
        p = plot(early_right_fast_slow(animal), late_right_fast_slow(animal), 'Marker', 'd', 'LineStyle','none', ...
            'DisplayName', [animal_name, ' right fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        % e = errorbar(early_right_fast_slow(animal), late_right_fast_slow(animal), late_right_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        c = get(p,'Color');
        p = plot(early_left_fast_slow(animal), late_left_fast_slow(animal), 'Marker', 's', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' left fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_left_fast_slow(animal), late_left_fast_slow(animal), late_left_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_fast_right_left(animal), late_fast_right_left(animal), 'Marker', 'o', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_fast_right_left(animal), late_fast_right_left(animal), late_fast_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_slow_right_left(animal), late_slow_right_left(animal), 'Marker', 'p', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_slow_right_left(animal), late_slow_right_left(animal), late_slow_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        x_bounds = [x_bounds, xlim];
        y_bounds = [y_bounds, ylim];
        title('Indirect non-learning');
        xlabel('Early (day 0)');
        ylabel('Best');
    end
    r = refline(1,0);
    r.Annotation.LegendInformation.IconDisplayStyle = 'off';
    hold off

    %% Control
    % control is only indirect

    control_fig = figure('visible', 'on');
    early_fast_slow_names = euclidian_table.animal(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    
    early_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    % early_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));

    early_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    % early_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));

    late_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
    % late_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));

    late_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
    % late_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));

    early_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    % early_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));

    early_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));
    % early_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region_type, 'indirect'));

    late_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
    % late_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));


    late_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
    % late_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region_type, 'indirect'));
        
    hold on
    for animal = 1:length(early_fast_slow_names)
        animal_name = early_fast_slow_names{animal};
        p = plot(early_right_fast_slow(animal), late_right_fast_slow(animal), 'Marker', 'd', 'LineStyle','none', ...
            'DisplayName', [animal_name, ' right fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        % e = errorbar(early_right_fast_slow(animal), late_right_fast_slow(animal), late_right_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        c = get(p,'Color');
        p = plot(early_left_fast_slow(animal), late_left_fast_slow(animal), 'Marker', 's', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' left fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_left_fast_slow(animal), late_left_fast_slow(animal), late_left_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_fast_right_left(animal), late_fast_right_left(animal), 'Marker', 'o', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_fast_right_left(animal), late_fast_right_left(animal), late_fast_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_slow_right_left(animal), late_slow_right_left(animal), 'Marker', 'p', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_slow_right_left(animal), late_slow_right_left(animal), late_slow_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        x_bounds = [x_bounds, xlim];
        y_bounds = [y_bounds, ylim];
        title('Control');
        xlabel('Early (day 0)');
        ylabel('Best');
    end
    r = refline(1,0);
    r.Annotation.LegendInformation.IconDisplayStyle = 'off';
    hold off

    right_control_fig = figure('visible', 'on');
    early_fast_slow_names = euclidian_table.animal(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'right'));
    
    early_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'right'));
    % early_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'right'));

    early_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'right'));
    % early_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'right'));

    late_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'right'));
    % late_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'right'));

    late_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'right'));
    % late_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'right'));

    early_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'right'));
    % early_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'right'));

    early_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'right'));
    % early_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'right'));

    late_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'right'));
    % late_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'right'));


    late_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'right'));
    % late_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'right'));
        
    hold on
    for animal = 1:length(early_fast_slow_names)
        animal_name = early_fast_slow_names{animal};
        p = plot(early_right_fast_slow(animal), late_right_fast_slow(animal), 'Marker', 'd', 'LineStyle','none', ...
            'DisplayName', [animal_name, ' right fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        % e = errorbar(early_right_fast_slow(animal), late_right_fast_slow(animal), late_right_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        c = get(p,'Color');
        p = plot(early_left_fast_slow(animal), late_left_fast_slow(animal), 'Marker', 's', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' left fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_left_fast_slow(animal), late_left_fast_slow(animal), late_left_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_fast_right_left(animal), late_fast_right_left(animal), 'Marker', 'o', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_fast_right_left(animal), late_fast_right_left(animal), late_fast_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_slow_right_left(animal), late_slow_right_left(animal), 'Marker', 'p', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_slow_right_left(animal), late_slow_right_left(animal), late_slow_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        x_bounds = [x_bounds, xlim];
        y_bounds = [y_bounds, ylim];
        title('Right Control');
        xlabel('Early (day 0)');
        ylabel('Best');
    end
    r = refline(1,0);
    r.Annotation.LegendInformation.IconDisplayStyle = 'off';
    hold off

    left_control_fig = figure('visible', 'on');
    early_fast_slow_names = euclidian_table.animal(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'left'));
    
    early_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'left'));
    % early_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'left'));

    early_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'left'));
    % early_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'left'));

    late_right_fast_slow = euclidian_table.right_fast_slow(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'left'));
    % late_right_fast_slow_std_err = euclidian_table.right_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'left'));

    late_left_fast_slow = euclidian_table.left_fast_slow(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'left'));
    % late_left_fast_slow_std_err = euclidian_table.left_fast_slow_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'left'));

    early_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'left'));
    % early_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'left'));

    early_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'left'));
    % early_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'early') & strcmpi(euclidian_table.region, 'left'));

    late_fast_right_left = euclidian_table.fast_right_left(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'left'));
    % late_fast_right_left_std_err = euclidian_table.fast_right_left_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'left'));


    late_slow_right_left = euclidian_table.slow_right_left(strcmpi(euclidian_table.animal_group, 'control') & ...
        strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'left'));
    % late_slow_right_left_std_err = euclidian_table.slow_right_left_std_err(strcmpi(euclidian_table.animal_group, 'control') & ...
    %     strcmpi(euclidian_table.day_type, 'late') & strcmpi(euclidian_table.region, 'left'));
        
    hold on
    for animal = 1:length(early_fast_slow_names)
        animal_name = early_fast_slow_names{animal};
        p = plot(early_right_fast_slow(animal), late_right_fast_slow(animal), 'Marker', 'd', 'LineStyle','none', ...
            'DisplayName', [animal_name, ' right fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        % e = errorbar(early_right_fast_slow(animal), late_right_fast_slow(animal), late_right_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        c = get(p,'Color');
        p = plot(early_left_fast_slow(animal), late_left_fast_slow(animal), 'Marker', 's', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' left fast slow']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_left_fast_slow(animal), late_left_fast_slow(animal), late_left_fast_slow_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_fast_right_left(animal), late_fast_right_left(animal), 'Marker', 'o', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_fast_right_left(animal), late_fast_right_left(animal), late_fast_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p = plot(early_slow_right_left(animal), late_slow_right_left(animal), 'Marker', 'p', 'Color', c, 'LineStyle','none', ...
            'DisplayName', [animal_name, ' fast right left']);
        set(p, 'MarkerFaceColor', get(p,'Color'));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % e = errorbar(early_slow_right_left(animal), late_slow_right_left(animal), late_slow_right_left_std_err(animal), 'k');
        % e.Annotation.LegendInformation.IconDisplayStyle = 'off';
        x_bounds = [x_bounds, xlim];
        y_bounds = [y_bounds, ylim];
        title('Left Control');
        xlabel('Early (day 0)');
        ylabel('Best');
    end
    r = refline(1,0);
    r.Annotation.LegendInformation.IconDisplayStyle = 'off';
    hold off

    % y_max = max(y_bounds);
    y_max = 1.6
    y_min = min(y_bounds);
    x_max = max(x_bounds);
    x_min = min(x_bounds);
    x_min = 0;
    y_min = 0;

    figure(direct_learning_fig);
    xlim([x_min, x_max]);
    ylim([y_min, y_max]);
    % hL1 = legend(h(1:l), legendInfo(1:l), <options>);
    % hL2 = legend(h(l+1:end), legendInfo(l+1:end), <options>);
    lg = legend;
    lg.Location = 'BestOutside';
    lg.Orientation = 'Horizontal';
    graph_name = ['learning_direct_euclidian_best.png'];
    saveas(gcf, fullfile(original_path, graph_name));
    graph_name = ['learning_direct_euclidian_best.svg'];
    saveas(gcf, fullfile(original_path, graph_name));

    figure(direct_non_learning_fig);
    xlim([x_min, x_max]);
    ylim([y_min, y_max]);
    lg = legend;
    lg.Location = 'BestOutside';
    lg.Orientation = 'Horizontal';
    graph_name = ['non_learning_direct_euclidian_best.png'];
    saveas(gcf, fullfile(original_path, graph_name));
    graph_name = ['non_learning_direct_euclidian_best.svg'];
    saveas(gcf, fullfile(original_path, graph_name));

    figure(indirect_learning_fig);
    xlim([x_min, x_max]);
    ylim([y_min, y_max]);
    lg = legend;
    lg.Location = 'BestOutside';
    lg.Orientation = 'Horizontal';
    graph_name = ['learning_indirect_euclidian_best.png'];
    saveas(gcf, fullfile(original_path, graph_name));
    graph_name = ['learning_indirect_euclidian_best.svg'];
    saveas(gcf, fullfile(original_path, graph_name));

    figure(indirect_non_learning_fig);
    xlim([x_min, x_max]);
    ylim([y_min, y_max]);
    lg = legend;
    lg.Location = 'BestOutside';
    lg.Orientation = 'Horizontal';
    graph_name = ['non_learning_indirect_euclidian_best.png'];
    saveas(gcf, fullfile(original_path, graph_name));
    graph_name = ['non_learning_indirect_euclidian_best.svg'];
    saveas(gcf, fullfile(original_path, graph_name));

    figure(control_fig);
    xlim([x_min, x_max]);
    ylim([y_min, y_max]);
    lg = legend;
    lg.Location = 'BestOutside';
    lg.Orientation = 'Horizontal';
    graph_name = ['control_euclidian_best.png'];
    saveas(gcf, fullfile(original_path, graph_name));
    graph_name = ['control_euclidian_best.svg'];
    saveas(gcf, fullfile(original_path, graph_name));

    figure(right_control_fig);
    xlim([x_min, x_max]);
    ylim([y_min, y_max]);
    lg = legend;
    lg.Location = 'BestOutside';
    lg.Orientation = 'Horizontal';
    graph_name = ['right_control_best.png'];
    saveas(gcf, fullfile(original_path, graph_name));
    graph_name = ['right_control_best.svg'];
    saveas(gcf, fullfile(original_path, graph_name));

    figure(left_control_fig);
    xlim([x_min, x_max]);
    ylim([y_min, y_max]);
    lg = legend;
    lg.Location = 'BestOutside';
    lg.Orientation = 'Horizontal';
    graph_name = ['left_control_best.png'];
    saveas(gcf, fullfile(original_path, graph_name));
    graph_name = ['left_control_best.svg'];
    saveas(gcf, fullfile(original_path, graph_name));
end