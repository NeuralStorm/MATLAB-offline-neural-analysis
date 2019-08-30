function parsed_path = sep_parser(animal_name, animal_path)                
    %% Parse files
    parse_start = tic;
    % Creates a list of all the files in the given directory ending with
    %TODO grab unique file extensions and use switch on valid file
    %extensions
    file_type = [animal_path, '/*.rh*'];
    file_list = dir(file_type);
    file_names = {file_list([file_list.isdir] == 0).name};
    fprintf('Parsing for %s\n', animal_name);
    % Data mapping for rhd files
    % Runs through all of the files in the selected directory
    if ~isempty(file_names)
        for file_index = 1: length(file_names)
                file = [animal_path, '/', file_names{file_index}];
                % Read data from the path 
                [board_band_map, board_adda_map, board_dig_in_data, t_amplifier, ...
                    sample_rate] = board_band_parser(file);
    %% Saves parsed files
                if ~isnan(sample_rate)        
                    [animal_path, file_name, ~] = fileparts(file);
                    parsed_path = [animal_path, '/', 'parsed'];
                    filename = [file_name, '.mat'];
                    matfile = fullfile(parsed_path, filename);
                    save(matfile, '-v7.3', 'board_band_map', 'board_adda_map', 'board_dig_in_data',  ...
                            't_amplifier', 'sample_rate');
                end
        end
    else
                warning('No files to be parsed in the directory.');
    end           
    fprintf('Finished parsing for %s. It took %s s\n', ...
        animal_name, num2str(toc(parse_start)));
end