function [] = parser_main()

    %% Get directory with all animals and their data
    original_path = uigetdir(pwd);
    start_time = tic;
    animal_list = dir(original_path);
    animal_names = {animal_list([animal_list.isdir] == 1 ...
                    & ~contains({animal_list.name}, '.')).name};

    for animal = 1:length(animal_names)
        animal_name = animal_names{animal};
        animal_path = fullfile(...
                                animal_list(strcmpi(animal_names{animal}, ...
                                {animal_list.name})).folder, animal_name);
        config = import_config(animal_path, 'parser');
        export_params(animal_path, 'parser', config);
        % Skips animals we want to ignore
        if config.ignore_animal
            continue;
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%           Parser           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %! Might remove the file handling in the future
            batch_parser(animal_path, animal_name, config);
        end
    end
    toc(start_time);
end