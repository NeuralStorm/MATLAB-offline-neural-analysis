function [] = batch_nv(animal_name, original_path, data_path, dir_name, ...
        search_ext, filename_substring_one, filename_substring_two, config)
    %% Check pre time is valid for analysis
    if abs(config.pre_time) <= 0.050
        error('Pre time ~= 0 for normalized variance analysis. Create psth with pre time > 0.');
    end
    nv_start = tic;

    %% NV set up
    [psth_files, nv_path, failed_path] = create_dir(data_path, dir_name, search_ext);
    general_column_names = {'animal', 'group', 'date', 'record_session'};
    analysis_column_names = {'event', 'region', 'channel', 'avg_background_rate', ...
        'background_var', 'norm_var', 'fano', 'notes'};
    column_names = [general_column_names, analysis_column_names];

    fprintf('Normalized variance analysis for %s \n', animal_name);
    all_neurons = [];
    general_info = table;
    for file_index = 1:length(psth_files)
        %% Run through files
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, psth_files(file_index).name);
            [~, filename, ~] = fileparts(file);
            filename = erase(filename, [filename_substring_one, '.', filename_substring_two, '.']);
            filename = erase(filename, [filename_substring_one, '_', filename_substring_two, '_']);
            [~, experimental_group, ~, session_num, session_date, ~] = get_filename_info(filename);
            load(file, 'labeled_neurons', 'event_struct');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, event_struct, labeled_neurons);
            if empty_vars
                continue
            end
            %% NV analysis
            neuron_activity = nv_calculation(labeled_neurons, event_struct, config.pre_time, config.post_time, ...
                config.bin_size, config.epsilon, config.norm_var_scaling, config.separate_events, analysis_column_names);

            %% Store metadata about file
            current_general_info = [{animal_name}, {experimental_group}, session_date, session_num];
            [general_info, all_neurons] = ...
                concat_tables(general_column_names, general_info, current_general_info, all_neurons, neuron_activity);

            %% Save analysis results
            matfile = fullfile(nv_path, ['NV_analysis_', filename, '.mat']);
            check_variables(matfile, labeled_neurons, neuron_activity);
            save(matfile, 'labeled_neurons', 'neuron_activity');
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end
    %% CSV export set up
    csv_path = fullfile(original_path, 'norm_var.csv');
    export_csv(csv_path, column_names, general_info, all_neurons);

    fprintf('Finished normalized variance analysis for %s. It took %s \n', ...
        animal_name, num2str(toc(nv_start)));
end