function [] = batch_parser(parsed_path, failed_path, animal_path, dir_name, config, label_table)
    fprintf('Parsing %s \n', dir_name);
    try
        %% Create list of files to parse excluding directories, configs, labels, and logs
        file_list = get_file_list(animal_path, '.*');
        file_list = file_list([file_list.isdir] == 0 ...
            & ~contains({file_list.name}, {'config.csv', 'labels.csv', 'log.csv', 'data.csv'}));
        file_list = update_file_list(file_list, failed_path, config.include_sessions);

        %% Find unique file extensions
        filenames = {file_list.name};
        unique_exts = [];
        for file_i = 1:length(filenames)
            curr_filename = filenames{file_i};
            [~, ~, file_ext] = fileparts(curr_filename);
            unique_exts = unique([unique_exts; {file_ext}]);
        end

        if isempty(unique_exts)
            error('No files to parse, please add files to parse to %s', dir_name)
        else
            for ext_i = 1:length(unique_exts)
                curr_ext = unique_exts{ext_i};
                ext_file_list = filenames(contains(filenames, curr_ext));
                switch curr_ext
                    case {'.plx', '.pl2'}
                        %% Handle parsing plx files
                        if contains(config.recording_type, 'spike', 'IgnoreCase', 1)
                            parsing_func = 'plx_spike_parser';
                        else
                            error('Continous parser for plexon needs to be implemented');
                        end
                    case '.rhs'
                        parsing_func = 'rh_parser';
                        config.rh = 'rhs';
                    case '.rhd'
                        parsing_func = 'rh_parser';
                        config.rh = 'rhd';
                    otherwise
                        error('Parser not implemented for %s. Please create your own parser.', ...
                            curr_ext);
                end
                parsing = str2func(parsing_func);
                %% Find files with unique extension
                for file_i = 1:length(ext_file_list)
                    %% Call appropriate parser
                    curr_filename = filenames{file_i};
                    raw_file = fullfile(animal_path, curr_filename);
                    parsing(parsed_path, failed_path, raw_file, config, label_table);
                end
            end
        end
    catch ME
        handle_ME(ME, failed_path, [dir_name, '_parsing.mat']);
    end

end