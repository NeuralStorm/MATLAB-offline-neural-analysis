function [rf_path] = batch_recfield(animal_name, original_path, data_path, dir_name, ...
        search_ext, filename_substring_one, config)
    %! TODO FIX CSV NAME HANDLING

    rf_start = tic;
    
    [rf_path, failed_path] = create_dir(data_path, dir_name);
    [files] = get_file_list(data_path, search_ext, config.ignore_sessions);

    %% Pull variable names into workspace scope for log
    pre_time = config.pre_time; pre_start = config.pre_start; pre_end = config.pre_end;
    post_time = config.post_time; post_start = config.post_start; post_end = config.post_end;
    bin_size = config.bin_size; threshold_scale = config.threshold_scale; ignore_sessions = config.ignore_sessions;
    sig_check = config.sig_check; sig_bins = config.sig_bins; span = config.span;

    export_params(rf_path, 'receptive_field_analysis', rf_path, failed_path, ...
        animal_name, pre_time, pre_start, pre_end, post_start, post_end, bin_size, ...
        threshold_scale, sig_check, sig_bins, span, ignore_sessions);

    meta_headers = {'animal', 'group', 'date', 'record_session', 'pre_time', ...
        'pre_start', 'pre_end', 'post_time', 'post_start', 'post_end', 'bin_size', ...
        'sig_check', 'sig_bins', 'span', 'threshold_scale'};
    analysis_headers = {'region', 'sig_channels', 'user_channels', 'event', 'significant', ...
        'background_rate', 'background_std', 'threshold', 'first_latency', ...
        'last_latency', 'duration', 'peak_latency', 'peak_response', ...
        'corrected_peak', 'response_magnitude', 'corrected_response_magnitude', ...
        'total_sig_events', 'principal_event', 'norm_magnitude', 'recording_notes'};
    csv_headers = [meta_headers, analysis_headers];

    sprintf('Receptive field analysis for %s \n', animal_name);
    all_neurons = [];
    general_info = table;
    for file_index = 1:length(files)
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, files(file_index).name);

            %% Load needed variables from psth and does the receptive field analysis
            load(file, 'labeled_data', 'baseline_window', 'response_window', 'filename_meta');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, baseline_window, response_window, labeled_data);
            if empty_vars
                error('Baseline_window, response_window, and/or labeled_data is empty');
            elseif ~isstruct(baseline_window) && isnan(baseline_window)
                error('pre_time, pre_start, and pre_end must all be non zero windows for this analysis.');
            elseif ~isstruct(response_window) && isnan(response_window)
                error('post_time, post_start, and post_end must all be non zero windows for this analysis.');
            end

            [sig_neurons, non_sig_neurons] = receptive_field_analysis( ...
                labeled_data, baseline_window, response_window, bin_size, post_start, threshold_scale, ...
                sig_check, sig_bins, span, analysis_headers);

            %% Capture data to save to csv from current day
            session_neurons = [sig_neurons; non_sig_neurons];
            current_general_info = [{filename_meta.animal_id}, ...
                {filename_meta.experimental_group}, filename_meta.session_date, ...
                filename_meta.session_num, pre_time, pre_start, ...
                pre_end, post_time, post_start, post_end, bin_size, ...
                sig_check, sig_bins, span, threshold_scale];
            [general_info, all_neurons] = ...
                concat_tables(meta_headers, general_info, current_general_info, all_neurons, session_neurons);

            %% Save receptive field matlab output
            % Does not check if variables are empty since there may/may not be significant responses in a set
            matfile = fullfile(rf_path, ['rec_field_', filename_meta.filename, '.mat']);
            save(matfile, 'labeled_data', 'sig_neurons', 'non_sig_neurons', 'filename_meta');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end

    %% CSV export set up
    csv_path = fullfile(original_path, [filename_substring_one, '_receptive_field_results.csv']);
    export_csv(csv_path, csv_headers, general_info, all_neurons);

    fprintf('Finished receptive field analysis for %s. It took %s \n', ...
        animal_name, num2str(toc(rf_start)));
end