function [] = output_sep_csv()
    project_path = uigetdir();
    %% See if csv already exists
    dir_list = dir(project_path);
    dir_list = dir_list([dir_list.isdir] == 1 ...
        & ~contains({dir_list.name}, {'.', '..'}));
    csv_path = fullfile(project_path, 'sep_analysis_results.csv');

    for dir_i = 1:length(dir_list)
        %% Go through directories present
        curr_dir = dir_list(dir_i).name;
        dir_path = [dir_list(dir_i).folder, '/', curr_dir];
        file_list = get_file_list(dir_path, '.mat');
        for file_i = 1:length(file_list)
            %% Go through files and format tables
            file = fullfile(dir_path, file_list(file_i).name);
            load(file, 'sep_analysis_results', 'filename_meta');
            sep_table = struct2table(sep_analysis_results);
            sep_table = removevars(sep_table, {'animal_id', 'sep_sliced_data', ...
                'exp_group', 'exp_cond', 'rec_session'});

            %% Get filename info out of filename_meta struct
            filename_info = [];
            filename_fields = fieldnames(filename_meta);
            for field_i = 1:length(filename_fields)
                field = filename_fields{field_i};
                filename_info = [filename_info, {filename_meta.(field)}];
            end
            filename_cells = repmat(filename_info, [height(sep_table),1]);
            filename_table = cell2table(filename_cells, 'VariableNames', fieldnames(filename_meta)');
            output_table = [filename_table, sep_table];
            % export_csv(csv_path, column_names, filename_table, sep_table)
            export_csv(csv_path, output_table, {});
        end
    end
end