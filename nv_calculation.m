function [nv_calc_path, region_channels, event_strings] = nv_calculation(psth_path, animal_name, pre_time, post_time, bin_size, span, epsilon, norm_var_scaling)
    % nv = normalized variance, bfr = background firing rate

    if pre_time <= 0.050
        error('Pre time can not be set to 0 for normalized variance analysis. Recreate the PSTH format with a different pre time.');
    end

    psth_mat_path = [psth_path, '/*.mat'];
    psth_files = dir(psth_mat_path);

    % rf = receptive field
    nv_calc_path = [psth_path, '/normalized_variance_analysis'];
    if ~exist(nv_calc_path, 'dir')
        mkdir(psth_path, 'normalized_variance_analysis');
    end

    % Deletes the failed directory if it already exists
    failed_path = [psth_path, '/failed'];
    if exist(failed_path, 'dir') == 7
        delete([failed_path, '/*']);
        rmdir(failed_path);
    end

    pre_time_bins = (length([-abs(pre_time): bin_size: 0])) - 1;
    post_time_bins = (length([0:bin_size:post_time])) - 1;

    for file = 1:length(psth_files)
        failed_rf = {};
        current_file = [psth_path, '/', psth_files(file).name];
        [file_path, filename, file_extension] = fileparts(current_file);
        split_name = strsplit(filename, '.');
        current_day = split_name{6};
        fprintf('Normalized variance calculation for %s on %s\n', animal_name, current_day);

        load(current_file);

        %% Preallocate nv struct with the neurons separated into their respective regions
        nv_analysis = struct;
        for region = 1:length(unique_regions)
            region_name = unique_regions{region};
            region_neurons = labeled_neurons.(region_name)(:, 1);
            for neuron = 1:length(region_neurons)
                neuron_name = region_neurons{neuron};
                nv_analysis.(region_name).([neuron_name, '_background_rate']) = [];
            end
            nv_analysis.(region_name).pop = [];
        end

        all_events = event_struct.all_events(:,2);
        event_end_indeces = [];
        for event = 1:length(all_events)
            event_end_indeces = [event_end_indeces, length(all_events{event})];
        end
        event_end_indeces = cumsum(event_end_indeces);
        % Relative response is trials x (neurons * bins)
        relative_response = event_struct.relative_response;
        [trials, unit_bins] = size(relative_response);

        %% Separates out the pre time window for each neuron from the relative response matrix
        last_trial_index = 1;
        event = 1;
        while event <= length(event_end_indeces)
            % Starts at the end of the pre time window and grabs the number of pre time bins before it to help prevent seg faults
            pre_index = pre_time_bins;
            % neuron is used as an index for the neuron map to get the neuron name for the given index
            neuron = 1;
            
            %% Isolates the current neuron's pre time window for current trial and calculates background firing rate
            while pre_index < unit_bins
                neuron_name = neuron_map{neuron};              
                %% Find the region the current neuron belongs to
                for region = 1:length(unique_regions)
                    region_name = unique_regions{region};
                    region_neurons = labeled_neurons.(region_name)(:, 1);
                    if any(strcmpi(region_neurons, neuron_name))
                        break;
                    end
                end
                % TODO pull out the pretime window, calculate background rate, and store in struct per neuron
                current_pre = relative_response(last_trial_index:event_end_indeces(event), (pre_index - pre_time_bins + 1 ):pre_index);
                % Calculate background rate
                background_rate = sum(current_pre, 2) / (pre_time * 1000);
                nv_analysis.(region_name).([neuron_name, '_background_rate']) = [nv_analysis.(region_name).([neuron_name, '_background_rate']); event_strings{event}, {background_rate}];

                %% Update indeces
                pre_index = pre_index + post_time_bins + pre_time_bins;
                neuron = neuron + 1;
            end

            %% Resets the index for the next trial
            pre_index = pre_time_bins;
            last_trial_index = event_end_indeces(event) + 1;
            event = event + 1;
        end

        %% Calculate nv for each event for each neuron
        % nv = c * (epsilon + var(event bfr))/ (c * epsilon + mean(event bfr))
        for region = 1:length(unique_regions)
            pop_norm_var = [];
            region_name = unique_regions{region};
            region_fields = fieldnames(nv_analysis.(region_name));
            for field = 1:length(region_fields)
                field_name = region_fields{field};
                % disp(field_name);
                % Grabs bfr for given neuron
                if contains(field_name, '_background_rate')
                    split_field = strsplit(field_name, '_');
                    neuron_name = split_field{1};
                    event_bfrs = getfield(nv_analysis.(region_name), region_fields{field});
                    event_norm_vars = [];
                    for event = 1:length(all_events)
                        current_event = event_strings{event};
                        current_bfr = event_bfrs{event, 2};
                        avg_bfr = mean(current_bfr);
                        bfr_var = var(current_bfr);
                        norm_var = norm_var_scaling * (epsilon + bfr_var)/(norm_var_scaling * epsilon + avg_bfr);
                        event_norm_vars= [event_norm_vars; event_strings{event}, {norm_var}];
                    end
                    nv_analysis.(region_name).([neuron_name, '_norm_var']) = event_norm_vars;
                    pop_norm_var = [pop_norm_var; event_norm_vars(:, end)'];
                end
            end
            nv_analysis.(region_name).pop = pop_norm_var;
        end

        %% Save analysis results
        nv_filename = strrep(filename, 'PSTH', 'NV');
        nv_filename = strrep(nv_filename, 'format', 'analysis');
        matfile = fullfile(nv_calc_path, [nv_filename, '.mat']);
        save(matfile, 'nv_analysis', 'unique_regions', 'event_strings', 'labeled_neurons', 'region_channels');
    end

end