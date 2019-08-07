function [rf_path] = batch_recfield(animal_name, original_path, data_path, dir_name, ...
        search_ext, filename_substring_one, filename_substring_two, config)
    %% Make sure rf analysis has enough pre time to determine threshold
    if abs(config.pre_time) <= 0.050
        error('Pre time ~= 0 for receptive field analysis. Create psth with pre time > 0.');
    end

    rf_start = tic;

    %% Rec field general set up
    [files, rf_path, failed_path] = create_dir(data_path, dir_name, search_ext);
    general_column_names = {'animal', 'group', 'date', 'record_session', 'pre_time', 'post_time', ...
        'bin_size', 'sig_check', 'sig_bins', 'span', 'threshold_scale'};
    analysis_column_names = {'region', 'channel', 'event', 'significant', ...
        'background_rate', 'background_std', 'threshold', 'first_latency', 'last_latency', 'duration', ...
        'peak_latency', 'peak_response', 'corrected_peak', 'response_magnitude', 'corrected_response_magnitude', ...
        'total_sig_events', 'principal_event', 'norm_magnitude', 'notes'};
    column_names = [general_column_names, analysis_column_names];

    fprintf('Receptive field analysis for %s \n', animal_name);
    all_neurons = [];
    general_info = table;
    for file_index = 1:length(files)
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, files(file_index).name);
            [~, filename, ~] = fileparts(file);
            filename = erase(filename, [filename_substring_one, '.', filename_substring_two, '.']);
            filename = erase(filename, [filename_substring_one, '_', filename_substring_two, '_']);
            [animal_id, experimental_group, ~, session_num, session_date, ~] = get_filename_info(filename);

            %% Load needed variables from psth and does the receptive field analysis
            load(file, 'labeled_data', 'psth_struct');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, psth_struct, labeled_data);
            if empty_vars
                continue
            end

            [sig_neurons, non_sig_neurons] = receptive_field_analysis( ...
                labeled_data, psth_struct, config.bin_size, config.threshold_scale, ...
                config.sig_check, config.sig_bins, config.span, analysis_column_names);

            %% Capture data to save to csv from current day
            session_neurons = [sig_neurons; non_sig_neurons];
            current_general_info = [{animal_id}, {experimental_group}, session_date, ...
                session_num, config.pre_time, config.post_time, config.bin_size, ...
                config.sig_check, config.sig_bins, config.span, config.threshold_scale];
            [general_info, all_neurons] = ...
                concat_tables(general_column_names, general_info, current_general_info, all_neurons, session_neurons);

            %% Save receptive field matlab output
            % Does not check if variables are empty since there may/may not be significant responses in a set
            matfile = fullfile(rf_path, ['rec_field_', filename, '.mat']);
            save(matfile, 'labeled_data', 'sig_neurons', 'non_sig_neurons');
            export_params(rf_path, 'receptive_field_analysis', rf_path, failed_path, ...
                animal_name, config);
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end

    %% CSV export set up
    csv_path = fullfile(original_path, 'receptive_field_results.csv');
    export_csv(csv_path, column_names, general_info, all_neurons);

    fprintf('Finished receptive field analysis for %s. It took %s \n', ...
        animal_name, num2str(toc(rf_start)));
end