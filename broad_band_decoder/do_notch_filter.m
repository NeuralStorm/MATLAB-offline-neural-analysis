function notch_filtered_path = do_notch_filter(animal_name, ...
    parsed_path, notch_filter_frequency, notch_filter_bandwidth, use_notch_bandstop)
    notch_filter_start = tic;
    fprintf('Applying notch filter for %s \n', animal_name);
    [parsed_files, notch_filtered_path, failed_path] = create_dir...
        (parsed_path, 'filtered', '.mat');
    for file_index = 1:length(parsed_files)
        try
            %% Load file contents
            file = [parsed_path, '/', parsed_files(file_index).name];
            [~, filename, ~] = fileparts(file);
            load(file, 'board_band_map', 'board_dig_in_data', 'sample_rate');
            %% Check parsed variables to make sure they are not empty
            empty_vars = check_variables(file, board_band_map, sample_rate);
            if empty_vars
                continue
            end
            %% Apply notch filter
            notch_filtered_map = notch_filter_for_boardband(board_band_map, ...
                notch_filter_frequency, notch_filter_bandwidth, sample_rate, use_notch_bandstop);

            %% Saving outputs
            matfile = fullfile(notch_filtered_path, ['filtered_', filename, '.mat']);
            %% Check output to make sure there are no issues with the output
            empty_vars = check_variables(matfile, notch_filtered_map);
            if empty_vars
                continue
            end
            %% Save file if all variables are not empty
                 save(matfile, 'notch_filtered_map', 'board_dig_in_data', 'sample_rate');
        catch ME
            handle_ME(ME, failed_path, filename);
        end
    end
    fprintf('Finished applying notch filter for %s. It took %s s\n', ...
    animal_name, num2str(toc(notch_filter_start)));
end