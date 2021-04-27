function [] = batch_dropping_classifier(project_path, save_path, failed_path, ...
                            data_path, dir_name, chan_type, config)

    is_unrecoverable = false;
    classifier_start = tic;
    config_log = config;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

    %% Create csv paths
    res_csv_path = fullfile(project_path, [chan_type, '_chan_dropping.csv']);

    %% Pull variable names into workspace scope for log
    bin_size = config.bin_size; window_start = config.window_start;
    window_end = config.window_end; response_start = config.response_start;
    response_end = config.response_end; include_events = config.include_events;
    drop_method = config.drop_method;

    meta_headers = {'filename', 'animal_id', 'exp_group', 'exp_condition', ...
        'optional_info', 'date', 'record_session', 'bin_size', 'window_start', ...
        'response_start', 'response_end', 'window_end', ...
        'drop_method', 'include_events'};
    ignore_headers = {'include_events', 'user_channels'};

    fprintf('PSTH classification for %s \n', dir_name);

    %% Pull csv results from classifications to determine drop order
    is_csv = any(ismember(config.drop_method, {'performance', 'mutual_info', 'corrected_info'}));
    if is_csv
        chan_csv_path = fullfile(project_path, [chan_type,'_chan_classification_info.csv']);
        if exist(chan_csv_path, 'file')
            chan_table = readtable(chan_csv_path);
        else
            %% Unrecoverable error for all files
            is_unrecoverable = true;
            error('Must have classifier results for channels before dropping with %s', drop_method)
        end
    end

    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        %% Run through files
        try
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'psth_struct', 'event_info', 'filename_meta', 'label_log');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, psth_struct, event_info, label_log);
            if empty_vars
                continue
            end

            if is_csv
                %% Filter table on filename, response window, and bin size
                chan_info = chan_table(strcmpi(chan_table.filename, filename_meta.filename) ...
                        & chan_table.bin_size == bin_size ...
                        & chan_table.response_start == response_start ...
                        & chan_table.response_end == response_end, :);
                if isempty(chan_info)
                    error('Must have classifier results for channels before dropping with %s', drop_method);
                end
            elseif strcmpi(drop_method, 'percent_var')
                var_path = [project_path, '/mnts/', chan_type, '/', dir_name];
                if strcmpi(chan_type, 'pca')
                    var_file = fullfile(var_path, ['pc_analysis_', filename_meta.filename, '.mat']);
                elseif strcmpi(chan_type, 'ica')
                    var_file = fullfile(var_path, ['ic_analysis_', filename_meta.filename, '.mat']);
                else
                    %% Unrecoverable error for all files
                    is_unrecoverable = true;
                    error('Cannot do percent variance dropping with %s type. Try pca or ica', config.psth_type);
                end
                load(var_file, 'component_results');
                chan_info = get_chan_vars(component_results);
            elseif strcmpi(drop_method, 'random')
                chan_info = label_log;
                chan_info = renamevars(chan_info, "label", "region");
            else
                is_unrecoverable = true;
                error('Unknown drop method: %s')
            end

            if config.combine_regions
                psth_struct = combine_regions(psth_struct);
                %% Convert region label to match combined region label
                tot_rows = height(chan_info);
                chan_info.region = repmat("all_regions", [tot_rows, 1]);
            end

            %% Drop classify
            pop_table = dropping_classifier(psth_struct, event_info, drop_method, ...
                chan_info, bin_size, window_start, window_end, ...
                response_start, response_end);

            %% Add meta data to table before export to csv
            meta_data = [
                {filename_meta.filename}, {filename_meta.animal_id}, ...
                {filename_meta.experimental_group}, ...
                {filename_meta.experimental_condition}, ...
                {filename_meta.optional_info}, filename_meta.session_date, ...
                filename_meta.session_num, bin_size, window_start, ...
                response_start, response_end, window_end, drop_method, include_events
            ];
            tot_rows = height(pop_table);
            pop_table = horzcat_cell(pop_table, repmat(meta_data, [tot_rows, 1]), meta_headers, 'before');
            %% Append to CSV
            export_csv(res_csv_path, pop_table, ignore_headers)
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
            if is_unrecoverable
                break
            end
        end
    end
    fprintf('Finished PSTH classifier for %s. It took %s \n', ...
        dir_name, num2str(toc(classifier_start)));
end

function [res] = get_chan_vars(component_results)
    headers = [["region", "string"]; ["channel", "string"]; ["variance", "double"]];
    res = prealloc_table(headers, [0, size(headers, 1)]);
    unique_regions = fieldnames(component_results);
    for reg_i = 1:numel(unique_regions)
        region = unique_regions{reg_i};
        reg_chans = component_results.(region).label_order;
        tot_chans = numel(reg_chans);
        reg_vars = component_results.(region).component_variance;
        reg_vars = reg_vars(1:numel(reg_chans));
        a = [repmat({region}, [tot_chans, 1]), reg_chans, num2cell(reg_vars)];
        res = vertcat_cell(res, a, headers(:, 1), "after");
    end
end