function [] = synergy_redundancy(classified_path, animal_name)
    % Grabs all the unit information files
    unit_path = [classified_path, '/unit'];
    unit_mat_path = strcat(unit_path, '/*.mat');
    unit_files = dir(unit_mat_path);
    % grab all of the population information files
    pop_path = [classified_path, '/population'];
    pop_mat_path = strcat(pop_path, '/*.mat');
    pop_files = dir(pop_mat_path);
    % TODO add assert or try statement to return early if length of pop and unit
    % TODO do not match (ie: animal doesnt have same number of days between two files)
    for pop = 1:length(pop_files)
        %% Get the file for the same days for both population and unit
        % Since all files follow same convention throughout processing, this ensures that same day is loaded
        pop_file = [pop_path, '/', pop_files(pop).name];
        unit_name = replace(pop_files(pop).name, 'POP', 'UNIT');
        unit_file = [unit_path, '/', unit_name];

        %% Grab the sum of the corrected unit info
        load(unit_file);
        struct_names = fieldnames(classified_struct);
        unit_corrected_sum = 0;
        for i = 1: length(struct_names)
            if contains(struct_names{i}, '_information')
                unit_info = getfield(classified_struct, struct_names{i});
                if unit_info > 0
                    unit_corrected_sum = unit_corrected_sum + unit_info;
                else
                    continue;
                end
            end
        end

        %% Grab the population information
        load(pop_file);
        corrected_pop_info = classified_struct.population_corrected_info;
        syn_red = corrected_pop_info - unit_corrected_sum;
        classified_struct.syn_red_value = syn_red;
        % TODO what happens when syn red is 0?
        classified_struct.syn_red_bool = syn_red > 0;
        save(pop_file, 'classified_struct', 'neuron_map', 'all_events', 'total_neurons');
    end
end