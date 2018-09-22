function [nv_path] = normalized_variance_analysis(nv_calc_path, animal_name, wanted_events, region_channels, event_strings)
    % nv = normalized variance
    %% Grab receptive field files from receptive field folder
    %! The ttest2 for indirect and direct (left and right) is hard coded -- dont think this can be avoided :(
    %! When we move over to python and data is formatted in a JSON file this can probably be avoided though :)

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
            % for event = 1:length(wanted_events)
            %     current_event = event_strings{event};
            %     days_norm_var.(region_name).([neuron_name, '_', current_event, '_left_early_late_results']) = [];
            %     days_norm_var.(region_name).([neuron_name, '_', current_event, '_right_early_late_results']) = [];
            %     days_norm_var.(region_name).([neuron_name, '_', current_event, '_early_left_right_results']) = [];
            %     days_norm_var.(region_name).([neuron_name, '_', current_event, '_late_left_right_results']) = [];
            %     days_norm_var.(region_name).([neuron_name, '_', current_event, '_left_early_late_change']) = [];
            %     days_norm_var.(region_name).([neuron_name, '_', current_event, '_right_early_late_change']) = [];
            % end
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
                if contains(field_name, '_norm_var')
                    split_field = strsplit(field_name, '_');
                    neuron_name = split_field{1};
                    event_norm_vars = getfield(nv_analysis.(region_name), region_fields{field});
                    norm_var = event_norm_vars(:, end)';
                    days_norm_var.(region_name).([neuron_name, '_norm_var']) = [days_norm_var.(region_name).([neuron_name, '_norm_var']); [day_num, norm_var]];
                end
            end
        end
    end

    %% Early late neuron comparison

    % left = getfield(days_norm_var.Left, 'norm_var');
    % right = getfield(days_norm_var.Right, 'norm_var');
    % left_events = left(:, 2:end);
    % right_events = right(:, 2:end);

    
    % early_left_events = [];
    % early_right_events = [];
    % late_left_events = [];
    % late_right_events = [];
    % for days = 1:length(left(:,1))
    %     if (left(days, 1) >= 1) && (left(days, 1) <= 5)
    %         early_left_events = [early_left_events; left_events(days, :)];
    %         early_right_events = [early_right_events; right_events(days, :)];
    %     elseif left(days, 1) >= 21
    %         late_left_events = [late_left_events; left_events(days, :)];
    %         late_right_events = [late_right_events; right_events(days, :)];
    %     end
    % end
    
    % %% Goes through all events and does the respective ttests
    % % This didnt need to be in a for loop but for clarity of variables
    % % I put it in a for loop so that event strings could be appended to the data
    % for event = 1:length(wanted_events)
    %     current_event = event_strings{event};
    %     days_norm_var.([current_event, '_left_early_late_results']) = [days_norm_var.([current_event, '_left_early_late_results']); ttest(early_left_events(:, event), late_left_events(:, event))];
    %     days_norm_var.([current_event, '_right_early_late_results']) = [days_norm_var.([current_event, '_right_early_late_results']); ttest(early_right_events(:, event), late_right_events(:, event))];
    %     days_norm_var.([current_event, '_early_left_right_results']) = [days_norm_var.([current_event, '_early_left_right_results']); ttest2(early_left_events(:, event), early_right_events(:, event))];
    %     days_norm_var.([current_event, '_late_left_right_results']) = [days_norm_var.([current_event, '_late_left_right_results']); ttest2(late_left_events(:, event), late_right_events(:, event))];
    %     left_early_avg = mean(early_left_events(:, event));
    %     right_early_avg = mean(early_right_events(:, event));
    %     left_late_avg = mean(late_left_events(:, event));
    %     right_late_avg = mean(late_right_events(:, event));
    %     days_norm_var.([current_event, '_left_early_late_change']) = left_early_avg - left_late_avg;
    %     days_norm_var.([current_event, '_right_early_late_change']) = right_early_avg - right_late_avg;
    % end

    %% Remove empty fields
    for region = 1:length(region_names)
        region_name = region_names{region};
        region_neurons = fieldnames(days_norm_var.(region_name));
        empty = cellfun(@(x) isempty(days_norm_var.(region_name).(x)), region_neurons);
        days_norm_var.(region_name) = rmfield(days_norm_var.(region_name), region_neurons(empty));
    end

    matfile = fullfile(nv_path, [animal_name '_norm_var_results.mat']);
    save(matfile, 'nv_analysis', 'unique_regions', 'days_norm_var');
end