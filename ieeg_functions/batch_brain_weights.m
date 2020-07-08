function [] = batch_brain_weights(dir_name, save_path, failed_path, elec_path, ...
    pial_path, pca_data_path, dir_config)

    %% Load mesh files into mesh struct
    %! move to main potentially?
    if dir_config.is_pial
        pial_list = get_file_list(pial_path, '.pial');
        mesh_struct = struct;
        for file_i = 1:numel(pial_list)
            [~, pial_name, ~] = fileparts(pial_list(file_i).name);
            pial_file_path = fullfile(pial_path, pial_list(file_i).name);
            mesh_output = ft_read_headshape(pial_file_path);
            mesh_struct.(pial_name) = mesh_output;
        end
    else
        pial_list = get_file_list(pial_path, '.mat');
        mesh_struct = struct;
        for file_i = 1:numel(pial_list)
            [~, pial_name, ~] = fileparts(pial_list(file_i).name);
            pial_file_path = fullfile(pial_path, pial_list(file_i).name);
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
            load(pca_file, 'component_results', 'filename_meta', 'label_log');

            plot_brain_weights(save_path, dir_name, mesh_struct, elec, component_results, ...
                label_log, dir_config.min_components, dir_config.feature_filter, ...
                dir_config.feature_value, dir_config.save_png);

        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
end