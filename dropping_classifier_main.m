function [] = dropping_classifier_main(varargin)
    %% Get data directory
    project_path = get_project_path(varargin);
    start_time = tic;

    %% Import psth config and removes ignored animals
    config = import_config(project_path, 'dropping_classifier');
    config(config.include_dir == 0, :) = [];

    dir_list = config.dir_name;
    for dir_i = 1:length(dir_list)
        curr_dir = dir_list{dir_i};
        dir_config = config(dir_i, :);
        dir_config = convert_table_cells(dir_config);
        label_table = load_labels(project_path, [curr_dir, '_labels.csv']);

        if strcmpi(dir_config.psth_type, 'psth')
            %% Creating paths to do psth formatting
            csv_modifier = 'psth';
            [psth_path, psth_failed_path] = create_dir(project_path, 'psth');
            [data_path, ~] = create_dir(psth_path, 'data');
            export_params(data_path, csv_modifier, config);
            if dir_config.create_psth
                try
                    %% Check to make sure paths exist for analysis and create save path
                    parsed_path = [project_path, '/parsed_spike'];
                    e_msg_1 = 'No parsed directory to create PSTHs';
                    e_msg_2 = ['No ', curr_dir, ' directory to create PSTHs'];
                    parsed_dir_path = enforce_dir_layout(parsed_path, curr_dir, psth_failed_path, e_msg_1, e_msg_2);
                    [dir_save_path, dir_failed_path] = create_dir(data_path, curr_dir);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%        Format PSTH         %%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    batch_format_psth(dir_save_path, dir_failed_path, parsed_dir_path, curr_dir, dir_config, label_table);
                catch ME
                    handle_ME(ME, psth_failed_path, [curr_dir, '_missing_dir.mat']);
                end
            else
                if ~exist(psth_path, 'dir') || ~exist(data_path, 'dir')
                    error('Must have PSTHs to run PSTH analysis on %s', curr_dir);
                end
            end
        elseif strcmpi(dir_config.psth_type, 'pca')
            csv_modifier = 'pca';
            psth_path = [project_path, '/pca_psth'];
            data_path = [psth_path, '/data'];
            if ~exist(psth_path, 'dir') || ~exist(data_path, 'dir')
                error('Must have PSTHs to run PSTH analysis on %s', curr_dir);
            end
        elseif strcmpi(dir_config.psth_type, 'ica')
            csv_modifier = 'ica';
            psth_path = [project_path, '/ica_psth'];
            data_path = [psth_path, '/data'];
            if ~exist(psth_path, 'dir') || ~exist(data_path, 'dir')
                error('Must have PSTHs to run PSTH analysis on %s', curr_dir);
            end
        else
            error('Invalid psth type %s, must be psth, pca, or ica', dir_config.psth_type);
        end


        [classifier_path, classifier_failed_path] = create_dir(psth_path, 'dropping_classifier');
        export_params(classifier_path, 'dropping_classifier', config);
        try
            %% Check to make sure paths exist for analysis and create save path
            e_msg_1 = 'No data directory to find PSTHs';
            e_msg_2 = ['No ', curr_dir, ' psth data for classifier analysis'];
            dir_psth_path = enforce_dir_layout(data_path, curr_dir, classifier_failed_path, e_msg_1, e_msg_2);
            [dir_save_path, dir_failed_path] = create_dir(classifier_path, curr_dir);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%        Classification      %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            batch_dropping_classifier(project_path, dir_save_path, dir_failed_path, ...
                dir_psth_path, curr_dir, csv_modifier, dir_config);
        catch ME
            handle_ME(ME, classifier_failed_path, [curr_dir, '_missing_dir.mat']);
        end
    end
    toc(start_time);
end