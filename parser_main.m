function [] = parser_main()

    %% Get project directory and check for raw directory
    project_path = uigetdir(pwd);
    start_time = tic;
    raw_path = [project_path, '/raw'];
    if ~exist(raw_path, 'dir')
        error('No raw directory to parse files');
    end

    %% Create parsed directory
    [parsed_path, failed_path] = create_dir(project_path, 'parsed');

    %% Import parser config
    config = import_config(project_path, 'parser');
    export_params(parsed_path, 'parser', config);

    dir_list = dir(raw_path);
    dir_names = {dir_list([dir_list.isdir] == 1 ...
                    & ~contains({dir_list.name}, '.')).name};

    for dir_i = 1:length(dir_names)
        curr_dir = dir_names{dir_i};
        dir_config = config(strcmpi(config.dir_name, curr_dir), :);
        if ~ismember(curr_dir, config.dir_name)
            try
                error('%s is not in the config. Please add %s to parser config', ...
                    curr_dir, curr_dir);
            catch ME
                handle_ME(ME, failed_path, ['missing_', curr_dir, '_config.mat']);
            end
        end
        % Skips animals we want to ignore
        if dir_config.include_animal
            dir_path = fullfile(...
                                    dir_list(strcmpi(dir_names{dir_i}, ...
                                    {dir_list.name})).folder, curr_dir);
            [dir_save_path, dir_failed_path] = create_dir(parsed_path, curr_dir);
            %% load label table
            label_table = load_labels(project_path, [curr_dir, '_labels.csv']);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Parser           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            batch_parser(dir_save_path, dir_failed_path, dir_path, curr_dir, dir_config, label_table);
        else
            continue;
        end
    end
    toc(start_time);
end