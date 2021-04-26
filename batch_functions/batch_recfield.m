function [] = batch_recfield(project_path, save_path, failed_path, data_path, dir_name, filename_substring_one, config)
    %TODO add recording notes to csv
    rf_start = tic;
    config_log = config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

    %% Pull variable names into workspace scope for log
    window_start = config.window_start; baseline_start = config.baseline_start; baseline_end = config.baseline_end;
    window_end = config.window_end; response_start = config.response_start; response_end = config.response_end;
    bin_size = config.bin_size; threshold_scalar = config.threshold_scalar;
    sig_check = config.sig_check; consec_bins = config.consec_bins; span = config.span;
    sig_alpha = config.cell_sig_alpha;
    bin_gap = config.bin_gap; mixed_smoothing = config.mixed_smoothing;

    rec_csv_path = fullfile(project_path, [filename_substring_one, '_receptive_field_results.csv']);
    cluster_csv_path = fullfile(project_path, [filename_substring_one, '_cluster_analysis_results.csv']);
    meta_headers = {'filename', 'animal_id', 'exp_group', 'exp_condition', ...
        'optional_info', 'date', 'record_session', 'window_start', ...
        'baseline_start', 'baseline_end', 'window_end', 'response_start', 'response_end', 'bin_size', ...
        'sig_alpha', 'mixed_smoothing', 'sig_check', 'consec_bins', ...
        'span', 'threshold_scalar'};
    ignore_headers = {
        'significant', 'background_rate', 'background_std', 'avg_response', 'response_window_rm', 'threshold', 'p_val', ...
        'first_latency', 'last_latency', 'duration', 'peak_latency', 'peak_response', ...
        'corrected_peak', 'response_magnitude', 'corrected_response_magnitude', ...
        'total_sig_events', 'principal_event', 'norm_response_magnitude', 'recording_notes', ...
        'tot_clusters', 'first_cluster_first_latency', 'first_cluster_last_latency', ...
        'first_cluster_duration', 'first_cluster_peak_latency', 'first_cluster_peak_response', ...
        'first_cluster_corrected_peak', 'first_cluster_response_magnitude', ...
        'first_cluster_corrected_response_magnitude', 'first_cluster_norm_response_magnitude', ...
        'primary_cluster_first_latency', 'primary_cluster_last_latency', ...
        'primary_cluster_duration', 'primary_cluster_peak_latency', ...
        'primary_cluster_peak_response', 'primary_cluster_corrected_peak', ...
        'primary_cluster_response_magnitude', 'primary_cluster_corrected_response_magnitude', ...
        'primary_cluster_norm_response_magnitude', 'last_cluster_first_latency', ...
        'last_cluster_last_latency', 'last_cluster_duration', 'last_cluster_peak_latency', ...
        'last_cluster_peak_response', 'last_cluster_corrected_peak', ...
        'last_cluster_response_magnitude', 'last_cluster_corrected_response_magnitude', ...
        'last_cluster_norm_response_magnitude', 'bfr_s', 'bfr_var', 'fano', 'norm_var'
    };
    sprintf('Receptive field analysis for %s \n', dir_name);
    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_index).name);

            %% Load needed variables from psth and does the receptive field analysis
            load(file, 'psth_struct', 'event_info', 'label_log', 'filename_meta');

            %% Receptive field analysis
            rec_res = receptive_field_analysis(psth_struct, event_info, ...
                bin_size, window_start, window_end, baseline_start, ...
                baseline_end, response_start, response_end, span, threshold_scalar, ...
                sig_check, sig_alpha, consec_bins, mixed_smoothing);

            if config.cluster_analysis
                %% Cluster analysis
                [cluster_struct, cluster_res] = do_cluster_analysis(rec_res, psth_struct, ...
                    event_info, window_start, window_end, response_start, response_end, ...
                    bin_size, mixed_smoothing, span, consec_bins, bin_gap);
            end

            %% Normalized variance analysis
            nv_res = nv_calculation(psth_struct, event_info, window_start, window_end, ...
                baseline_start, baseline_end, bin_size, config.epsilon, config.norm_var_scaling);
            assert(height(rec_res) == height(nv_res), ...
                'Join assumes a 1-1 mapping but found %d rows in rf and %d rows in nv', ...
                height(rec_res), height(nv_res));
            rec_res = join(rec_res, nv_res, 'Keys', {'region', 'event', 'channel'});

            %% Save receptive field matlab output
            matfile = fullfile(save_path, ['rec_field_', filename_meta.filename, '.mat']);
            if config.cluster_analysis
                save(matfile, 'label_log', 'rec_res', 'filename_meta', 'config_log', ...
                    'cluster_struct', 'cluster_res');
            else
                save(matfile, 'label_log', 'rec_res', 'filename_meta', 'config_log');
            end

            %% Capture data to save to csv from current day
            meta_data = [
                {filename_meta.filename}, {filename_meta.animal_id}, ...
                {filename_meta.experimental_group}, ...
                {filename_meta.experimental_condition}, ...
                {filename_meta.optional_info}, filename_meta.session_date, ...
                filename_meta.session_num, window_start, baseline_start, ...
                baseline_end, window_end, response_start, response_end, bin_size, ...
                sig_alpha, mixed_smoothing, sig_check, consec_bins, span, threshold_scalar];

            %% Append to receptive field CSV
            tot_rows = height(rec_res);
            rec_res = horzcat_cell(rec_res, repmat(meta_data, [tot_rows, 1]), meta_headers, 'before');
            rec_res = removevars(rec_res, 'p_val');
            export_csv(rec_csv_path, rec_res, ignore_headers);

            if config.cluster_analysis
                %% Append to cluster analysis csv
                tot_rows = height(cluster_res);
                cluster_res = horzcat_cell(cluster_res, repmat(meta_data, [tot_rows, 1]), meta_headers, 'before');
                export_csv(cluster_csv_path, cluster_res, ignore_headers);
            end

            %% Clean up workspace
            if config.cluster_analysis
                clear('psth_struct', 'label_log', 'rec_res', 'filename_meta', ...
                    'event_info', 'cluster_struct', 'cluster_res');
            else
                clear('psth_struct', 'label_log', 'rec_res', 'filename_meta', ...
                    'event_info');
            end
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished receptive field analysis for %s. It took %s \n', ...
        dir_name, num2str(toc(rf_start)));
end