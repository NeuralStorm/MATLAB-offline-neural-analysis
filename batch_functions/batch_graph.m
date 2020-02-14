function [] = batch_graph(animal_name, data_path, dir_name, search_ext, config, rf_path)

    graph_start = tic;
    
    [graph_path, failed_path] = create_dir(data_path, dir_name);
    files = get_file_list(data_path, search_ext, config.ignore_sessions);
    
    fprintf('Graphing for %s \n', animal_name);
    %% Goes through all the files and calculates mutual info according to the parameters set in config
    for file_index = 1:length(files)
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, files(file_index).name);
            load(file, 'psth_struct', 'labeled_data', 'filename_meta');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, psth_struct, labeled_data);
            if empty_vars
                continue
            end

            % Creates the day directory if it does not already exist
            day_path = [graph_path, '/', num2str(filename_meta.session_num)];
            if ~exist(day_path, 'dir')
                mkdir(graph_path, num2str(filename_meta.session_num));
            end

            if config.rf_analysis
                %% Load receptive field data
                rf_matfile = fullfile(rf_path, ['rec_field_', filename_meta.filename, '.mat']);
                load(rf_matfile, 'sig_neurons', 'non_sig_neurons');
                graph_PSTH(day_path, psth_struct, labeled_data, sig_neurons, non_sig_neurons, ...
                    config, filename_meta.filename)
            else
                graph_PSTH(day_path, psth_struct, labeled_data, NaN, NaN, config, ...
                filename_meta.filename)
            end
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished graphing for %s. It took %s \n', ...
        animal_name, num2str(toc(graph_start)));
end