function [nv_path] = normalized_variance_analysis(nv_calc_path, animal_name, wanted_events, region_channels, event_strings)
    % nv = normalized variance
    %% Grab receptive field files from receptive field folder

    nv_calc_mat_path = [nv_calc_path, '/*.mat'];
    nv_calc_files = dir(nv_calc_mat_path);

    nv_path = [nv_calc_path, '/nv_results'];
    if ~exist(nv_path, 'dir')
        mkdir(nv_path, 'nv_results');
    end

    % Deletes the failed directory if it already exists
    failed_path = [nv_path, '/norm_var_failed'];
    if exist(failed_path, 'dir') == 7
        delete([failed_path, '/*']);
        rmdir(failed_path);
    end

    days = [];
    %% Allocate struct fields for the actual NV analysis
    unique_regions = fieldnames(region_channels);
    for region = 1:length(unique_regions)
        region_name = unique_regions{region};
        for neuron = 1:length(region_channels.(region_name))
            neuron_name = region_channels.(region_name){neuron};
            days_norm_var.(region_name).([neuron_name, '_norm_var']) = [];
            days_norm_var.(region_name).early_norm_var = [];
            days_norm_var.(region_name).late_norm_var = [];
            days_norm_var.(region_name).best_norm_var = [];
            days_norm_var.(region_name).first_norm_var = [];
            days_norm_var.(region_name).early_pop = [];
            days_norm_var.(region_name).late_pop = [];
            days_norm_var.(region_name).overall_pop = [];
        end
    end

    %% Iterate through all the files and concact normalized variance across days for each neuron for each event
    for file = 1:length(nv_calc_files)
        failed_nv = {};
        current_file = [nv_calc_path, '/', nv_calc_files(file).name];
        [file_path, filename, file_extension] = fileparts(current_file);
        split_filename = strsplit(filename, '.');
        current_day = split_filename{6};
        day_num = regexp(current_day,'\d*','Match');
        day_num = str2num(day_num{1});
        days = [days; day_num];
        fprintf('Normalized variance analysis for %s on %s\n', animal_name, current_day);
        
        load(current_file);
        region_names = fieldnames(nv_analysis);

        %% Gathers all the normalized variance data across all days
        for region = 1:length(region_names)
            region_name = region_names{region};
            region_fields = fieldnames(nv_analysis.(region_name));
            for field = 1:length(region_fields)
                field_name = region_fields{field};
                if contains(field_name, 'pop')
                    pop_norm_vars = getfield(nv_analysis.(region_name), region_fields{field});
                    pop_avg_norm_var = [];

                    for event = 1:length(pop_norm_vars(1, :))
                        pop_event_avg = mean([pop_norm_vars{:, event}]);
                        pop_avg_norm_var = [pop_avg_norm_var, pop_event_avg];
                    end
                    if day_num >= 1 && day_num <= 5
                        days_norm_var.(region_name).early_norm_var = [days_norm_var.(region_name).early_norm_var;  pop_avg_norm_var];
                        days_norm_var.(region_name).early_pop = [days_norm_var.(region_name).early_pop; pop_norm_vars];
                    elseif day_num >= 21 && day_num <= 25
                        days_norm_var.(region_name).late_norm_var = [days_norm_var.(region_name).late_norm_var;  pop_avg_norm_var];
                        days_norm_var.(region_name).late_pop = [days_norm_var.(region_name).late_pop; pop_norm_vars];
                    end

                    days_norm_var.(region_name).all_days_avg_norm_var = [days_norm_var.(region_name).overall_pop; [day_num, pop_avg_norm_var]];

                    %% Best day NV separation
                    if day_num == 1
                        days_norm_var.(region_name).first_norm_var = [days_norm_var.(region_name).first_norm_var; pop_avg_norm_var];
                    elseif strcmpi(animal_name, 'lc02') && day_num == 22
                        days_norm_var.(region_name).best_norm_var = pop_avg_norm_var;
                    elseif strcmpi(animal_name, 'prac03') && day_num == 25
                        days_norm_var.(region_name).best_norm_var = pop_avg_norm_var;
                    elseif strcmpi(animal_name, 'ravi19') && day_num == 22
                        days_norm_var.(region_name).best_norm_var = pop_avg_norm_var;
                    elseif strcmpi(animal_name, 'ravi20') && day_num == 21
                        days_norm_var.(region_name).best_norm_var = pop_avg_norm_var;
                    elseif strcmpi(animal_name, 'tnc06') && day_num == 22
                        days_norm_var.(region_name).best_norm_var = pop_avg_norm_var;
                    elseif strcmpi(animal_name, 'tnc12') && day_num == 23
                        days_norm_var.(region_name).best_norm_var = pop_avg_norm_var;
                    elseif strcmpi(animal_name, 'tnc16') && day_num == 23
                        days_norm_var.(region_name).best_norm_var = pop_avg_norm_var;
                    elseif strcmpi(animal_name, 'tnc25') && day_num == 23
                        days_norm_var.(region_name).best_norm_var = pop_avg_norm_var;
                    end
                elseif contains(field_name, '_norm_var')
                    split_field = strsplit(field_name, '_');
                    neuron_name = split_field{1};
                    event_norm_vars = getfield(nv_analysis.(region_name), region_fields{field});
                    norm_var = event_norm_vars(:, end)';
                    days_norm_var.(region_name).([neuron_name, '_norm_var']) = [days_norm_var.(region_name).([neuron_name, '_norm_var']); [day_num, norm_var]];
                end
            end
            %% Sort days
            days_norm_var.(region_name).overall_pop = sortrows(days_norm_var.(region_name).all_days_avg_norm_var, 1);
        end
    end

    %% Remove empty fields
    for region = 1:length(region_names)
        region_name = region_names{region};
        region_neurons = fieldnames(days_norm_var.(region_name));
        empty = cellfun(@(x) isempty(days_norm_var.(region_name).(x)), region_neurons);
        days_norm_var.(region_name) = rmfield(days_norm_var.(region_name), region_neurons(empty));
    end

    matfile = fullfile(nv_path, [animal_name '_norm_var_results.mat']);
    save(matfile, 'nv_analysis', 'unique_regions', 'days_norm_var', 'event_strings');
end