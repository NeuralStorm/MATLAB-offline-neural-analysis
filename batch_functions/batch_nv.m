function [] = batch_nv(animal_name, original_path, data_path, dir_name, ...
        search_ext, filename_substring_one, filename_substring_two, config, ignore_sessions)
    %% Check pre time is valid for analysis
    nv_start = tic;
    
    %% NV set up

    [nv_path, failed_path] = create_dir(data_path, dir_name);
    [psth_files] = get_file_list(data_path, search_ext, config.ignore_sessions);
    
    meta_headers = {'animal', 'group', 'date', 'record_session', 'pre_time', 'pre_start', 'pre_end'};
    analysis_headers = {'event', 'region', 'channel', 'avg_background_rate', ...
        'background_var', 'norm_var', 'fano', 'notes'};
    csv_headers = [meta_headers, analysis_headers];

    %% Pull variable names into workspace scope for log
    pre_time = config.pre_time; pre_start = config.pre_start; pre_end = config.pre_end; 
    bin_size = config.bin_size; epsilon = config.epsilon; 
    norm_var_scaling = config.norm_var_scaling; separate_events = config.separate_events;

    export_params(nv_path, 'normalized_variance', failed_path, animal_name, pre_time, ...
        pre_start, pre_end, bin_size, epsilon, norm_var_scaling, separate_events);

    fprintf('Normalized variance analysis for %s \n', animal_name);
    all_neurons = [];
    meta_info = table;
    for file_index = 1:length(psth_files)
        %% Run through files
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, psth_files(file_index).name);
            [~, filename, ~] = fileparts(file);
            filename = erase(filename, [filename_substring_one, '.', filename_substring_two, '.']);
            filename = erase(filename, [filename_substring_one, '_', filename_substring_two, '_']);
            [~, experimental_group, ~, session_num, session_date, ~] = get_filename_info(filename);
            load(file, 'labeled_data', 'baseline_window');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, baseline_window, labeled_data);
            if empty_vars
                error('Baseline_window and/or labeled_data is empty');
            elseif ~isstruct(baseline_window) && isnan(baseline_window)
                error('pre_time, pre_start, and pre_end must all be non zero windows for this analysis.');
            end
            %% NV analysis
            neuron_activity = nv_calculation(labeled_data, baseline_window, pre_start, ...
                pre_end, bin_size, epsilon, norm_var_scaling, separate_events, analysis_headers);

            %% Store metadata about file
            current_meta = [{animal_name}, {experimental_group}, session_date, session_num, ...
                pre_time, pre_start, pre_end];
            [meta_info, all_neurons] = concat_tables(meta_headers, meta_info, current_meta, ...
                all_neurons, neuron_activity);

            %% Save analysis results
            matfile = fullfile(nv_path, ['NV_analysis_', filename, '.mat']);
            check_variables(matfile, labeled_data, neuron_activity);
            save(matfile, 'labeled_data', 'neuron_activity');
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end
    %% CSV export set up
    csv_path = fullfile(original_path, 'norm_var.csv');
    export_csv(csv_path, csv_headers, meta_info, all_neurons);

    fprintf('Finished normalized variance analysis for %s. It took %s \n', ...
        animal_name, num2str(toc(nv_start)));
end