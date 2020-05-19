function [] = batch_plot_tfr_pca_psth(save_path, failed_path, tfr_path, ...
        pca_data_path, pca_psth_path, dir_config)

    %% PCA file list
    pca_file_list = get_file_list(pca_data_path, '.mat');
    pca_file_list = update_file_list(pca_file_list, failed_path, dir_config.include_sessions);

    %% PCA file list
    psth_file_list = get_file_list(pca_psth_path, '.mat');
    psth_file_list = update_file_list(psth_file_list, failed_path, dir_config.include_sessions);

    %% TFR file list
    %TODO session num?
    tfr_file_list = get_file_list(tfr_path, '.fig');

    %% Go through files and load relevant parameters
    for file_index = 1:length(pca_file_list)
        [~, filename, ~] = fileparts(pca_file_list(file_index).name);
        filename_meta.filename = filename;
        try
            pca_file = fullfile(pca_data_path, pca_file_list(file_index).name);
            load(pca_file, 'component_results', 'filename_meta', 'label_log');

            if any(contains({psth_file_list.name}, filename_meta.filename))
                psth_filename = psth_file_list(...
                    contains({psth_file_list.name}, filename_meta.filename)).name;
                psth_file = fullfile(pca_psth_path, psth_filename);
                load(psth_file, 'psth_struct', 'pc_log');
            else
                error('Missing %s to plot PSTH time course', filename_meta.filename);
            end

            plot_tfr_pca_psth(save_path, tfr_path, tfr_file_list, label_log, pc_log, ...
                component_results, psth_struct, dir_config.bin_size, ...
                dir_config.window_start, dir_config.window_end, dir_config.baseline_start, ...
                dir_config.baseline_end, dir_config.response_start, ...
                dir_config.response_end, dir_config.feature_filter, ...
                dir_config.feature_value, dir_config.sub_rows, ...
                dir_config.sub_columns, dir_config.st_type, dir_config.ymax_scale, ...
                dir_config.transparency, dir_config.min_components);

        catch ME
            handle_ME(ME, failed_path, filename_meta.filename);
        end
    end
end