function [nv_calc_path, csv_path] = ...
    nv_calculation(original_path, psth_path, animal_name, pre_time, post_time, ...
    bin_size, epsilon, norm_var_scaling, first_iteration, separate_events)
    % nv = normalized variance, bfr = background firing rate, rf = receptive field

    if pre_time <= 0.050
        error('Pre time can not be set to 0 for normalized variance analysis. Recreate the PSTH format with a different pre time.');
    end

    %% Animal categories
    learning = ['PRAC03', 'TNC16', 'RAVI19', 'RAVI20', 'RAVI019', 'RAVI020'];
    non_learning = ['LC02', 'TNC06', 'TNC12', 'TNC25'];
    control = ['TNC01', 'TNC03', 'TNC04', 'TNC14'];
    right_direct = ['RAVI19', 'RAVI019', 'PRAC03', 'LC02', 'TNC12'];
    left_direct = ['RAVI20', 'RAVI020', 'TNC16', 'TNC25', 'TNC06'];

    column_names = {'animal', 'group', 'day', 'region', 'region_type', ...
        'event', 'channel', 'avg_bfr', 'bfr_var', 'norm_var', 'fano'};

    if contains(learning, animal_name)
        animal_type = 'learning';
    elseif contains(non_learning, animal_name)
        animal_type = 'non_learning';
    elseif contains(control, animal_name)
        animal_type = 'control';
    else
        error([animal_name, ' does not fall into learning, non learning, or control groups']);
    end

    psth_mat_path = [psth_path, '/*.mat'];
    psth_files = dir(psth_mat_path);

    nv_calc_path = [psth_path, '/normalized_variance_analysis'];
    if ~exist(nv_calc_path, 'dir')
        mkdir(psth_path, 'normalized_variance_analysis');
    end

    % Deletes the failed directory if it already exists
    failed_path = [psth_path, '/failed'];
    if exist(failed_path, 'dir') == 7
        delete([failed_path, '/*']);
        rmdir(failed_path);
    end

    pre_time_bins = (length([-abs(pre_time): bin_size: 0])) - 1;
    post_time_bins = (length([0:bin_size:post_time])) - 1;

    %% CSV export set up
    csv_path = fullfile(original_path, 'single_unit_nv.csv');
    if ~exist(csv_path, 'file') && first_iteration
        nv_table = table([], [], [], [], [], [], [], [], [], [], [], 'VariableNames', column_names);
    elseif exist(csv_path, 'file') && first_iteration
        delete(csv_path);
        nv_table = table([], [], [], [], [], [], [], [], [], [], [], 'VariableNames', column_names);
    else
        nv_table = readtable(csv_path);
    end

    nv_data = [];
    for file = 1:length(psth_files)
        failed_rf = {};
        current_file = [psth_path, '/', psth_files(file).name];
        [file_path, filename, file_extension] = fileparts(current_file);
        split_name = strsplit(filename, '.');
        current_day = split_name{6};
        day_num = regexp(current_day,'\d*','Match');
        day_num = str2num(day_num{1});
        exp_date = split_name{end};
        current_animal = split_name{3};
        current_animal_id = split_name{4};
        fprintf('Normalized variance calculation for %s on %s\n', animal_name, current_day);

        load(current_file);

        % Gets the end indeces of events for separation
        all_events = event_struct.all_events(:,2);
        event_end_indeces = [];
        for event = 1:length(all_events)
            event_end_indeces = [event_end_indeces, length(all_events{event})];
        end
        event_end_indeces = cumsum(event_end_indeces);
        
        neuron_activity = struct;
        for region = 1:length(unique_regions)
            current_region = unique_regions{region};
            region_neurons = labeled_neurons.(current_region)(:, 1);
            if (contains(right_direct, animal_name) && strcmpi('Right', current_region)) || (contains(left_direct, animal_name) && strcmpi('Left', current_region))
                region_type = 'Direct';
            else
                region_type = 'Indirect';
            end

            relative_response = event_struct.(current_region).relative_response;
            if separate_events
                last_trial_index = 1;
                for event = 1:length(event_strings)
                    current_event = event_strings{event};
                    pre_index = pre_time_bins;
                    for neuron = 1:length(region_neurons)
                        current_neuron = region_neurons{neuron};
                        current_pre = relative_response(last_trial_index:event_end_indeces(event), (pre_index - pre_time_bins + 1 ):pre_index);
                        neuron_activity.(current_region).([current_event, '_', current_neuron, '_background_rate']) = current_pre;
                        pre_index = pre_index + post_time_bins + pre_time_bins;
                        %% Calculate NV for each event
                        bfr = sum(current_pre, 2) / (pre_time * 1000);
                        avg_bfr = mean(bfr);
                        bfr_var = var(bfr);
                        norm_var = norm_var_scaling * (epsilon + bfr_var)/(norm_var_scaling * epsilon + avg_bfr);
                        fano = avg_bfr / bfr_var;
                        nv_data = [nv_data; {animal_name}, {animal_type}, {day_num}, {current_region}, {region_type}, ...
                            {current_event}, {current_neuron}, {avg_bfr}, {bfr_var}, {norm_var}, {fano}];
                    end
                    pre_index = pre_time_bins;
                    last_trial_index = event_end_indeces(event) + 1;
                end
            else
                pre_index = pre_time_bins;
                for neuron = 1:length(region_neurons)
                    current_neuron = region_neurons{neuron};
                    %% Grabs all trials for given neuron
                    neuron_pre_activity = relative_response(:, (pre_index - pre_time_bins + 1 ):pre_index);
                    bfr = sum(neuron_pre_activity, 2) / (pre_time * 1000);
                    avg_bfr = mean(bfr);
                    bfr_var = var(bfr);
                    norm_var = norm_var_scaling * (epsilon + bfr_var)/(norm_var_scaling * epsilon + avg_bfr);
                    fano = avg_bfr / bfr_var;
                    nv_data = [nv_data; {animal_name}, {animal_type}, {day_num}, {current_region}, {region_type}, ...
                        {'all_events'}, {current_neuron}, {avg_bfr}, {bfr_var}, {norm_var}, {fano}];
                    pre_index = pre_index + post_time_bins + pre_time_bins;
                end
            end
        end

        %% Save analysis results
        nv_filename = strrep(filename, 'PSTH', 'NV');
        nv_filename = strrep(nv_filename, 'format', 'analysis');
        matfile = fullfile(nv_calc_path, [nv_filename, '.mat']);
        save(matfile, 'labeled_neurons', 'neuron_activity');
    end
    new_nv_table = cell2table(nv_data, 'VariableNames', column_names);
    nv_table = [nv_table; new_nv_table];
    writetable(nv_table, csv_path, 'Delimiter', ',');

end