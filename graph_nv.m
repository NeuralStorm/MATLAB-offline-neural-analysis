function [matfile] = graph_nv(nv_list, event_strings, original_path)
    % NV = norm_var = normalized variance

    %% Animal categories
    learning = ['PRAC03', 'TNC16', 'RAVI19', 'RAVI20'];
    non_learning = ['LC02', 'TNC06', 'TNC12', 'TNC25'];
    control = ['TNC01', 'TNC03', 'TNC04', 'TNC14'];
    right_direct = ['RAVI19', 'PRAC03', 'LC02', 'TNC12'];
    left_direct = ['RAVI20', 'TNC16', 'TNC25', 'TNC06'];

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

    csv_data = [];
    pop_csv_data = [];
    early_late_bar_info = [];


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

        for region = 1:length(unique_regions)
            region_name = unique_regions{region};
            repeat_length = length(days_norm_var.(region_name).all_nv_info);
            pop_repeat_length = length(days_norm_var.(region_name).all_days_avg_norm_var);
            %% Labels regions as direct or indirect
            if (contains(right_direct, current_animal) && strcmpi('Right', region_name)) || (contains(left_direct, current_animal) && strcmpi('Left', region_name))
                region_type = 'Direct';
            else
                region_type = 'Indirect';
            end
            %% Labels animal as learning, non learning, or control
            if contains(control, current_animal)
                animal_type = 'Control';
            elseif contains(learning, current_animal)
                animal_type = 'Learning';
            else
                animal_type = 'Non-learning';
            end

            csv_data = [csv_data; days_norm_var.(region_name).all_nv_info, repmat({region_name}, [repeat_length, 1]), repmat({region_type}, [repeat_length, 1]), repmat({animal_type}, [repeat_length, 1])];
            pop_csv_data = [pop_csv_data; days_norm_var.(region_name).all_days_avg_norm_var, repmat({region_name}, [pop_repeat_length, 1]), repmat({region_type}, [pop_repeat_length, 1]), ...
                repmat({animal_type}, [pop_repeat_length, 1])];


            repeat_length = length(days_norm_var.(region_name).early_late_bar_info(:,1));
            early_late_bar_info = [early_late_bar_info; days_norm_var.(region_name).early_late_bar_info, repmat({region_name}, [repeat_length, 1]), repmat({region_type}, [repeat_length, 1]), repmat({animal_type}, [repeat_length, 1])];
        end

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

        % Contains all events for the first (early) and last (late) 5 days

        %% Early/Late NV with mean of neurons per day ((AVG NV * 5 days) X events)
        early_direct_nv = days_norm_var.(direct_region).early_norm_var;
        late_direct_nv = days_norm_var.(direct_region).late_norm_var;
        early_indirect_nv = days_norm_var.(indirect_region).early_norm_var;
        late_indirect_nv = days_norm_var.(indirect_region).late_norm_var;

        %% Early/Late with all neurons ((neurons NV * 5 days) X events)
        dir_early_pop = days_norm_var.(direct_region).early_pop;
        dir_late_pop = days_norm_var.(direct_region).late_pop;
        indir_early_pop = days_norm_var.(indirect_region).early_pop;
        indir_late_pop = days_norm_var.(indirect_region).late_pop;

        %% Entire neuron NV population across days ((AVG NV * total days) x (day num and events)
        dir_pop = days_norm_var.(direct_region).overall_pop;
        indir_pop = days_norm_var.(indirect_region).overall_pop;

        for event = 1:length(early_direct_nv(1,:))
            current_event = event_strings{event};

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%              Population                 %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            %% Early direct
            early_direct_event = early_direct_nv(:, event);
            avg_early_direct_event = mean(early_direct_event);
            std_early_direct_event = std(early_direct_event);
            std_err_early_direct_event = std_early_direct_event / (sqrt(length(early_direct_event)));
            
            %% Late direct
            late_direct_event = late_direct_nv(:, event);
            avg_late_direct_event = mean(late_direct_event);
            std_late_direct_event = std(late_direct_event);
            std_err_late_direct_event = std_late_direct_event / (sqrt(length(late_direct_event)));

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
                %% Indirect
                nv_event_graphs.([current_event, '_indir_learning_nv']) = [nv_event_graphs.([current_event, '_indir_learning_nv']), avg_early_indirect_event, avg_late_indirect_event];
                nv_event_graphs.([current_event, '_indir_learning_std_err']) = [nv_event_graphs.([current_event, '_indir_learning_std_err']), std_err_early_indirect_event, std_err_late_indirect_event];
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
                %% Indirect
                nv_event_graphs.([current_event, '_indir_non_learning_nv']) = [nv_event_graphs.([current_event, '_indir_non_learning_nv']), avg_early_indirect_event, avg_late_indirect_event];
                nv_event_graphs.([current_event, '_indir_non_learning_std_err']) = [nv_event_graphs.([current_event, '_indir_non_learning_std_err']), std_err_early_indirect_event, std_err_late_indirect_event];
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
        %%           NV time fn Graphs             %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if ~contains(control, current_animal) 
            figure(all_animals_fig)
            hold on
            plot(dir_pop(:, 1), dir_pop(:, 2), 'DisplayName', current_animal);
            hold off

            if contains(learning, current_animal)
                figure(direct_learning_fig)
                hold on
                plot(dir_pop(:, 1), dir_pop(:, 2), 'DisplayName', current_animal);
                hold off
                
                figure(indirect_learning_fig)
                hold on
                plot(indir_pop(:, 1), indir_pop(:, 2), 'DisplayName', current_animal);
                hold off
            else
                figure(direct_non_learning_fig)
                hold on
                plot(dir_pop(:, 1), dir_pop(:, 2), 'DisplayName', current_animal);
                hold off

                figure(indirect_non_learning_fig)
                hold on
                plot(indir_pop(:, 1), indir_pop(:, 2), 'DisplayName', current_animal);
                hold off
            end
        end


    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%                 T-test                  %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ttest2 can also return p-value, ci, and the stats struct results
    % Add those to the outputs and save them at the end to see desired stat results
    for event = 1:length(event_strings)
        early_direct_learn_non_learn_ttest = ...
            ttest2(cell2mat(nv_event_graphs.([current_event, '_early_dir_learning_pop'])), cell2mat(nv_event_graphs.([current_event, '_early_dir_non_learning_pop'])));
        late_direct_learn_non_learn_ttest = ...
            ttest2(cell2mat(nv_event_graphs.([current_event, '_late_dir_learning_pop'])), cell2mat(nv_event_graphs.([current_event, '_late_dir_non_learning_pop'])));
        early_indirect_learn_non_learn_ttest = ...
            ttest2(cell2mat(nv_event_graphs.([current_event, '_early_indir_learning_pop'])), cell2mat(nv_event_graphs.([current_event, '_early_indir_non_learning_pop'])));
        late_indirect_learn_non_learn_ttest = ...
            ttest2(cell2mat(nv_event_graphs.([current_event, '_late_indir_learning_pop'])), cell2mat(nv_event_graphs.([current_event, '_late_indir_non_learning_pop'])));
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

    spreadsheet_table = cell2table(csv_data, 'VariableNames',{'Animal' 'Animal_ID' 'exp_date' 'exp_day' 'pre_time' 'post_time', 'bin_size' 'norm_var_constant' 'epsilon' ...
        'channel' 'event_1_nv' 'event_2_nv' 'event_3_nv' 'event_4_nv' 'region' 'region_type' 'animal_type'});
    matfile = fullfile(original_path, 'unit_nv_analysis.csv');
    writetable(spreadsheet_table, matfile, 'Delimiter', ',');

    pop_spreadsheet_table = cell2table(pop_csv_data, 'VariableNames',{'Animal' 'Animal_ID' 'exp_date' 'exp_day' 'pre_time' 'post_time', 'bin_size' 'norm_var_constant' 'epsilon' ...
        'event_1_nv' 'event_2_nv' 'event_3_nv' 'event_4_nv' 'event_1_std' 'event_2_std' 'event_3_std' 'event_4_std' 'event_1_std_err' 'event_2_std_err' 'event_3_std_err' ...
        'event_4_std_err' 'region' 'region_type' 'animal_type'});
    matfile = fullfile(original_path, 'pop_nv_analysis.csv');
    writetable(pop_spreadsheet_table, matfile, 'Delimiter', ',');

    early_late_raw_info = cell2table(early_late_bar_info, 'VariableNames', {'Animal' 'Animal_ID' 'early_event_1_nv' 'early_event_2_nv' 'early_event_3_nv' 'early_event_4_nv' ...
        'late_event_1_nv' 'late_event_2_nv' 'late_event_3_nv' 'late_event_4_nv' 'region' 'region_type' 'animal_type'});

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%            Group NV Graph               %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    day_nv_table = varfun(@(x) mean(x, 'omitnan'), pop_spreadsheet_table, 'GroupingVariables', {'exp_day', 'animal_type', 'region_type'}, ...
        'InputVariables', {'event_1_nv', 'event_1_std', 'event_1_std_err'});
    
    mystats = @(x)[mean(x, 'omitnan') std(x, 'omitnan') (std(x, 'omitnan')/sqrt(length(x)))];
    
    all_day_nv_table = varfun(mystats, pop_spreadsheet_table, 'GroupingVariables', {'exp_day', 'animal_type', 'region_type'}, ...
        'InputVariables', 'event_1_nv')
        
    early_late_table = varfun(mystats, early_late_raw_info, 'GroupingVariables', {'animal_type', 'region_type'}, ...
        'InputVariables', {'early_event_1_nv', 'early_event_2_nv', 'early_event_3_nv', 'early_event_4_nv', 'late_event_1_nv', 'late_event_2_nv', 'late_event_3_nv', 'late_event_4_nv'})

    matfile = fullfile(original_path, 'group_nv_results.mat');
    save(matfile, 'csv_data', 'nv_event_graphs', 'day_nv_table', 'all_day_nv_table', 'early_late_bar_info', 'early_late_table', 'early_direct_learn_non_learn_ttest', ...
        'late_direct_learn_non_learn_ttest', 'early_indirect_learn_non_learn_ttest', 'late_indirect_learn_non_learn_ttest');
end