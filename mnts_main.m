function [] = mnts_main()
    %% Get directory with all animals and their data
    original_path = uigetdir(pwd);
    start_time = tic;
    animal_list = dir(original_path);
    animal_names = {animal_list([animal_list.isdir] == 1 & ~contains({animal_list.name}, '.')).name};
    for animal = 1:length(animal_names)
        animal_name = animal_names{animal};
        animal_path = fullfile(...
            animal_list(strcmpi(animal_names{animal}, {animal_list.name})).folder, animal_name);
        config = import_config(animal_path, 'mnts');
        export_params(animal_path, 'main', config);
        check_time(config.pre_time, config.pre_start, config.pre_end, config.post_time, ...
            config.post_start, config.post_end, config.bin_size);
        % Skips animals we want to ignore
        if config.ignore_animal
            continue;
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Parser           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.parse_files
                %% Parse files
                %! Might remove the file handling in the future
                parsed_path = parser(animal_path, animal_name, config.total_trials, ...
                    config.total_events, config.trial_lower_bound, ...
                    config.is_non_strobed_and_strobed, config.event_map, config.ignore_sessions);
            else
                parsed_path = [animal_path, '/parsed'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%       Label Channels       %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.label_channels
                batch_label(animal_path, animal_name, parsed_path);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%            MNTS            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.create_mnts
                mnts_path = batch_format_mnts(parsed_path, animal_name, config);
            else
                mnts_path = [parsed_path, '/mnts'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %             PCA            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.pc_analysis
                pca_path = batch_pca(mnts_path, animal_name, config);
            else
                pca_path = [mnts_path, '/pca'];
            end

            if config.convert_mnts_psth
                psth_path = batch_mnts_to_psth(animal_name, pca_path, 'psth', ...
                    '.mat', 'pc', 'analysis', 'pca_psth', config);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     Normalized Variance    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.nv_analysis
                batch_nv(animal_name, original_path, psth_path, 'normalized_variance_analysis', ...
                    '.mat', 'pca', 'psth', config);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.rf_analysis
                pc_rf_path = batch_recfield(animal_name, original_path, psth_path, 'receptive_field_analysis', ...
                    '.mat', 'pca', 'psth', config);
            else
                pc_rf_path = [psth_path, '/receptive_field_analysis'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, psth_path, 'pc_graphs', '.mat', 'pca', 'psth', ...
                    config.bin_size, config.pre_time, config.post_time, config.pre_start, ...
                    config.pre_end, config.post_start, config.post_end, config.rf_analysis, pc_rf_path, ...
                    config.make_region_subplot, config.sub_columns, config.sub_rows, config.ignore_sessions);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.psth_classify
                batch_classify(animal_name, original_path, psth_path, 'classifier', '.mat', ...
                    'pca', 'psth', config);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.info_analysis
                batch_info(animal_name, psth_path, 'mutual_info', ...
                    '.mat', 'pca', 'psth', config.ignore_sessions);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %             ICA            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.ic_analysis
                ica_path = batch_ica(mnts_path, animal_name, config);
            end

            if config.convert_mnts_psth
                psth_path = batch_mnts_to_psth(animal_name, ica_path, 'psth', ...
                    '.mat', 'ic', 'analysis', 'ica_psth', config);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     Normalized Variance    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.nv_analysis
                batch_nv(animal_name, original_path, psth_path, 'normalized_variance_analysis', ...
                    '.mat', 'ica', 'psth', config)
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.rf_analysis
                ic_rf_path = batch_recfield(animal_name, original_path, psth_path, 'receptive_field_analysis', ...
                    '.mat', 'ica', 'psth', config);
            else
                ic_rf_path = [psth_path, '/receptive_field_analysis'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, psth_path, 'ic_graphs', '.mat', 'ica', 'psth', ...
                    config.bin_size, config.pre_time, config.post_time, config.pre_start, ...
                    config.pre_end, config.post_start, config.post_end, config.rf_analysis, ic_rf_path, ...
                    config.make_region_subplot, config.sub_columns, config.sub_rows, config.ignore_sessions);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.psth_classify
                batch_classify(animal_name, original_path, psth_path, 'classifier', '.mat', ...
                    'ica', 'psth', config);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.info_analysis
                batch_info(animal_name, psth_path, 'mutual_info', ...
                    '.mat', 'ica', 'psth', config.ignore_sessions);
            end

        end
    end
    toc(start_time);
end