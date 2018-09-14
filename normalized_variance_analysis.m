function [] = normalized_variance_analysis(rf_path, animal_name, wanted_events, unique_regions)
    % nv = normalized variance
    %% Grab receptive field files from receptive field folder
    %! The ttest2 for indirect and direct (left and right) is hard coded -- dont think this can be avoided :(
    %! When we move over to python and data is formatted in a JSON file this can probably be avoided though :)
    rf_mat_path = [rf_path, '/*.mat'];
    rf_files = dir(rf_mat_path);

    nv_path = [rf_path, '/nv_results'];
    if ~exist(nv_path, 'dir')
        mkdir(rf_path, 'nv_results');
     end

    % Deletes the failed directory if it already exists
    failed_path = [rf_path, '/norm_var_failed'];
    if exist(failed_path, 'dir') == 7
        delete([failed_path, '/*']);
        rmdir(failed_path);
    end
    %TODO get all nv from all days to be able to access and do pair t-test, etc
    days = [];
    %% Dynamically allocates the fields
    for region = 1:length(unique_regions)
        current_region = unique_regions{region};
        all_norm_var.(current_region).norm_var = [];
    end
    % all_normalized_variance = [];
    for file = 1:length(rf_files)
        % REC.FIELD.PRAC.03.ClosedLoop.Day1.101515.mat
        failed_nv = {};
        current_file = [rf_path, '/', rf_files(file).name];
        [file_path, filename, file_extension] = fileparts(current_file);
        split_filename = strsplit(filename, '.');
        current_day = split_filename{6};
        day_num = regexp(current_day,'\d*','Match');
        day_num = str2num(day_num{1});
        days = [days; day_num];
        fprintf('Normalized variance analysis for %s on %s\n', animal_name, current_day);
        
        load(current_file);
        region_names = fieldnames(normalized_variance);

        %% Gathers all the normalized variance data across all days
        for region = 1:length(region_names)
            current_region = region_names{region};
            % struct_names = fieldnames(normalized_variance.(current_region));
            norm_var = [];
            for event = 1:length(wanted_events)
                current_event = event_strings{event};   
                current_norm_var = getfield(normalized_variance.(current_region), [current_event, '_norm_variance']);
                % disp(current_norm_var);
                norm_var = [norm_var, current_norm_var];
                all_norm_var.([current_event, '_left_early_late_results']) = [];
                all_norm_var.([current_event, '_right_early_late_results']) = [];
                all_norm_var.([current_event, '_early_left_right_results']) = [];
                all_norm_var.([current_event, '_late_left_right_results']) = [];
                all_norm_var.([current_event, '_left_early_late_change']) = [];
                all_norm_var.([current_event, '_right_early_late_change']) = [];
            end
            all_norm_var.(current_region).norm_var = [all_norm_var.(current_region).norm_var; day_num, norm_var];
            % all_normalized_variance = [all_normalized_variance; norm_var];
            all_norm_var.(current_region).norm_var = sortrows(all_norm_var.(current_region).norm_var);
        end
    end

    left = getfield(all_norm_var.Left, 'norm_var');
    right = getfield(all_norm_var.Right, 'norm_var');
    left_events = left(:, 2:end);
    right_events = right(:, 2:end);

    
    early_left_events = [];
    early_right_events = [];
    late_left_events = [];
    late_right_events = [];
    for days = 1:length(left(:,1))
        if (left(days, 1) >= 1) && (left(days, 1) <= 5)
            early_left_events = [early_left_events; left_events(days, :)];
            early_right_events = [early_right_events; right_events(days, :)];
        elseif left(days, 1) >= 21
            late_left_events = [late_left_events; left_events(days, :)];
            late_right_events = [late_right_events; right_events(days, :)];
        end
    end
    
    %% Goes through all events and does the respective ttests
    % This didnt need to be in a for loop but for clarity of variables
    % I put it in a for loop so that event strings could be appended to the data
    for event = 1:length(wanted_events)
        current_event = event_strings{event};
        disp(early_left_events(:, event));
        all_norm_var.([current_event, '_left_early_late_results']) = [all_norm_var.([current_event, '_left_early_late_results']); ttest(early_left_events(:, event), late_left_events(:, event))];
        all_norm_var.([current_event, '_right_early_late_results']) = [all_norm_var.([current_event, '_right_early_late_results']); ttest(early_right_events(:, event), late_right_events(:, event))];
        all_norm_var.([current_event, '_early_left_right_results']) = [all_norm_var.([current_event, '_early_left_right_results']); ttest2(early_left_events(:, event), early_right_events(:, event))];
        all_norm_var.([current_event, '_late_left_right_results']) = [all_norm_var.([current_event, '_late_left_right_results']); ttest2(late_left_events(:, event), late_right_events(:, event))];
        left_early_avg = mean(early_left_events(:, event));
        right_early_avg = mean(early_right_events(:, event));
        left_late_avg = mean(late_left_events(:, event));
        right_late_avg = mean(late_right_events(:, event));
        all_norm_var.([current_event, '_left_early_late_change']) = left_early_avg - left_late_avg;
        all_norm_var.([current_event, '_right_early_late_change']) = right_early_avg - right_late_avg;
    end

    matfile = fullfile(nv_path, 'norm_var_results.mat');
    save(matfile, 'all_norm_var');
end