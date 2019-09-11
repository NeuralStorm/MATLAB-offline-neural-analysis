function parsed_path = sep_parser(animal_name, animal_path, ignore_sessions)
    %% Parse files
    parse_start = tic;
    [parsed_path, failed_path] = create_dir(animal_path, 'parsed');
    [file_list] = get_file_list(animal_path, '.rh*', ignore_sessions);
    fprintf('Parsing for %s\n', animal_name);
    % Data mapping for rhd files
    % Runs through all of the files in the selected directory
    if ~isempty(file_list)
        for file_index = 1:length(file_list)
            file = [animal_path, '/', file_list(file_index).name];
            [animal_path, file_name, ~] = fileparts(file);
            % Read data from the path
            [board_band_map, board_adda_map, board_dig_in_data, t_amplifier, ...
                sample_rate] = board_band_parser(file);

            matfile = fullfile(parsed_path, [file_name, '.mat']);
            save(matfile, '-v7.3', 'board_band_map', 'board_adda_map', 'board_dig_in_data',  ...
                    't_amplifier', 'sample_rate');
        end
    else
        warning('No files to be parsed in the directory.');
    end
    fprintf('Finished parsing for %s. It took %s s\n', ...
        animal_name, num2str(toc(parse_start)));
end