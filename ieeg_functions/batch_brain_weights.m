function [] = batch_brain_weights(dir_name, save_path, failed_path, elec_path, ...
    mesh_path, pca_data_path, dir_config)

    %% Purpose: Go through file list and plot electrode weights onto 3D brain mesh
    %% Input:
    % dir_name: Name of dir that data came from (usually subject #)
    % save_path: path to save files at
    % failed_path: path to save errors at
    % elec_path: path to load files with electrode anatomy
    % mesh_path: path where pial or fieldtrip .mat files contain brain mesh for plotting
    % pca_data_path: path to load pca results from
    % dir_config: config settings for that subject
    %% Output:
    %  No output, plots are saved at specified save location

    fprintf('Graphing PCA meshes for %s \n', dir_name);
    mesh_start = tic;

    %% Load mesh files into mesh struct
    %! move to main potentially?
    if dir_config.is_pial
        mesh_list = get_file_list(mesh_path, '.pial'); 
        mesh_struct = struct;
        for file_i = 1:numel(mesh_list)
            [~, pial_name, ~] = fileparts(mesh_list(file_i).name);
            pial_file_path = fullfile(mesh_path, mesh_list(file_i).name);
            mesh_output = ft_read_headshape(pial_file_path);
            mesh_struct.(pial_name) = mesh_output;
        end
    else
        mesh_list = get_file_list(mesh_path, '.mat');
        mesh_struct = struct;
        for file_i = 1:numel(mesh_list)
            [~, pial_name, ~] = fileparts(mesh_list(file_i).name);
            pial_file_path = fullfile(mesh_path, mesh_list(file_i).name);
            load(pial_file_path, 'mesh');
            mesh_struct.(pial_name) = mesh;
        end
    end

    %% dir electrode file
    %! check assumption that there will not be multiple electode mappings for subjects
    elec_file = get_file_list(elec_path, '.mat');
    assert(numel(elec_file) == 1)
    elec_file = fullfile(elec_path, elec_file(1).name);
    load(elec_file, 'elec');

    %% PCA file list
    pca_file_list = get_file_list(pca_data_path, '.mat');
    pca_file_list = update_file_list(pca_file_list, failed_path, dir_config.include_sessions);

    %% Go through files and load relevant parameters
    for file_index = 1:numel(pca_file_list)
        [~, filename, ~] = fileparts(pca_file_list(file_index).name);
        filename_meta.filename = filename;
        try
            pca_file = fullfile(pca_data_path, pca_file_list(file_index).name);
            load(pca_file, 'component_results', 'filename_meta', 'chan_group_log');

            plot_brain_weights(save_path, dir_name, mesh_struct, elec, component_results, ...
                chan_group_log, dir_config.min_components, dir_config.feature_filter, ...
                dir_config.feature_value, dir_config.save_png);

            clear('component_results', 'filename_meta', 'chan_group_log');

        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
    fprintf('Finished PCA mesh plots for %s. It took %s \n', ...
        dir_name, num2str(toc(mesh_start)));
end