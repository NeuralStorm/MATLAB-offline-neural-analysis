function [] = batch_nv(project_path, save_path, failed_path, data_path, ...
        dir_name, filename_substring_one, config)
    nv_start = tic;
    config_log = config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

    meta_headers = {'filename', 'animal_id', 'exp_group', 'exp_condition', ...
    'optional_info', 'date', 'record_session', 'bin_size', 'window_start', ...
    'baseline_start', 'baseline_end', 'epsilon', 'norm_var_scaling', 'separate_events'};
    analysis_headers = {'event', 'region', 'sig_channels', 'user_channels', 'avg_background_rate', ...
        'background_var', 'norm_var', 'fano', 'recording_notes'};
    ignore_headers = {'avg_background_rate', 'background_var', 'norm_var', 'fano'};

    %% Pull variable names into workspace scope for log
    window_start = config.window_start; baseline_start = config.baseline_start; baseline_end = config.baseline_end; 
    bin_size = config.bin_size; epsilon = config.epsilon; 
    norm_var_scaling = config.norm_var_scaling; separate_events = config.separate_events;

    fprintf('Normalized variance analysis for %s \n', dir_name);
    all_neurons = [];
    meta_info = table;
    for file_index = 1:length(file_list)
        %% Run through files
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'label_log', 'baseline_window', 'filename_meta');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, baseline_window, label_log);
            if empty_vars
                error('Baseline_window and/or label_log is empty');
            elseif ~isstruct(baseline_window) && isnan(baseline_window)
                error('window_start, baseline_start, and baseline_end must all be non zero windows for this analysis.');
            end
            %% NV analysis
            neuron_activity = nv_calculation(label_log, baseline_window, baseline_start, ...
                baseline_end, bin_size, epsilon, norm_var_scaling, separate_events, analysis_headers);

            %% Store metadata about file
            current_meta = [
                {filename_meta.filename}, {filename_meta.animal_id}, ...
                {filename_meta.experimental_group}, ...
                {filename_meta.experimental_condition}, ...
                {filename_meta.optional_info}, filename_meta.session_date, ...
                filename_meta.session_num, bin_size, window_start, baseline_start, ...
                baseline_end, epsilon, norm_var_scaling, separate_events
            ];
            [meta_info, all_neurons] = concat_tables(meta_headers, meta_info, current_meta, ...
                all_neurons, neuron_activity);

            %% Save analysis results
            matfile = fullfile(save_path, ['NV_analysis_', filename_meta.filename, '.mat']);
            check_variables(matfile, label_log, neuron_activity);
            save(matfile, 'label_log', 'neuron_activity', 'filename_meta', ...
                'config_log');
            clear('label_log', 'neuron_activity', 'filename_meta');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    %% CSV export set up
    nv_results = [meta_info, all_neurons];
    csv_path = fullfile(project_path, [filename_substring_one, '_norm_var.csv']);
    export_csv(csv_path, nv_results, ignore_headers);

    fprintf('Finished normalized variance analysis for %s. It took %s \n', ...
        dir_name, num2str(toc(nv_start)));
end