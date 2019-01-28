function [] = z_score_nv(csv_path, pre_time, post_time, bin_size, epsilon, norm_var_scaling)
    %% Get csv table containing nv results
    if exist(csv_path, 'file')
        nv_table = readtable(csv_path);
    else
        error('Please run the nv calculation function first to get the normalized variance for your data set');
    end

    %% Find baseline for each animal and z score data
    unique_animals = unique(nv_table.animal);
    unique_regions = unique(nv_table.region);
    unique_days = unique(nv_table.day);
    z_score_data = [];
    combined_control_z = [];
    for animal = 1:length(unique_animals)
        current_animal = unique_animals{animal};
        animal_group = unique(nv_table.group(strcmpi(nv_table.animal, current_animal)));
        for region = 1:length(unique_regions)
            current_region = unique_regions{region};
            current_region_type = unique(nv_table.region_type(strcmpi(nv_table.animal, current_animal) & ...
                strcmpi(nv_table.region, current_region)));
            baseline_nv = nv_table.norm_var(strcmpi(nv_table.animal, current_animal) & ...
                strcmpi(nv_table.region, current_region) & nv_table.day == 0);
            baseline_pop_avg = mean(baseline_nv, 'omitnan');
            baseline_pop_std = std(baseline_nv, 'omitnan');
            baseline_fano = nv_table.fano(strcmpi(nv_table.animal, current_animal) & ...
                strcmpi(nv_table.region, current_region) & nv_table.day == 0);
            fano_baseline_pop_avg = mean(baseline_fano, 'omitnan');
            fano_baseline_pop_std = std(baseline_fano, 'omitnan');
            for day = 1:length(unique_days)
                current_day = unique_days(day);
                channels = nv_table.channel(strcmpi(nv_table.animal, current_animal) & ...
                    strcmpi(nv_table.region, current_region) & nv_table.day == current_day);
                %% Get nv and fano data for current day
                current_nv_data = nv_table.norm_var(strcmpi(nv_table.animal, current_animal) & ...
                    strcmpi(nv_table.region, current_region) & nv_table.day == current_day);
                current_fano = nv_table.fano(strcmpi(nv_table.animal, current_animal) & ...
                    strcmpi(nv_table.region, current_region) & nv_table.day == current_day);
                unit_z_nv = (current_nv_data - baseline_pop_avg) / baseline_pop_std;
                unit_z_fano = (current_fano - fano_baseline_pop_avg) / fano_baseline_pop_std;
                general_info = [{current_animal}, {animal_group}, {current_day}, ...
                    {pre_time}, {post_time}, {bin_size}, {norm_var_scaling}, {epsilon}, ...
                    {current_region}, {current_region_type}];
                general_info = repmat(general_info, [length(channels(:,1)), 1]);
                z_score_data = [z_score_data; general_info, channels, num2cell(unit_z_nv), num2cell(unit_z_fano)];
            end
        end
    end
    z_score_table = cell2table(z_score_data, 'VariableNames', {'animal', 'group', 'day', ...
        'pre_time', 'post_time', 'bin_size', 'norm_var_constant', 'epsilon', 'region', ...
        'region_type', 'channel', 'unit_z_nv', 'unit_z_fano'});
    [z_csv_path, ~, ~] = fileparts(csv_path);
    z_filename = fullfile(z_csv_path, 'pop_z.csv');
    writetable(z_score_table, z_filename, 'Delimiter', ',');

    %TODO calculate z score std err across days and plot
    % format: [day (x value), avg for group (y_value), std_err for group
    direct_learning = [];
    indirect_learning = [];
    direct_non_learning = [];
    indirect_non_learning = [];
    control = [];
    unique_days = unique(z_score_table.day);
    for day = 1:length(unique_days)
        current_day = unique_days(day);
        %% learning
        direct_learning_z = z_score_table.unit_z_nv(strcmpi(z_score_table.group, 'learning') & ...
            strcmpi(z_score_table.region_type, 'direct') & z_score_table.day == current_day);
        % disp(length(direct_learning_z));
        avg_direct_learning = mean(direct_learning_z, 'omitnan');
        std_err_direct_learning = std(direct_learning_z, 'omitnan') / sqrt(length(direct_learning_z));
        indirect_learning_z = z_score_table.unit_z_nv(strcmpi(z_score_table.group, 'learning') & ...
            strcmpi(z_score_table.region_type, 'indirect') & z_score_table.day == current_day);
        avg_indirect_learning = mean(indirect_learning_z, 'omitnan');
        std_err_indirect_learning = std(indirect_learning_z, 'omitnan') / sqrt(length(indirect_learning_z));
        %% non learning
        direct_non_learning_z = z_score_table.unit_z_nv(strcmpi(z_score_table.group, 'non_learning') & ...
            strcmpi(z_score_table.region_type, 'direct') & z_score_table.day == current_day);
        avg_direct_non_learning = mean(direct_non_learning_z, 'omitnan');
        std_err_direct_non_learning = std(direct_non_learning_z, 'omitnan') / sqrt(length(direct_non_learning_z));
        indirect_non_learning_z = z_score_table.unit_z_nv(strcmpi(z_score_table.group, 'non_learning') & ...
            strcmpi(z_score_table.region_type, 'indirect') & z_score_table.day == current_day);
        avg_indirect_non_learning = mean(indirect_non_learning_z, 'omitnan');
        std_err_indirect_non_learning = std(indirect_non_learning_z, 'omitnan') / sqrt(length(indirect_non_learning_z));
        %% control
        control_z = z_score_table.unit_z_nv(strcmpi(z_score_table.group, 'control') & ...
            z_score_table.day == current_day);
        avg_control = mean(control_z, 'omitnan');
        std_err_control = std(control_z, 'omitnan') / sqrt(length(control_z));
        %% Store the results of combining groups
        direct_learning = [direct_learning; current_day avg_direct_learning, std_err_direct_learning];
        indirect_learning = [indirect_learning; current_day avg_indirect_learning, std_err_indirect_learning];
        direct_non_learning = [direct_non_learning; current_day avg_direct_non_learning, std_err_direct_non_learning];
        indirect_non_learning = [indirect_non_learning; current_day avg_indirect_non_learning, std_err_indirect_non_learning];
        control = [control; current_day avg_control, std_err_control];
    end

    if true
        %% line plots
        %% learners
        direct_x=direct_learning(:,1);
        direct_y=direct_learning(:,2); % y-values used in plotting 
        direct_e=direct_learning(:,3); % error bar-values used in plotting
        % disp(direct_e)
        
        % learning animals
        indirect_x=indirect_learning(:,1); % x-values used in plotting 
        indirect_y=indirect_learning(:,2); % y-values used in plotting 
        indirect_e=indirect_learning(:,3); % error bar-values used in plotting 
        
        % control animals 
        control_x=control(:,1); % x-values used in plotting 
        control_y=control(:,2); % y-values used in plotting 
        control_e=control(:,3); % error bar-values used in plotting 

        %% Plot figure 

        % generate line with shading
        % close
        figure
        hold on;
        plot(direct_x, direct_y, 'Color', 'r', 'LineWidth', 4);
        plot(indirect_x, indirect_y, 'Color', 'b', 'LineWidth', 4);
        plot(control_x, control_y, 'Color', 'k', 'LineWidth', 4);
        transparency=0.2; % transparency of background
        [l,p] = boundedline(control_x, control_y, control_e, 'k', indirect_x, indirect_y, indirect_e, 'b', ...
            direct_x, direct_y, direct_e, 'cmap', [[0 0 0]; [0 0 1]; [1 0 0]],...
            'transparency', transparency);


        % figure properties 
        innerlineWidth=3;  % width of mean line 

        % apply properties to all lines in figure 
        for lineProperty=1:length(l)
            l(lineProperty).LineWidth=innerlineWidth;
        end

        xlabel('Time (Days)');
        ylabel('Z-Score');
        ax = axis;

        learning_ylim =  ylim;

        %% Legend
        lg = legend('direct','indirect','Control');
        legend('boxoff');
        lg.Location = 'BestOutside';
        lg.Orientation = 'Horizontal';

        title('Learning Z-Score NV');

        ylim([-0.50 1.5]);
        yticks([-0.50, 0, 1.5]);
        ytickformat('%.2f')
        hold off
        % graph_name = 'line_Z_learn.png';
        % saveas(gcf, fullfile(file_path, graph_name));
        % graph_name = 'line_Z_learn.svg';
        % saveas(gcf, fullfile(file_path, graph_name));


        %% learners
        direct_x=direct_non_learning(:,1);
        direct_y=direct_non_learning(:,2); % y-values used in plotting 
        direct_e=direct_non_learning(:,3); % error bar-values used in plotting
        % disp(direct_e)
        
        % non_learning animals
        indirect_x=indirect_non_learning(:,1); % x-values used in plotting 
        indirect_y=indirect_non_learning(:,2); % y-values used in plotting 
        indirect_e=indirect_non_learning(:,3); % error bar-values used in plotting 
        

        %% Plot figure 

        % generate line with shading
        % close
        figure
        hold on;
        plot(direct_x, direct_y, 'Color', 'r', 'LineWidth', 4);
        plot(indirect_x, indirect_y, 'Color', 'b', 'LineWidth', 4);
        plot(control_x, control_y, 'Color', 'k', 'LineWidth', 4);
        transparency=0.2; % transparency of background
        [l,p] = boundedline(control_x, control_y, control_e, 'k', indirect_x, indirect_y, indirect_e, 'b', ...
            direct_x, direct_y, direct_e, 'cmap', [[0 0 0]; [0 0 1]; [1 0 0]],...
            'transparency', transparency);


        % figure properties 
        innerlineWidth=3;  % width of mean line 

        % apply properties to all lines in figure 
        for lineProperty=1:length(l)
            l(lineProperty).LineWidth=innerlineWidth;
        end

        xlabel('Time (Days)');
        ylabel('Z-Score');
        ax = axis;

        non_learning_ylim =  ylim;

        %% Legend
        lg = legend('direct','indirect','Control');
        legend('boxoff');
        lg.Location = 'BestOutside';
        lg.Orientation = 'Horizontal';

        title('non_learning Z-Score NV');

        ylim([-0.50 1.5]);
        yticks([-0.50, 0, 1.5]);
        ytickformat('%.2f')
        hold off
        % graph_name = 'line_Z_learn.png';
        % saveas(gcf, fullfile(file_path, graph_name));
        % graph_name = 'line_Z_learn.svg';
        % saveas(gcf, fullfile(file_path, graph_name));

        direct_learning = [];
        indirect_learning = [];
        direct_non_learning = [];
        indirect_non_learning = [];
        control = [];
        unique_days = unique(z_score_table.day);
        for day = 1:length(unique_days)
            current_day = unique_days(day);
            %% learning
            direct_learning_z = z_score_table.unit_z_fano(strcmpi(z_score_table.group, 'learning') & ...
                strcmpi(z_score_table.region_type, 'direct') & z_score_table.day == current_day);
            % disp(length(direct_learning_z));
            avg_direct_learning = mean(direct_learning_z, 'omitnan');
            std_err_direct_learning = std(direct_learning_z, 'omitnan') / sqrt(length(direct_learning_z));
            indirect_learning_z = z_score_table.unit_z_fano(strcmpi(z_score_table.group, 'learning') & ...
                strcmpi(z_score_table.region_type, 'indirect') & z_score_table.day == current_day);
            avg_indirect_learning = mean(indirect_learning_z, 'omitnan');
            std_err_indirect_learning = std(indirect_learning_z, 'omitnan') / sqrt(length(indirect_learning_z));
            %% non learning
            direct_non_learning_z = z_score_table.unit_z_fano(strcmpi(z_score_table.group, 'non_learning') & ...
                strcmpi(z_score_table.region_type, 'direct') & z_score_table.day == current_day);
            avg_direct_non_learning = mean(direct_non_learning_z, 'omitnan');
            std_err_direct_non_learning = std(direct_non_learning_z, 'omitnan') / sqrt(length(direct_non_learning_z));
            indirect_non_learning_z = z_score_table.unit_z_fano(strcmpi(z_score_table.group, 'non_learning') & ...
                strcmpi(z_score_table.region_type, 'indirect') & z_score_table.day == current_day);
            avg_indirect_non_learning = mean(indirect_non_learning_z, 'omitnan');
            std_err_indirect_non_learning = std(indirect_non_learning_z, 'omitnan') / sqrt(length(indirect_non_learning_z));
            %% control
            control_z = z_score_table.unit_z_fano(strcmpi(z_score_table.group, 'control') & ...
                z_score_table.day == current_day);
            avg_control = mean(control_z);
            std_err_control = std(control_z) / sqrt(length(control_z));
            %% Store the results of combining groups
            direct_learning = [direct_learning; current_day avg_direct_learning, std_err_direct_learning];
            indirect_learning = [indirect_learning; current_day avg_indirect_learning, std_err_indirect_learning];
            direct_non_learning = [direct_non_learning; current_day avg_direct_non_learning, std_err_direct_non_learning];
            indirect_non_learning = [indirect_non_learning; current_day avg_indirect_non_learning, std_err_indirect_non_learning];
            control = [control; current_day avg_control, std_err_control];
        end

        %% line plots
        %% learners
        direct_x=direct_learning(:,1);
        direct_y=direct_learning(:,2); % y-values used in plotting 
        direct_e=direct_learning(:,3); % error bar-values used in plotting
        % disp(direct_e)
        
        % learning animals
        indirect_x=indirect_learning(:,1); % x-values used in plotting 
        indirect_y=indirect_learning(:,2); % y-values used in plotting 
        indirect_e=indirect_learning(:,3); % error bar-values used in plotting 
        
        % control animals 
        control_x=control(:,1); % x-values used in plotting 
        control_y=control(:,2); % y-values used in plotting 
        control_e=control(:,3); % error bar-values used in plotting 

        %% Plot figure 

        % generate line with shading
        % close
        figure
        hold on;
        plot(direct_x, direct_y, 'Color', 'r', 'LineWidth', 4);
        plot(indirect_x, indirect_y, 'Color', 'b', 'LineWidth', 4);
        plot(control_x, control_y, 'Color', 'k', 'LineWidth', 4);
        transparency=0.2; % transparency of background
        [l,p] = boundedline(control_x, control_y, control_e, 'k', indirect_x, indirect_y, indirect_e, 'b', ...
            direct_x, direct_y, direct_e, 'cmap', [[0 0 0]; [0 0 1]; [1 0 0]],...
            'transparency', transparency);


        % figure properties 
        innerlineWidth=3;  % width of mean line 

        % apply properties to all lines in figure 
        for lineProperty=1:length(l)
            l(lineProperty).LineWidth=innerlineWidth;
        end

        xlabel('Time (Days)');
        ylabel('Z-Score');
        ax = axis;

        learning_ylim =  ylim;

        %% Legend
        lg = legend('direct','indirect','Control');
        legend('boxoff');
        lg.Location = 'BestOutside';
        lg.Orientation = 'Horizontal';

        title('Learning Z-Score Fano');

        ylim([-0.50 1.5]);
        yticks([-0.50, 0, 1.5]);
        ytickformat('%.2f')
        hold off
        % graph_name = 'line_Z_learn.png';
        % saveas(gcf, fullfile(file_path, graph_name));
        % graph_name = 'line_Z_learn.svg';
        % saveas(gcf, fullfile(file_path, graph_name));


        %% learners
        direct_x=direct_non_learning(:,1);
        direct_y=direct_non_learning(:,2); % y-values used in plotting 
        direct_e=direct_non_learning(:,3); % error bar-values used in plotting
        % disp(direct_e)
        
        % non_learning animals
        indirect_x=indirect_non_learning(:,1); % x-values used in plotting 
        indirect_y=indirect_non_learning(:,2); % y-values used in plotting 
        indirect_e=indirect_non_learning(:,3); % error bar-values used in plotting 
        

        %% Plot figure 

        % generate line with shading
        % close
        figure
        hold on;
        plot(direct_x, direct_y, 'Color', 'r', 'LineWidth', 4);
        plot(indirect_x, indirect_y, 'Color', 'b', 'LineWidth', 4);
        plot(control_x, control_y, 'Color', 'k', 'LineWidth', 4);
        transparency=0.2; % transparency of background
        [l,p] = boundedline(control_x, control_y, control_e, 'k', indirect_x, indirect_y, indirect_e, 'b', ...
            direct_x, direct_y, direct_e, 'cmap', [[0 0 0]; [0 0 1]; [1 0 0]],...
            'transparency', transparency);


        % figure properties 
        innerlineWidth=3;  % width of mean line 

        % apply properties to all lines in figure 
        for lineProperty=1:length(l)
            l(lineProperty).LineWidth=innerlineWidth;
        end

        xlabel('Time (Days)');
        ylabel('Z-Score');
        ax = axis;

        non_learning_ylim =  ylim;

        %% Legend
        lg = legend('direct','indirect','Control');
        legend('boxoff');
        lg.Location = 'BestOutside';
        lg.Orientation = 'Horizontal';

        title('non_learning Z-Score fano');

        ylim([-0.50 1.5]);
        yticks([-0.50, 0, 1.5]);
        ytickformat('%.2f')
        hold off
        % graph_name = 'line_Z_learn.png';
        % saveas(gcf, fullfile(file_path, graph_name));
        % graph_name = 'line_Z_learn.svg';
        % saveas(gcf, fullfile(file_path, graph_name));
    end
    
end