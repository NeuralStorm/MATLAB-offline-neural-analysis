function sep_slicing_path = sep_slicing(animal_name, filtered_path, start_window, end_window)
    sep_slicing_start = tic;
    fprintf('Applying sep slicing for %s \n', animal_name);
        [filtered_files, sep_slicing_path, failed_path] = create_dir...
            (filtered_path, 'sliced', '.mat');
        for file_index = 1:length(filtered_files)
            try
                %% Load file contents
                file = [filtered_path, '/', filtered_files(file_index).name];
                [~, filename, ~] = fileparts(file);
                load(file, 'bandpass_filtered_map', 'board_dig_in_data', 'sample_rate');
                %% Check filtered variables to make sure they are not empty
                empty_vars = check_variables(file, bandpass_filtered_map, board_dig_in_data, sample_rate);
                if empty_vars
                    continue
                end
                %% Apply sep slicing
                sep_window = [-abs(start_window), end_window];
                sep_l2h_map = make_sep_map(bandpass_filtered_map, board_dig_in_data, ...
                    sample_rate, sep_window);

                %% Saving outputs
                matfile = fullfile(sep_slicing_path, ['sliced_', filename, '.mat']);
                %% Check output to make sure there are no issues with the output
                empty_vars = check_variables(matfile, sep_l2h_map);
                if empty_vars
                    continue
                end
                %% Save file if all variables are not empty
                     save(matfile, 'sep_l2h_map', 'sep_window');
            catch ME
                handle_ME(ME, failed_path, filename);
            end
        end         
        fprintf('Finished sep slicing for %s. It took %s s\n', ...
            animal_name, num2str(toc(sep_slicing_start)));
end