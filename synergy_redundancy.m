function [] = synergy_redundancy(classified_path, animal_name)
    % Grabs all the unit information files
    unit_path = [classified_path, '/unit'];
    unit_mat_path = strcat(unit_path, '/*.mat');
    unit_files = dir(unit_mat_path);
    % grab all of the population information files
    pop_path = [classified_path, '/population'];
    pop_mat_path = strcat(pop_path, '/*.mat');
    pop_files = dir(pop_mat_path);
    for pop = 1:length(pop_files)
        %% Get the file for the same days for both population and unit
        % Since all files follow same convention throughout processing, this ensures that same day is loaded
        pop_file = [pop_path, '/', pop_files(pop).name];
        unit_name = replace(pop_files(pop).name, 'POP', 'UNIT');
        unit_file = [unit_path, '/', unit_name];

        %% Grab the sum of the corrected unit info
        load(unit_file);

        classified_struct_names = fieldnames(classified_struct);
        region_names = fieldnames(labeled_neurons);
        %% Iterates through all the regions
        for region = 1:length(region_names)
            region_struct.([region_names{region}, '_sum']) = 0;
            %% Iterates through all the channels within a given region
            for neuron = 1:length(labeled_neurons.(region_names{region}))
                unit_info = getfield(classified_struct, [labeled_neurons.(region_names{region}){neuron}, '_information']);
                % Adds up the total unit information when info is above 0
                if unit_info > 0
                    region_struct.([region_names{region}, '_sum']) = region_struct.([region_names{region}, '_sum']) + unit_info;
                end
            end
        end

        %% Grab population information
        load(pop_file);
        for region = 1:length(region_names)
            corrected_region_info = classified_struct.([region_names{region}, '_corrected_info']);
            region_syn_red = corrected_region_info - region_struct.([region_names{region}, '_sum']);
            classified_struct.([region_names{region}, '_syn_red']) = region_syn_red;
            classified_struct.([region_names{region}, '_syn_red_bool']) = region_syn_red > 0;
        end
        save(pop_file, 'classified_struct', 'all_events', 'labeled_neurons');
    end
end