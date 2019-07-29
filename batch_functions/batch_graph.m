function [] = batch_graph(animal_name, data_path, dir_name, search_ext, filename_substring_one, filename_substring_two, ...
                total_bins, bin_size, pre_time, rf_analysis, rf_path, make_region_subplot, sub_columns)
    graph_start = tic;
    [files, graph_path, failed_path] = create_dir(data_path, dir_name, search_ext);

    fprintf('Graphing for %s \n', animal_name);
    %% Goes through all the files and calculates mutual info according to the parameters set in config
    for file_index = 1:length(files)
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, files(file_index).name);
            [~, filename, ~] = fileparts(file);
            filename = erase(filename, [filename_substring_one, '.', filename_substring_two, '.']);
            filename = erase(filename, [filename_substring_one, '_', filename_substring_two, '_']);
            [~, ~, ~, session_num, ~, ~] = get_filename_info(filename);
            load(file, 'event_struct', 'labeled_neurons');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, event_struct, labeled_neurons);
            if empty_vars
                continue
            end

            % Creates the day directory if it does not already exist
            day_path = [graph_path, '/', num2str(session_num)];
            if ~exist(day_path, 'dir')
                mkdir(graph_path, num2str(session_num));
            end

            if rf_analysis
                %% Load receptive field data
                rf_file = [rf_path, '/', files(file_index).name];
                [rf_path, rf_filename, ~] = fileparts(rf_file);
                rf_filename = strrep(rf_filename, filename_substring_one, 'rec');
                rf_filename = strrep(rf_filename, filename_substring_two, 'field');
                rf_matfile = fullfile(rf_path, [rf_filename, '.mat']);
                load(rf_matfile, 'sig_neurons', 'non_sig_neurons');
                graph_PSTH(day_path, event_struct, labeled_neurons, sig_neurons, non_sig_neurons, ...
                    total_bins, bin_size, pre_time, rf_analysis, make_region_subplot, sub_columns)
            else
                graph_PSTH(day_path, event_struct, labeled_neurons, NaN, NaN, total_bins, bin_size, ...
                    pre_time, rf_analysis, make_region_subplot, sub_columns)
            end
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end
    fprintf('Finished graphing for %s. It took %s \n', ...
        animal_name, num2str(toc(graph_start)));
end