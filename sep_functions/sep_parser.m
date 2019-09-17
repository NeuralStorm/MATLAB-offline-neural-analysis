function parsed_path = sep_parser(animal_name, animal_path, config)
    %% Parse files
    parse_start = tic;
    [parsed_path, failed_path] = create_dir(animal_path, 'parsed');
    [file_list] = get_file_list(animal_path, '.rh*', config.ignore_sessions);
    export_params(parsed_path, 'parser', failed_path, config);
    
    % Data mapping for rhd files
    % Runs through all of the files in the selected directory
    if ~isempty(file_list)
        for file_index = 1:length(file_list)
            file = [animal_path, '/', file_list(file_index).name];
            [animal_path, file_name, ~] = fileparts(file);
            fprintf('Parsing for %s\n', file_name, '...');
            % Read data from the path and generate labels
            [board_band_map, board_adda_map, board_dig_in_data, t_amplifier, ...
                sample_rate] = board_band_parser(file);
            labels = sep_make_labels(animal_path, animal_name); 
            
            %Gets filename parameters and adds to labels
            file_name_params = split(file_name, '_'); 
            [exp_group{1:height(labels),1}] = deal(cell2mat(file_name_params(2)));
            [exp_cond{1:height(labels),1}] = deal(cell2mat(file_name_params(3)));
            [rec_session{1:height(labels),1}] = deal(cell2mat(file_name_params(4)));
            [date{1:height(labels),1}] = deal(cell2mat(file_name_params(5)));
            
            labels = addvars(labels, exp_group, exp_cond, rec_session); 
            
            
            
            % newStr = strrep(str,old,new)
            board_band_map(:, 1) = cellfun(@(x) strrep(x, '-', '_'), board_band_map(:, 1), 'UniformOutput',false);
            board_band_map = sep_assign_labels(board_band_map, labels);
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