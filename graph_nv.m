function [] = graph_nv(nv_list, event_strings, original_path)

    %% Colors
    max_color = 255;
    dark_green = [0 (102/max_color) 0];
    light_green = [(102/max_color) (153/max_color) 0];
    black = [0 0 0];
    burgandy = [(102/max_color) 0 0]; % burgandy
    orange = [(255/max_color) (51/max_color) 0]; % orange
    % purple = [(102/max_color) 0 (255/max_color)];
    % lavender = [(153/max_color) (153/max_color) (255/max_color)];    

    %% Animal categories
    learning = ['PRAC03', 'TNC16', 'RAVI19', 'RAVI20'];
    non_learning = ['LC02', 'TNC06', 'TNC12', 'TNC25'];
    control = ['TNC01', 'TNC03', 'TNC04', 'TNC14'];
    right_direct = ['RAVI19', 'PRAC03', 'LC02', 'TNC12'];
    left_direct = ['RAVI20', 'TNC16', 'TNC25', 'TNC06'];

    learn_avg_late_direct_nv = [];
    learn_avg_early_direct_nv = [];
    learn_std_late_direct_nv = [];
    learn_std_early_direct_nv = [];

    nonlearn_avg_late_direct_nv = [];
    nonlearn_avg_early_direct_nv = [];
    nonlearn_std_late_direct_nv = [];
    nonlearn_std_early_direct_nv = [];

    non_learn_nv = [];
    non_learn_names = [];
    learn_nv = [];
    learn_names = [];

    all_animals_fig = figure('visible', 'on');
    title('All animals')
    direct_learning_fig = figure('visible', 'on');
    title('Direct learning')
    direct_non_learning_fig = figure('visible', 'on');
    title('Direct non learning')
    indirect_learning_fig = figure('visible', 'on');
    title('Indirect learning')
    indirect_non_learning_fig = figure('visible', 'on');
    title('Indirect non learning')


    %% Preallocate fields
    for event = 1:length(event_strings)
        current_event = event_strings{event};
        %% Population
        nv_event_graphs.([current_event, '_learning_nv']) = [];
        nv_event_graphs.([current_event, '_non_learning_nv']) = [];
        nv_event_graphs.([current_event, '_learning_std_err']) = [];
        nv_event_graphs.([current_event, '_non_learning_std_err']) = [];
        nv_event_graphs.([current_event, '_indir_learning_nv']) = [];
        nv_event_graphs.([current_event, '_indir_non_learning_nv']) = [];
        nv_event_graphs.([current_event, '_indir_learning_std_err']) = [];
        nv_event_graphs.([current_event, '_indir_non_learning_std_err']) = [];
        nv_event_graphs.([current_event, '_indir_non_learning_std_err']) = [];
        %% Best and first
        nv_event_graphs.([current_event, '_dir_learning_bf']) = [];
        nv_event_graphs.([current_event, '_dir_non_learning_bf']) = [];
        nv_event_graphs.([current_event, '_indir_learning_bf']) = [];
        nv_event_graphs.([current_event, '_indir_non_learning_bf']) = [];
        %% T-test
        nv_event_graphs.([current_event, '_early_dir_learning_pop']) = [];
        nv_event_graphs.([current_event, '_early_indir_learning_pop']) = [];
        nv_event_graphs.([current_event, '_late_dir_learning_pop']) = [];
        nv_event_graphs.([current_event, '_late_indir_learning_pop']) = [];
        nv_event_graphs.([current_event, '_early_dir_non_learning_pop']) = [];
        nv_event_graphs.([current_event, '_early_indir_non_learning_pop']) = [];
        nv_event_graphs.([current_event, '_late_dir_non_learning_pop']) = [];
        nv_event_graphs.([current_event, '_late_indir_non_learning_pop']) = [];

        %% NV time function
        nv_event_graphs.([current_event, '_learning_time_fn']) = [];
        nv_event_graphs.([current_event, '_learning_time_fn']) = [];
        nv_event_graphs.([current_event, '_non_learning_time_fn']) = [];
        nv_event_graphs.([current_event, '_non_learning_time_fn']) = [];
    end

    %% Grabs the NVs from all animals to make bar graphs
    for file = 1:length(nv_list)
        current_file_path = nv_list{file};
        split_file_path = strsplit(current_file_path, '/');
        current_animal = split_file_path{end - 4};
        current_file = fullfile(current_file_path, [current_animal, '_norm_var_results.mat']);
        load(current_file);

        %% Skip control animals
        if contains(control, current_animal)
            continue;
        end

        %% Determine direct and indirect regions
        if contains(right_direct, current_animal)
            direct_region =  'Right';
            indirect_region = 'Left';
        else
            direct_region =  'Left';
            indirect_region = 'Right';
        end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%              Population                 %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Direct
        direct_first_nv = getfield(days_norm_var.(direct_region), 'first_norm_var');
        direct_best_nv = getfield(days_norm_var.(direct_region), 'best_norm_var');
        %% Indirect
        indirect_first_nv = getfield(days_norm_var.(indirect_region), 'first_norm_var');
        indirect_best_nv = getfield(days_norm_var.(indirect_region), 'best_norm_var');

        % Contains all events for the last 5 days
        early_direct_nv = getfield(days_norm_var.(direct_region), 'early_norm_var');
        late_direct_nv = getfield(days_norm_var.(direct_region), 'late_norm_var');
        early_indirect_nv = getfield(days_norm_var.(indirect_region), 'early_norm_var');
        late_indirect_nv = getfield(days_norm_var.(indirect_region), 'late_norm_var');

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%              first v best               %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        dir_first_nv = getfield(days_norm_var.(direct_region), 'first_norm_var');
        dir_best_nv = getfield(days_norm_var.(direct_region), 'best_norm_var');
        indir_first_nv = getfield(days_norm_var.(indirect_region), 'first_norm_var');
        indir_best_nv = getfield(days_norm_var.(indirect_region), 'best_norm_var');

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%                 T-test                  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        dir_early_pop = getfield(days_norm_var.(direct_region), 'early_pop');
        dir_late_pop = getfield(days_norm_var.(direct_region), 'late_pop');
        indir_early_pop = getfield(days_norm_var.(indirect_region), 'early_pop');
        indir_late_pop = getfield(days_norm_var.(indirect_region), 'late_pop');

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%              Population                 %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        dir_pop = getfield(days_norm_var.(direct_region), 'overall_pop');
        indir_pop = getfield(days_norm_var.(indirect_region), 'overall_pop');

        for event = 1:length(early_direct_nv(1,:))
            current_event = event_strings{event};

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%              first v best               %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            dir_first = dir_first_nv(:, event);
            dir_best = dir_first_nv(:, event);
            indir_first = indir_first_nv(:, event);
            indir_best = indir_first_nv(:, event);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%              Population                 %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            %% Early direct
            early_direct_event = early_direct_nv(:, event);
            avg_early_direct_event = mean(early_direct_event);
            std_early_direct_event = std(early_direct_event);
            std_err_early_direct_event = std_early_direct_event / (sqrt(length(early_direct_event)));
            % avg_early_nv = mean(early_direct_nv);
            % std_early_nv = std(early_direct_nv);
            
            %% Late direct
            late_direct_event = late_direct_nv(:, event);
            avg_late_direct_event = mean(late_direct_event);
            std_late_direct_event = std(late_direct_event);
            std_err_late_direct_event = std_late_direct_event / (sqrt(length(late_direct_event)));
            % avg_late_nv = mean(late_direct_nv);
            % std_late_nv = std(late_direct_nv);

            %% Early indirect
            early_indirect_event = early_indirect_nv(:, event);
            avg_early_indirect_event = mean(early_indirect_event);
            std_early_indirect_event = std(early_indirect_event);
            std_err_early_indirect_event = std_early_indirect_event / (sqrt(length(early_indirect_event)));

            %% Late indirect
            late_indirect_event = late_indirect_nv(:, event);
            avg_late_indirect_event = mean(late_indirect_event);
            std_late_indirect_event = std(late_indirect_event);
            std_err_late_indirect_event = std_late_indirect_event / (sqrt(length(late_indirect_event)));

            %% NV Time function
            event_dir_pop = dir_pop(:, event);
            event_indir_pop = indir_pop(:, event);

            if contains(learning, current_animal)
                %% Direct
                nv_event_graphs.([current_event, '_learning_nv']) = [nv_event_graphs.([current_event, '_learning_nv']), avg_early_direct_event, avg_late_direct_event];
                nv_event_graphs.([current_event, '_learning_std_err']) = [nv_event_graphs.([current_event, '_learning_std_err']), std_err_early_direct_event, std_err_late_direct_event];
                % learn_nv = [learn_nv, avg_early_nv, avg_late_nv];
                %% Indirect
                nv_event_graphs.([current_event, '_indir_learning_nv']) = [nv_event_graphs.([current_event, '_indir_learning_nv']), avg_early_indirect_event, avg_late_indirect_event];
                nv_event_graphs.([current_event, '_indir_learning_std_err']) = [nv_event_graphs.([current_event, '_indir_learning_std_err']), std_err_early_indirect_event, std_err_late_indirect_event];
                learn_names = [learn_names, {current_animal}];
                %% Best and first
                nv_event_graphs.([current_event, '_dir_learning_bf']) = [nv_event_graphs.([current_event, '_dir_learning_bf']), dir_first, dir_best];
                nv_event_graphs.([current_event, '_indir_learning_bf']) = [nv_event_graphs.([current_event, '_indir_learning_bf']), dir_first, dir_best];
                %% T-test
                nv_event_graphs.([current_event, '_early_dir_learning_pop']) = [nv_event_graphs.([current_event, '_early_dir_learning_pop']); dir_early_pop];
                nv_event_graphs.([current_event, '_early_indir_learning_pop']) = [nv_event_graphs.([current_event, '_early_indir_learning_pop']); indir_early_pop];
                nv_event_graphs.([current_event, '_late_dir_learning_pop']) = [nv_event_graphs.([current_event, '_late_dir_learning_pop']); dir_late_pop];
                nv_event_graphs.([current_event, '_late_indir_learning_pop']) = [nv_event_graphs.([current_event, '_late_indir_learning_pop']); indir_late_pop];
                %% NV time function
                nv_event_graphs.([current_event, '_learning_time_fn']) = [nv_event_graphs.([current_event, '_learning_time_fn']); event_dir_pop];
                nv_event_graphs.([current_event, '_learning_time_fn']) = [nv_event_graphs.([current_event, '_learning_time_fn']); event_indir_pop];
            else
                %% Direct
                nv_event_graphs.([current_event, '_non_learning_nv']) = [nv_event_graphs.([current_event, '_non_learning_nv']), avg_early_direct_event, avg_late_direct_event];
                nv_event_graphs.([current_event, '_non_learning_std_err']) = [nv_event_graphs.([current_event, '_non_learning_std_err']), std_err_early_direct_event, std_err_late_direct_event];
                % non_learn_nv = [non_learn_nv, avg_early_nv, avg_late_nv];
                %% Indirect
                nv_event_graphs.([current_event, '_indir_non_learning_nv']) = [nv_event_graphs.([current_event, '_indir_non_learning_nv']), avg_early_indirect_event, avg_late_indirect_event];
                nv_event_graphs.([current_event, '_indir_non_learning_std_err']) = [nv_event_graphs.([current_event, '_indir_non_learning_std_err']), std_err_early_indirect_event, std_err_late_indirect_event];
                non_learn_names = [non_learn_names, {current_animal}];
                %% Best and first
                nv_event_graphs.([current_event, '_dir_non_learning_bf']) = [nv_event_graphs.([current_event, '_indir_non_learning_bf']), indir_first, indir_best];
                nv_event_graphs.([current_event, '_indir_non_learning_bf']) = [nv_event_graphs.([current_event, '_indir_non_learning_bf']), indir_first, indir_best];
                %% T-test
                nv_event_graphs.([current_event, '_early_dir_non_learning_pop']) = [nv_event_graphs.([current_event, '_early_dir_non_learning_pop']); dir_early_pop];
                nv_event_graphs.([current_event, '_early_indir_non_learning_pop']) = [nv_event_graphs.([current_event, '_early_indir_non_learning_pop']); indir_early_pop];
                nv_event_graphs.([current_event, '_late_dir_non_learning_pop']) = [nv_event_graphs.([current_event, '_late_dir_non_learning_pop']); dir_late_pop];
                nv_event_graphs.([current_event, '_late_indir_non_learning_pop']) = [nv_event_graphs.([current_event, '_late_indir_non_learning_pop']); indir_late_pop];
                %% NV time function
                nv_event_graphs.([current_event, '_non_learning_time_fn']) = [nv_event_graphs.([current_event, '_non_learning_time_fn']); event_dir_pop];
                nv_event_graphs.([current_event, '_non_learning_time_fn']) = [nv_event_graphs.([current_event, '_non_learning_time_fn']); event_indir_pop];
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%              NV time fn                 %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if ~contains(control, current_animal) 
            figure(all_animals_fig)
            hold on
            plot(dir_pop(:, 1), dir_pop(:, 2), 'DisplayName', current_animal);
            hold off

            
            figure('visible', 'on');
            disp(current_event);
            plot(dir_pop(:, 1), dir_pop(:, 2));
            if contains(learning, current_animal)
                title([current_animal, 'Learning direct NV time function']);
                graph_file = fullfile(original_path, [current_animal, '_learning_dir_nv_time_fn']);
                
                figure(direct_learning_fig)
                hold on
                plot(dir_pop(:, 1), dir_pop(:, 2), 'DisplayName', current_animal);
                hold off
                
                figure(indirect_learning_fig)
                hold on
                plot(indir_pop(:, 1), indir_pop(:, 2), 'DisplayName', current_animal);
                hold off
            else
                title([current_animal, 'Non-learning direct NV time function']);
                graph_file = fullfile(original_path, [current_animal, '_non_learning_dir_nv_time_fn']);

                figure(direct_non_learning_fig)
                hold on
                plot(dir_pop(:, 1), dir_pop(:, 2), 'DisplayName', current_animal);
                hold off

                figure(indirect_non_learning_fig)
                hold on
                plot(indir_pop(:, 1), indir_pop(:, 2), 'DisplayName', current_animal);
                hold off
            end
            saveas(gcf, graph_file);

            figure('visible', 'on');
            plot(indir_pop(:, 1), indir_pop(:, 2));
            if contains(learning, current_animal)
                title([current_animal, 'Learning indirect NV time function']);
                graph_file = fullfile(original_path, [current_animal, '_learning_indir_nv_time_fn']);
            else
                title([current_animal, 'Non-learning indirect NV time function']);
                graph_file = fullfile(original_path, [current_animal, '_non_learning_indir_nv_time_fn']);
            end
            saveas(gcf, graph_file);
        end


    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%               Graphing                  %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for event = 1:length(event_strings)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%                 T-test                  %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [early_direct_learn_non_learn, early_direct_learn_non_learn_p_value, early_direct_learn_non_learn_ci, early_direct_learn_non_learn_stats] = ttest2(cell2mat(nv_event_graphs.([current_event, '_early_dir_learning_pop'])), cell2mat(nv_event_graphs.([current_event, '_early_dir_non_learning_pop'])));
        [late_direct_learn_non_learn, late_direct_learn_non_learn_p_value, late_direct_learn_non_learn_ci, late_direct_learn_non_learn_stats] = ttest2(cell2mat(nv_event_graphs.([current_event, '_late_dir_learning_pop'])), cell2mat(nv_event_graphs.([current_event, '_late_dir_non_learning_pop'])));
        [early_indirect_learn_non_learn, early_indirect_learn_non_learn_p_value, early_indirect_learn_non_learn_ci, early_indirect_learn_non_learn_stats] = ttest2(cell2mat(nv_event_graphs.([current_event, '_early_indir_learning_pop'])), cell2mat(nv_event_graphs.([current_event, '_early_indir_non_learning_pop'])));
        [late_indirect_learn_non_learn, late_indirect_learn_non_learn_p_value, late_indirect_learn_non_learn_ci, late_indirect_learn_non_learn_stats] = ttest2(cell2mat(nv_event_graphs.([current_event, '_late_indir_learning_pop'])), cell2mat(nv_event_graphs.([current_event, '_late_indir_non_learning_pop'])));
        
        
        %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %     %%              NV time fn                 %%
        %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % figure('visible', 'on');
        % current_event = event_strings{event};
        % disp(current_event);
        % % plot(test_pop(:, 1), test_pop(:, 2))
        % plot(nv_event_graphs.([current_event, '_learning_time_fn'])(:, 1), nv_event_graphs.([current_event, '_learning_time_fn'])(:, event));
        % graph_file = fullfile(original_path, [current_event, '_direct_learning_v_non_learning.png']);
        % saveas(gcf, graph_file);
        
        % %% Direct
        % figure('visible','on');
        % current_event = event_strings{event};
        % disp(current_event);
        % all_means = [nv_event_graphs.([current_event, '_learning_nv']); nv_event_graphs.([current_event, '_non_learning_nv'])];
        % all_std_error = [nv_event_graphs.([current_event, '_learning_std_err']); nv_event_graphs.([current_event, '_non_learning_std_err'])];
        % disp(all_means);
        % ax = axes;
        % b = bar(all_means, 'BarWidth', 1);
        % xticks(ax,[1 2]);
        % xticklabels(ax,{ 'Learning', 'Non-learning'});
        % hold on;

        % %% Adds error bars
        % groups = size(all_means, 1);
        % bars = size(all_means, 2);
        % groupwidth = min(0.8, bars/(bars + 1.5));
        % for k = 1:bars
        %     center = (1:groups) - groupwidth/2 + (2*k-1) * groupwidth / (2*bars);
        %     errorbar(center, all_means(:,k), all_std_error(:,k), 'k', 'linestyle', 'none');
        % end
        % current_graph = gca;
        % current_graph.Clipping = 'off';

        % for k = 1:size(all_means,2)
        %     if mod(k, 2) == 0
        %         b(k).FaceColor = dark_green;
        %         b(k-1).FaceColor = light_green;
        %     end
        % end


        % title([current_event, 'direct normalized variance between learning and non learning animals']);


        % %% Creates Legends
        % lg = legend('Early','Late');
        % legend('boxoff');
        % lg.Location = 'BestOutside';
        % lg.Orientation = 'Horizontal';
        % graph_file = fullfile(original_path, [current_event, '_direct_learning_v_non_learning.png']);
        % saveas(gcf, graph_file);
        % hold off;

        % %% Indirect
        % figure('visible','on');
        % current_event = event_strings{event};
        % disp(current_event);
        % all_means = [nv_event_graphs.([current_event, '_indir_learning_nv']); nv_event_graphs.([current_event, '_indir_non_learning_nv'])];
        % disp(all_means);
        % ax = axes;
        % b = bar(all_means, 'BarWidth', 1);
        % xticks(ax,[1 2]);
        % xticklabels(ax,{ 'Learning', 'Non-learning'});
        % hold on;

        % %% Adds error bars
        % groups = size(all_means, 1);
        % bars = size(all_means, 2);
        % groupwidth = min(0.8, bars/(bars + 1.5));
        % for k = 1:bars
        %     center = (1:groups) - groupwidth/2 + (2*k-1) * groupwidth / (2*bars);
        %     errorbar(center, all_means(:,k), all_std_error(:,k), 'k', 'linestyle', 'none');
        % end
        % current_graph = gca;
        % current_graph.Clipping = 'off';

        % for k = 1:size(all_means,2)
        %     if mod(k, 2) == 0
        %         b(k).FaceColor = dark_green;
        %         b(k-1).FaceColor = light_green;
        %     end
        % end


        % title([current_event, 'indirect normalized variance between learning and non learning animals']);


        % %% Creates Legends
        % lg = legend('Early','Late');
        % legend('boxoff');
        % lg.Location = 'BestOutside';
        % lg.Orientation = 'Horizontal';
        % hold off;

        % graph_file = fullfile(original_path, [current_event, '_indirect_learning_v_non_learning.png']);
        % saveas(gcf, graph_file);

        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % %%              first v best               %%
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % %% direct
        % figure('visible','on');
        % current_event = event_strings{event};
        % disp(current_event);
        % all_means = [nv_event_graphs.([current_event, '_dir_learning_bf']); nv_event_graphs.([current_event, '_dir_non_learning_bf'])];
        % disp(all_means);
        % ax = axes;
        % b = bar(all_means, 'BarWidth', 1);
        % xticks(ax,[1 2]);
        % xticklabels(ax,{ 'Learning', 'Non-learning'});
        % hold on;

        % current_graph = gca;
        % current_graph.Clipping = 'off';

        % for k = 1:size(all_means,2)
        %     if mod(k, 2) == 0
        %         b(k).FaceColor = [1 0 0]; % red
        %         b(k-1).FaceColor = [0 0 1]; % blue
        %     end
        % end


        % title([current_event, 'direct first vs best']);


        % %% Creates Legends
        % lg = legend('first','best');
        % legend('boxoff');
        % lg.Location = 'BestOutside';
        % lg.Orientation = 'Horizontal';
        % graph_file = fullfile(original_path, [current_event, '_direct_first_v_best.png']);
        % saveas(gcf, graph_file);
        % hold off;
        
        % %% indirect
        % figure('visible','on');
        % current_event = event_strings{event};
        % disp(current_event);
        % all_means = [nv_event_graphs.([current_event, '_indir_learning_bf']); nv_event_graphs.([current_event, '_indir_non_learning_bf'])];
        % disp(all_means);
        % ax = axes;
        % b = bar(all_means, 'BarWidth', 1);
        % xticks(ax,[1 2]);
        % xticklabels(ax,{ 'Learning', 'Non-learning'});
        % hold on;

        % current_graph = gca;
        % current_graph.Clipping = 'off';

        % for k = 1:size(all_means,2)
        %     if mod(k, 2) == 0
        %         b(k).FaceColor = [1 0 0]; % red
        %         b(k-1).FaceColor = [0 0 1]; % blue
        %     end
        % end


        % title([current_event, 'indirect first vs best']);


        % %% Creates Legends
        % lg = legend('first','best');
        % legend('boxoff');
        % lg.Location = 'BestOutside';
        % lg.Orientation = 'Horizontal';
        % graph_file = fullfile(original_path, [current_event, '_indirect_first_v_best.png']);
        % saveas(gcf, graph_file);
        % hold off;

    end

    figure(all_animals_fig)
    legend
    figure(direct_learning_fig)
    legend
    figure(indirect_learning_fig)
    legend
    figure(direct_non_learning_fig);
    legend
    figure(indirect_non_learning_fig)
    legend

    matfile = fullfile(original_path, 'test.mat');
    save(matfile, 'nv_event_graphs', 'early_direct_learn_non_learn', 'late_direct_learn_non_learn', 'early_indirect_learn_non_learn', 'late_indirect_learn_non_learn', ...
    'late_direct_learn_non_learn_p_value', 'late_direct_learn_non_learn_ci', 'late_direct_learn_non_learn_stats', 'early_indirect_learn_non_learn_p_value', 'early_indirect_learn_non_learn_ci', 'early_indirect_learn_non_learn_stats');
end