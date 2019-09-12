function [] = sep_main()
    original_path = uigetdir(pwd);
    start_time = tic;
    animal_list = dir(original_path);
    animal_names = {animal_list([animal_list.isdir] == 1 & ~contains({animal_list.name}, '.')).name};
    for animal = 1:length(animal_names)
        animal_name = animal_names{animal};
        animal_path = [original_path, '/', animal_name];
        config = import_config(animal_path, 'sep');
        if isempty(config.trial_range)
            config.trial_range = [];
        else
            config.trial_range = str2num(config.trial_range);
        end

        export_params(animal_path, 'main', config);
        % Skips animals we want to ignore
        if config.ignore_animal
            continue;
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Parser           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if config.is_parse_files
                 parsed_path = sep_parser(animal_name, animal_path, config.ignore_sessions);
            else
                parsed_path = [animal_path, '/parsed'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%            Sep_slicing           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.is_sep_slicing
                slice_path = batch_sep_slice(animal_name, parsed_path, config);
            else
                slice_path = [parsed_path, '/sep'];
            end

            if config.update_sep_trials
                update_sep(slice_path, config.ignore_sessions, config.trial_range);
            end

             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%         Sep_analysis         %%
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.is_sep_analysis
                sep_analysis(animal_name, slice_path, config.baseline_start_window, ...
                    config.baseline_end_window, config.standard_deviation_coefficient, ...
                    config.early_start, config.early_end, config.late_start, ...
                    config.late_end, config.ignore_sessions);
            end
            
        end
    end
    toc(start_time);
end