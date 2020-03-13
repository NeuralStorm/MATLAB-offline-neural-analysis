function [] = batch_nv(project_path, save_path, failed_path, data_path, ...
        dir_name, filename_substring_one, config)
    nv_start = tic;
    config_log = config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);
    %% NV set up

    meta_headers = {'animal', 'group', 'date', 'record_session', 'pre_time', 'pre_start', 'pre_end'};
    analysis_headers = {'event', 'region', 'sig_channels', 'user_channels', 'avg_background_rate', ...
        'background_var', 'norm_var', 'fano', 'recording_notes'};
    csv_headers = [meta_headers, analysis_headers];

    %% Pull variable names into workspace scope for log
    pre_time = config.pre_time; pre_start = config.pre_start; pre_end = config.pre_end; 
    bin_size = config.bin_size; epsilon = config.epsilon; 
    norm_var_scaling = config.norm_var_scaling; separate_events = config.separate_events;

    %TODO export log

    fprintf('Normalized variance analysis for %s \n', dir_name);
    all_neurons = [];
    meta_info = table;
    for file_index = 1:length(file_list)
        %% Run through files
        try
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'selected_data', 'baseline_window', 'filename_meta');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, baseline_window, selected_data);
            if empty_vars
                error('Baseline_window and/or selected_data is empty');
            elseif ~isstruct(baseline_window) && isnan(baseline_window)
                error('pre_time, pre_start, and pre_end must all be non zero windows for this analysis.');
            end
            %% NV analysis
            neuron_activity = nv_calculation(selected_data, baseline_window, pre_start, ...
                pre_end, bin_size, epsilon, norm_var_scaling, separate_events, analysis_headers);

            %% Store metadata about file
            current_meta = [{filename_meta.animal_id}, ...
                {filename_meta.experimental_group}, filename_meta.session_date, ...
                filename_meta.session_num, pre_time, pre_start, pre_end];
            [meta_info, all_neurons] = concat_tables(meta_headers, meta_info, current_meta, ...
                all_neurons, neuron_activity);

            %% Save analysis results
            matfile = fullfile(save_path, ['NV_analysis_', filename_meta.filename, '.mat']);
            check_variables(matfile, selected_data, neuron_activity);
            save(matfile, 'selected_data', 'neuron_activity', 'filename_meta', ...
                'config_log');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    %% CSV export set up
    csv_path = fullfile(project_path, [filename_substring_one, '_norm_var.csv']);
    export_csv(csv_path, csv_headers, meta_info, all_neurons);

    fprintf('Finished normalized variance analysis for %s. It took %s \n', ...
        dir_name, num2str(toc(nv_start)));
end