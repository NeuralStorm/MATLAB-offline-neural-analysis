function [] = sep_main()
            %% Get directory with all animals and their data
    original_path = uigetdir(pwd);
    start_time = tic;
    animal_list = dir(original_path);
    animal_names = {animal_list([animal_list.isdir] == 1 & ~contains({animal_list.name}, '.')).name};
    for animal = 1:length(animal_names)
        animal_name = animal_names{animal};
        animal_path = fullfile(...
            animal_list(strcmpi(animal_names{animal}, {animal_list.name})).folder, animal_name);
        config = import_config(animal_path);

        %export_params(animal_path, 'main', config);
        % Skips animals we want to ignore
        if config.ignore_animal
            continue;
        else
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Parser           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if config.is_parse_files
                %% Parse files
                parse_start = tic;
                % Creates a list of all the files in the given directory ending with
                file_type = [animal_path, '/*', '*'];
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
                                save(matfile, 'board_band_map', 'board_adda_map', 'board_dig_in_data',  ...
                                        't_amplifier', 'sample_rate');
                            end
                    end
                else
                            warning('No files to be parsed in the directory.');
                end           
                fprintf('Finished parsing for %s. It took %s s\n', ...
                    animal_name, num2str(toc(parse_start)));
            else
                parsed_path = [animal_path, '/parsed'];
            end
            
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Filter           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                    
            if config.is_notch_filter
                %% Notch filter
                filtered_path = do_notch_filter(animal_name, ...
                    parsed_path, config.notch_filter_frequency, config.notch_filter_bandwidth, config.use_notch_bandstop);
                %% Lowpass filter with notch
                if config.is_lowpass_filter
                    do_lowpass_filter(animal_name, parsed_path, filtered_path, config.is_notch_filter, ...
                        config.lowpass_filter_order, config.lowpass_filter_fc);
                end
                %% Highpass filter with notch
                if config.is_highpass_filter
                    do_highpass_filter(animal_name, parsed_path, filtered_path, config.is_notch_filter, ...
                        config.is_lowpass_filter, config.highpass_filter_order, config.highpass_filter_fc);
                end               
            elseif (config.is_lowpass_filter || config.is_highpass_filter)
            % If is_notch_filter is ture, pass the filtered data into lowpass
            % or highpass filter. If is_notch_filter is false, pass the raw
            % data into lowpass or highpass filter. 
                %% Lowpass filter without notch 
                if config.is_lowpass_filter                           
                    filtered_path = do_lowpass_filter(animal_name, parsed_path, '', config.is_notch_filter, ...
                        config.lowpass_filter_order, config.lowpass_filter_fc);               
                end
            
                %% Highpass filter without notch       
                if config.is_highpass_filter
                    filtered_path = do_highpass_filter(animal_name, parsed_path, '', config.is_notch_filter, ...
                        config.is_lowpass_filter, config.highpass_filter_order, config.highpass_filter_fc);
                end
            else           
                filtered_path = [parsed_path, '/filtered'];
            end
            
            
            
        end
        end
    toc(start_time);
    end
    

    