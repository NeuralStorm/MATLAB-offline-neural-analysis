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
            %% Checks to see if parsed directory exists
            parsed_path = [animal_path, '/', 'parsed'];
            if ~exist(parsed_path, 'dir')
                error('Parsed directory does not exist. Please run the Parser main to parse files');
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%            MNTS            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.create_mnts
                mnts_path = batch_format_mnts(animal_path, parsed_path, animal_name, config);
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
                    '.mat', 'pca', config);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.rf_analysis
                pc_rf_path = batch_recfield(animal_name, original_path, psth_path, 'receptive_field_analysis', ...
                    '.mat', 'pca', config);
            else
                pc_rf_path = [psth_path, '/receptive_field_analysis'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, psth_path, 'pc_graphs', '.mat', config, pc_rf_path);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.psth_classify
                batch_classify(animal_name, original_path, psth_path, 'classifier', '.mat', ...
                    'pca', config);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.info_analysis
                batch_info(animal_name, psth_path, 'mutual_info', ...
                    '.mat', config.ignore_sessions);
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

            if config.convert_mnts_psth
                psth_path = batch_mnts_to_psth(animal_name, ica_path, 'psth', ...
                    '.mat', 'ic', 'analysis', 'ica_psth', config);
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
                    '.mat', 'ica', config)
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Receptive Field Analysis  %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.rf_analysis
                ic_rf_path = batch_recfield(animal_name, original_path, psth_path, 'receptive_field_analysis', ...
                    '.mat', 'ica', config);
            else
                ic_rf_path = [psth_path, '/receptive_field_analysis'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Graph PSTH         %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.make_psth_graphs
                batch_graph(animal_name, psth_path, 'ic_graphs', '.mat', config, ic_rf_path);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%     PSTH Classification    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.psth_classify
                batch_classify(animal_name, original_path, psth_path, 'classifier', '.mat', ...
                    'ica', config);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Information Analysis    %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.info_analysis
                batch_info(animal_name, psth_path, 'mutual_info', ...
                    '.mat', config.ignore_sessions);
            end

        end
    end
    toc(start_time);
end