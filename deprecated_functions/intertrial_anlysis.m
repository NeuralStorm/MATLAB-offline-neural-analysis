function [] = intertrial_anlysis(original_path, animal_name, psth_path, bin_size, pre_time, post_time, first_iteration)
    %% Animal categories
    learning = ['PRAC03', 'TNC16', 'RAVI19', 'RAVI20', 'RAVI019', 'RAVI020'];
    non_learning = ['LC02', 'TNC06', 'TNC12', 'TNC25'];
    control = ['TNC01', 'TNC03', 'TNC04', 'TNC14'];
    right_direct = ['RAVI19', 'RAVI019', 'PRAC03', 'LC02', 'TNC12'];
    left_direct = ['RAVI20', 'RAVI020', 'TNC16', 'TNC25', 'TNC06'];

    % Checks if a intertrial directory exists and if not it creates it
    intertrial_path = [psth_path, '/intertrial_analysis'];
    if ~exist(intertrial_path, 'dir')
        mkdir(psth_path, '/intertrial_analysis');
    end

    plots_path = [intertrial_path, '/plots'];
    if ~exist(plots_path, 'dir')
        mkdir(intertrial_path, '/plots');
    end

    results_path = fullfile(original_path, 'intertrial_results.csv');
    if ~exist(results_path, 'file') && first_iteration
        intertrial_table = table([], [], [], [], [], [], [], [], 'VariableNames', {'animal', ...
            'animal_group', 'mean_direct_rsq' 'std_direct_rsq' 'std_err_direct_rsq' 'mean_indirect_rsq' ...
            'std_indirect_rsq' 'std_err_indirect_rsq'});
    elseif exist(results_path, 'file') && first_iteration
        delete(results_path);
        intertrial_table = table([], [], [], [], [], [], [], [], 'VariableNames', {'animal', ...
            'animal_group', 'mean_direct_rsq' 'std_direct_rsq' 'std_err_direct_rsq' 'mean_indirect_rsq' ...
            'std_indirect_rsq' 'std_err_indirect_rsq'});
    else
        intertrial_table = readtable(results_path);
    end

    % Grabs all the psth formatted files
    psth_mat_path = strcat(psth_path, '/*.mat');
    psth_files = dir(psth_mat_path);

    direct_first_last_fig = figure;
    title([animal_name, ' Direct first and last 5 days']);
    direct_x_upper = [];
    direct_y_upper = [];
    indirect_first_last_fig = figure;
    title([animal_name, ' Indirect first and last 5 days']);
    indirect_x_upper = [];
    indirect_y_upper = [];

    direct_x_rsq = [];
    direct_y_rsq = [];

    indirect_x_rsq = [];
    indirect_y_rsq = [];

    %% only used to split control right and left regionss
    right_rsq = [];
    left_rsq = [];

    direct_slope = [];
    indirect_slope = [];


    %% Iterates through all the psth formated files
    for file = 1: length(psth_files)
        current_file = [psth_path, '/', psth_files(file).name];
        [file_path, filename, file_extension] = fileparts(current_file);
        split_name = strsplit(filename, '.');
        current_day = split_name{6};
        day_num = regexp(current_day,'\d*','Match');
        day_num = str2num(day_num{1});
        exp_date = split_name{end};
        current_animal = split_name{3};
        current_animal_id = split_name{4};
        current_animal = [current_animal, current_animal_id];
        disp([current_animal, ' ', current_day])

        load(current_file, 'event_struct', 'event_ts', 'event_strings', 'labeled_neurons');

        trial_ids = 1:1:length(event_ts);
        labeled_events = [trial_ids', event_ts];

        intertrial_struct = struct;
        all_events = event_struct.all_events;
        unique_regions = fieldnames(labeled_neurons);
        for region = 1:length(unique_regions)
            region_name = unique_regions{region};
            %% Determine direct and indirect regions
            if (contains(right_direct, current_animal) & strcmpi(region_name, 'right')) || ...
                (contains(left_direct, current_animal) & strcmpi(region_name, 'left'))
                region_type = 'direct';
            else
                region_type = 'indirect';
            end
            region_path = [plots_path, '/', region_type];
            if ~exist(region_path, 'dir')
                mkdir(plots_path, ['/', region_type]);
            end


            total_region_neurons = length(labeled_neurons.(region_name)(:,1));          
            region_neurons = [labeled_neurons.(region_name)(:,1), labeled_neurons.(region_name)(:,end)];
            region_psth = NeuroToolbox.PSTHToolbox.PSTH(region_neurons, all_events, 'bin_size', ... 
                bin_size, 'PSTH_window', [-abs(pre_time), post_time]);
            region_template = NeuroToolbox.PSTHToolbox.SU_Classifier(region_psth);
            region_decoder_output = region_template.classify(region_neurons, all_events, 'SameDataSet', true);
            correct_trials = cellfun(@strcmp, region_decoder_output.Decision, region_decoder_output.Event);
            correct_labels = region_decoder_output.Event(correct_trials);
            confusion_values = region_decoder_output.Classification_Parameter;
                    
            event_key = region_decoder_output.DecoderSpec.Template.TemplateSource.event_key;
            event_decode = [];
            
            min_values = [];
            
            for i = 1:length(correct_trials)
                [min_values(i), event_decode(i)] = min(confusion_values(i,:));
            end
            
            confusion_numbers = confusionmat(event_key, event_decode');
            % confusion_matrix = (confusionmat(event_key, event_decode'))./length(correct_trials);
            confusion_matrix = (confusionmat(event_key, event_decode'));
            intertrial_struct.(region_name).confusion_matrix = confusion_matrix;
            information = I_confmatr(confusion_matrix);
            intertrial_struct.(region_name).information = information;

            intertrial_struct.(region_name).region_neurons = region_neurons;
            intertrial_struct.(region_name).psth = region_psth;
            intertrial_struct.(region_name).template = region_template;
            intertrial_struct.(region_name).decorder_output = region_decoder_output;
            intertrial_struct.(region_name).correct_trials = correct_trials;
            intertrial_struct.(region_name).correct_labels = correct_labels;
            figure('Visible', 'off');
            all_events = event_struct.all_events;
            event_length = length(all_events{1,2}) + length(all_events{2,2}) + length(all_events{3,2}) + length(all_events{4,2});
            % disp(event_length)
            x_values = (1:1:event_length)';
            y_values = cumsum(correct_trials);
            % hold on;
            % plot(x_values, y_values);
            linear_fit = polyfit(x_values, y_values, 1);
            slope = linear_fit(1);
            yfit = polyval(linear_fit, x_values);
            yresid = y_values - yfit;
            SSresid = sum(yresid.^2);
            SStotal = (length(y_values)-1) * var(y_values);
            rsq = 1 - SSresid/SStotal;
            intertrial_struct.(region_name).linear_slope = linear_fit(1);
            intertrial_struct.(region_name).r_square = rsq;
            linear_fit = linear_fit(1) * x_values + linear_fit(2);
            % plot(x_values, linear_fit,'r-.');
            ylim([0 event_length])
            % title([current_animal, ' on ', current_day, ' for ', region_type, ' (', region_name, ') Intertrial Progress']);
            xlabel('Trials')
            ylabel('Cumalitive Sum')
            % hold off
            % graph_name = [current_day, '_', current_animal, '_', region_name,'_', region_type, '_cumsum.png'];
            % saveas(gcf, fullfile(region_path, graph_name));
            
            if strcmpi(region_type, 'direct')
                direct_x_rsq = [direct_x_rsq; day_num];
                direct_y_rsq = [direct_y_rsq; rsq];
                direct_slope = [direct_slope; slope];
            else
                indirect_x_rsq = [indirect_x_rsq; day_num];
                indirect_y_rsq = [indirect_y_rsq; rsq];
                indirect_slope = [indirect_slope; slope];
            end

            %% Split control into regions
            if contains(control, current_animal) & strcmpi(region_name, 'right')
                right_rsq = [right_rsq, rsq];
            elseif contains(control, current_animal)
                left_rsq = [left_rsq, rsq];
            end



            if day_num <= 5 && strcmpi(region_type, 'direct') && ~contains(control, current_animal)
                figure(direct_first_last_fig)
                hold on
                plot((1:1:event_length), cumsum(correct_trials), 'r');
                direct_x_upper = [direct_x_upper, event_length];
                direct_y_upper = [direct_y_upper, event_length];
                hold off
            elseif day_num >= 20 && strcmpi(region_type, 'direct') && ~contains(control, current_animal)
                figure(direct_first_last_fig)
                hold on
                plot((1:1:event_length), cumsum(correct_trials), 'k');
                direct_x_upper = [direct_x_upper, event_length];
                direct_y_upper = [direct_y_upper, event_length];
                hold off
            elseif day_num <= 5 && strcmpi(region_type, 'indirect')
                figure(indirect_first_last_fig)
                hold on
                plot((1:1:event_length), cumsum(correct_trials), 'r');
                indirect_x_upper = [indirect_x_upper, event_length];
                indirect_y_upper = [indirect_y_upper, event_length];
                hold off
            elseif day_num >= 20 && strcmpi(region_type, 'indirect')
                figure(indirect_first_last_fig)
                hold on
                plot((1:1:event_length), cumsum(correct_trials), 'k');
                indirect_x_upper = [indirect_x_upper, event_length];
                indirect_y_upper = [indirect_y_upper, event_length];
                hold off
            end

        end
        filename = strrep(filename, 'PSTH', 'intertrial');
        filename = strrep(filename, 'format', 'analysis');
        matfile = fullfile(intertrial_path, [filename, '.mat']);
        save(matfile, 'intertrial_struct', 'labeled_events');
    end

    if ~contains(control, animal_name)
        figure(direct_first_last_fig)
        xlim([0 max(direct_x_upper)]);
        ylim([0 max(direct_y_upper)]);
        graph_name = fullfile(intertrial_path, [current_animal, '_direct_first_last.png']);
        saveas(gcf, graph_name);
    end
    figure(indirect_first_last_fig)
    xlim([0 max(indirect_x_upper)]);
    ylim([0 max(indirect_y_upper)]);
    graph_name = fullfile(intertrial_path, [current_animal, '_indirect_first_last.png']);
    saveas(gcf, graph_name);
    close all

    direct_scatter_fig = figure;
    scatter(direct_x_rsq, direct_y_rsq, 'filled')
    title([animal_name, ' Direct r^2 scatter']);
    graph_name = fullfile(plots_path, [current_animal, '_direct_rsqr.png']);
    saveas(gcf, graph_name);

    indirect_scatter_fig = figure;
    scatter(indirect_x_rsq, indirect_y_rsq, 'filled')
    title([animal_name, ' Indirect r^2 scatter']);
    graph_name = fullfile(plots_path, [current_animal, '_indirect_rsqr.png']);
    saveas(gcf, graph_name);

    direct_slope_fig = figure;
    scatter(direct_x_rsq, direct_slope, 'filled')
    title([animal_name, ' Direct slope scatter']);
    graph_name = fullfile(plots_path, [current_animal, '_direct_slope.png']);
    saveas(gcf, graph_name);

    indirect_slope_fig = figure;
    scatter(indirect_x_rsq, indirect_slope, 'filled')
    title([animal_name, ' indirect slope scatter']);
    graph_name = fullfile(plots_path, [current_animal, '_indirect_slope.png']);
    saveas(gcf, graph_name);


    if contains(learning, current_animal)
        group = 'learning';
    elseif contains(non_learning, current_animal)
        group = 'non_learning';
    else
        group = 'control'
    end

    if contains(control, current_animal)
        direct_rsq_mean = mean(right_rsq);
        direct_rsq_std = std(right_rsq);
        direct_rsq_std_err = std(right_rsq)/sqrt(length(right_rsq));
        indirect_rsq_mean = mean(left_rsq);
        indirect_rsq_std = std(left_rsq);
        indirect_rsq_std_err = std(left_rsq)/sqrt(length(left_rsq));
    else
        direct_rsq_mean = mean(direct_y_rsq);
        direct_rsq_std = std(direct_y_rsq);
        direct_rsq_std_err = std(direct_y_rsq)/sqrt(length(direct_y_rsq));
        indirect_rsq_mean = mean(indirect_y_rsq);
        indirect_rsq_std = std(indirect_y_rsq);
        indirect_rsq_std_err = std(indirect_y_rsq)/sqrt(length(indirect_y_rsq));
    end

    new_intertrial_table = table({current_animal}, {group}, direct_rsq_mean, direct_rsq_std, direct_rsq_std_err, ...
    indirect_rsq_mean, indirect_rsq_std, indirect_rsq_std_err, 'VariableNames', {'animal', ...
    'animal_group', 'mean_direct_rsq' 'std_direct_rsq' 'std_err_direct_rsq' 'mean_indirect_rsq' ...
    'std_indirect_rsq' 'std_err_indirect_rsq'});
    intertrial_table = [intertrial_table; new_intertrial_table];
    writetable(intertrial_table, results_path, 'Delimiter', ',');


end