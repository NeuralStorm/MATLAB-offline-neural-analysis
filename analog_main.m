function [] = analog_main()
    original_path = uigetdir(pwd);
    start_time = tic;
    animal_list = dir(original_path);
    animal_names = {animal_list([animal_list.isdir] == 1 & ~contains({animal_list.name}, '.')).name};
    for animal = 1:length(animal_names)
        animal_name = animal_names{animal};
        animal_path = [original_path, '/', animal_name];
        config = import_config(animal_path, 'sep');
        export_params(animal_path, 'main', config);
        % Skips animals we want to ignore
        if config.ignore_animal
            continue;
        else
            %% Checks to see if parsed directory exists
            parsed_path = [animal_path, '/', 'parsed'];
            if ~exist(parsed_path, 'dir')
                error('Parsed directory does not exist. Please run the Parser main to parse files');
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%             Filtering            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.save_filtered
                filter_path = batch_filter(animal_path, parsed_path, config);
            else
                filter_path = [parsed_path, '/filtered'];
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%            Sep_slicing           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.sep_slicing
                slice_path = batch_sep_slice(animal_path, parsed_path, filter_path, config);
            else
                slice_path = [parsed_path, '/sep'];
            end

            if config.update_sep_trials
                update_sep(slice_path, config.ignore_sessions, config.trial_range);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Sep Analysis           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if config.sep_analysis
                do_sep_analysis(animal_name, slice_path, config);
            end
        end
    end
    toc(start_time);
end