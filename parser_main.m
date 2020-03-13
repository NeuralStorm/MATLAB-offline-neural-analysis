function [] = parser_main()
    %% Get project directory and check for raw directory
    project_path = uigetdir(pwd);
    start_time = tic;
    raw_path = [project_path, '/raw'];
    if ~exist(raw_path, 'dir')
        error('No raw directory to parse files');
    end

    %% Import parser config, remove ignored animals, export log
    config = import_config(project_path, 'parser');
    config(config.include_animal == 0, :) = [];

    dir_list = config.dir_name;
    for dir_i = 1:length(dir_list)
        %% Set up directories for parsing and load labels
        curr_dir = dir_list{dir_i};
        dir_config = config(strcmpi(config.dir_name, curr_dir), :);
        label_table = load_labels(project_path, [curr_dir, '_labels.csv']);

        %% Check if spike or continuous
        %TODO handle scenario where both is included
        if strcmpi(dir_config.recording_type, 'spike')
            [parsed_path, failed_path]= create_dir(project_path, 'parsed_spike');
        elseif strcmpi(dir_config.recording_type, 'continuous')
            [parsed_path, failed_path]= create_dir(project_path, 'parsed_continuous');
        end
        export_params(parsed_path, 'parser', config);

        %% Check to make sure paths exist for analysis and create save path
        e_msg_1 = 'No raw directory to parse';
        e_msg_2 = ['No ', curr_dir, ' directory to parse'];
        raw_data_path = enforce_dir_layout(raw_path, curr_dir, failed_path, e_msg_1, e_msg_2);
        [dir_save_path, dir_failed_path] = create_dir(parsed_path, curr_dir);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%           Parser           %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        batch_parser(dir_save_path, dir_failed_path, raw_data_path, curr_dir, dir_config, label_table);
    end
    toc(start_time);
end