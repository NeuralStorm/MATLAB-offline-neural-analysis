function [] = batch_power_graph_psth(graph_path, failed_path, data_path, dir_name, config)
    graph_start = tic;
    file_list = get_file_list(data_path, '.mat');
    file_list = update_file_list(file_list, failed_path, config.include_sessions);

    config.make_unit_plot = false;

    fprintf('Graphing for %s \n', dir_name);
    %% Goes through all the files and calculates mutual info according to the parameters set in config
    for file_index = 1:length(file_list)
        [~, filename, ~] = fileparts(file_list(file_index).name);
        filename_meta.filename = filename;
        try
            %% pull info from filename and set up file path for analysis
            file = fullfile(data_path, file_list(file_index).name);
            load(file, 'psth_struct', 'pc_log', 'filename_meta');
            %% Check psth variables to make sure they are not empty
            empty_vars = check_variables(file, psth_struct, pc_log);
            if empty_vars
                continue
            end

            % Creates the day directory if it does not already exist
            unique_powers = fieldnames(pc_log);
            for pow_i = 1:length(unique_powers)
                bandname = unique_powers{pow_i};
                power_path = [graph_path, '/', bandname];
                if ~exist(power_path, 'dir')
                    mkdir(graph_path, bandname);
                end

                power_graph_PSTH(power_path, psth_struct.(bandname), pc_log.(bandname), config);
            end
            clear('psth_struct', 'pc_log', 'filename_meta');
        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished graphing for %s. It took %s \n', ...
        dir_name, num2str(toc(graph_start)));
end