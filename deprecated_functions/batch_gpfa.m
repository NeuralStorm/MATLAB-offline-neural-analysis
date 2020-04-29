function [trajectory_path] = batch_gpfa(psth_path, config)
    [trajectory_path, ~] = create_dir(psth_path, 'trajectories');
    file_list = get_file_list(psth_path, '.mat', config.ignore_sessions);

    for file_index = 1:length(file_list)
        psth_file = [psth_path, '/', file_list(file_index).name];
        [~, psth_filename, ~] = fileparts(psth_file);
        load(psth_file, 'selected_data', 'psth_struct');
        [animal_id, ~, ~, session_num, ~, ~] = get_filename_info(psth_filename);
        [gpfa_results] = do_gpfa(animal_id, session_num, selected_data, psth_struct, ...
            config.bin_size, config.window_start, config.window_end, config.state_dimension);

        %% GPFA to PSTH
        [psth_struct, selected_data] = gpfa_to_psth(gpfa_results, psth_struct, selected_data);

        %% Saving the file
        %TODO write generalized filename checking function that checks length of filename and erases first x enteries if it is too long
        filename = erase(psth_filename, ['PSTH', '.', 'format', '.']);
        filename = erase(filename, ['PSTH', '_', 'format', '_']);
        matfile = fullfile(trajectory_path, ['gpfa_results_', filename, '.mat']);
        save(matfile, 'gpfa_results', 'psth_struct', 'selected_data');

    end
end