function [] = batch_graph_psth(save_path, failed_path, data_path, dir_name, config, rf_path)
    graph_start = tic;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

    fprintf('Graphing for %s \n', dir_name);
    %% Goes through all the files and calculates mutual info according to the parameters set in config
    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'psth_struct', 'event_info', 'filename_meta');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, psth_struct, event_info);
            if empty_vars
                continue
            end

            if config.plot_rf
                %% Load receptive field data and verify parameters match
                rf_matfile = fullfile(rf_path, ['rec_field_', filename_meta.filename, '.mat']);
                load(rf_matfile, 'rec_res', 'config_log');
                assert(config.bin_size       == config_log.bin_size ...
                    & config.window_start    == config_log.window_start ...
                    & config.window_end      == config_log.window_end ...
                    & config.baseline_start  == config_log.baseline_start ...
                    & config.baseline_end    == config_log.baseline_end ...
                    & config.response_start  == config_log.response_start ...
                    & config.response_end    == config_log.response_end ...
                    & config.span            == config_log.span ...
                    & config.mixed_smoothing == config_log.mixed_smoothing, ...
                    ['Config parameters do not match recfield config log.', ...
                    ' Make sure recfield parameters match psth parameters'])
            else
                rec_res = NaN;
            end
            graph_PSTH(save_path, filename_meta.filename, psth_struct, event_info, ...
                config.bin_size, config.window_start, config.window_end, ...
                config.baseline_start, config.baseline_end, config.response_start, ...
                config.response_end, config.sub_rows, config.sub_cols, ...
                config.plot_rf, rec_res, config.mixed_smoothing, config.span);
            clear('rec_res', 'config_log', 'filename_meta', 'psth_struct', 'event_info');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished graphing for %s. It took %s \n', ...
        dir_name, num2str(toc(graph_start)));
end