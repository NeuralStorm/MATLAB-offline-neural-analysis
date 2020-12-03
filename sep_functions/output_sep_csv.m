function [] = output_sep_csv()
    project_path = uigetdir();

    %% Set up failed path and removed past failed directory
    failed_path = [project_path, '\', 'failed_export_csv'];
    if exist(failed_path, 'dir') == 7
        delete([failed_path, '/*']);
        rmdir(failed_path);
    end

    %% See if csv already exists
    dir_list = dir(project_path);
    dir_list = dir_list([dir_list.isdir] == 1 ...
        & ~contains({dir_list.name}, {'.', '..', 'failed'}));
    csv_path = fullfile(project_path, 'sep_analysis_results.csv');
    final_table = table;
    for dir_i = 1:length(dir_list)
        %% Go through directories present
        curr_dir = dir_list(dir_i).name;
        disp(['Reading files from... ', curr_dir]);
        dir_path = [dir_list(dir_i).folder, '/', curr_dir];
        file_list = get_file_list(dir_path, '.mat');
        for file_i = 1:length(file_list)
            %% Go through files and format tables
            file = fullfile(dir_path, file_list(file_i).name);
            try
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

                %% Go through double arrays and convert to string to prevent multidimensional
                %% appending errors with final table
                headers = output_table.Properties.VariableNames;
                for col_i = 1:width(output_table)
                    curr_col = headers{col_i};
                    curr_type = class(output_table.(curr_col));
                    if ismember(curr_type, 'double')
                        output_table.(curr_col) = cellstr(num2str(output_table.(curr_col)));
                    end
                end

                final_table = [final_table; output_table];
            catch ME
                handle_ME(ME, failed_path, [filename_meta.filename, '_failed.mat']);
            end
        end
    end
    disp('Saving CSV...');
    export_csv(csv_path, final_table, {});
end