function [euclidian_path] = unit_euclidian_psth(original_path, psth_path, animal_name, pre_time, post_time, total_bins, first_iteration)
    %% Animal categories
    learning = ['PRAC03', 'TNC16', 'RAVI19', 'RAVI20', 'RAVI019', 'RAVI020'];
    non_learning = ['LC02', 'TNC06', 'TNC12', 'TNC25'];
    control = ['TNC01', 'TNC03', 'TNC04', 'TNC14'];
    right_direct = ['RAVI19', 'RAVI019', 'PRAC03', 'LC02', 'TNC12'];
    left_direct = ['RAVI20', 'RAVI020', 'TNC16', 'TNC25', 'TNC06'];
    % Grabs all the psth formatted files
    psth_mat_path = strcat(psth_path, '/*.mat');
    psth_files = dir(psth_mat_path);
    
    euclidian_path = fullfile(original_path, 'euclidian.csv');
    if ~exist(euclidian_path, 'file') && first_iteration
        euclidian_table = table([], [], [], [], [], [], [], [], [], [], [], [], 'VariableNames', {'animal', 'day', ...
            'day_type', 'animal_group', 'region', 'region_type', 'fast_right_left', 'slow_right_left', 'right_fast_slow',  ...
            'left_fast_slow', 'right_fast_left_slow', 'right_slow_left_fast'});
    elseif exist(euclidian_path, 'file') && first_iteration
        delete(euclidian_path);
        euclidian_table = table([], [], [], [], [], [], [], [], [], [], [], [], 'VariableNames', {'animal', 'day', ...
            'day_type', 'animal_group', 'region', 'region_type', 'fast_right_left', 'slow_right_left', 'right_fast_slow',  ...
            'left_fast_slow', 'right_fast_left_slow', 'right_slow_left_fast'});
    else
        euclidian_table = readtable(euclidian_path);
    end

    if contains(learning, animal_name)
        animal_type = 'learning';
    elseif contains(non_learning, animal_name)
        animal_type = 'non_learning';
    elseif contains(control, animal_name)
        animal_type = 'control';
    else
        error([animal_name, ' does not fall into learning, non learning, or control groups']);
    end

    %% Initialize arrays for graphs

    right_late = [];
    left_late = [];
    euclidian_data = [];

    for file = 1:length(psth_files)
        current_file = [psth_path, '/', psth_files(file).name];
        [file_path, filename, file_extension] = fileparts(current_file);
        split_filename = strsplit(filename, '.');
        current_day = split_filename{6};
        day_num = regexp(current_day,'\d*','Match');
        day_num = str2num(day_num{1});
        current_animal = [split_filename{3}, split_filename{4}];
        %% Skips all days except for first and best day for each animal
        if ~(day_num == 0 || ((strcmpi(current_animal, 'LC02') || strcmpi(current_animal, 'TNC06') || ...
            strcmpi(current_animal, 'TNC12') || strcmpi(current_animal, 'TNC25') || strcmpi(current_animal, 'TNC14')) ...
            & day_num == 20) || ((strcmpi(current_animal, 'TNC14') || strcmpi(current_animal, 'RAVI020')) & day_num == 21) || ((strcmpi(current_animal, 'RAVI019') || ... 
            strcmpi(current_animal, 'TNC01') || strcmpi(current_animal, 'TNC03') || ...
            strcmpi(current_animal, 'TNC04')) & day_num == 22) || ((strcmpi(current_animal, 'TNC04') || ...
            strcmpi(current_animal, 'TNC16')) & day_num == 23) || (strcmpi(current_animal, 'TNC01') & day_num == 24) || ...
            (strcmpi(current_animal, 'TNC03') & day_num == 25) || (strcmpi(current_animal, 'PRAC03') & day_num == 16))
                continue
        end

        %% create labels for csv
        if day_num == 0
            day_type = 'early';
        else
            day_type = 'late';
        end
        
        load(current_file);
        unique_regions = fieldnames(labeled_data);
        for region = 1:length(unique_regions)
            region_name = unique_regions{region};
            total_region_neurons = length(labeled_data.(region_name)(:,1));
            %% Label region as direct or indirect
            if (contains(right_direct, current_animal) && strcmpi('Right', region_name)) || (contains(left_direct, current_animal) && strcmpi('Left', region_name))
                region_type = 'Direct';
            else
                region_type = 'Indirect';
            end

            %% From first v best graphs
            if contains(control, current_animal) & ((contains(region_name, 'Right') & (day_num == 22 || ...
                day_num == 20)) || (contains(region_name, 'Left') & (day_num == 21 || day_num == 23 ||...
                day_num == 24 || day_num == 25)))
                    continue
            end
            right_fast = psth_struct.(region_name).event_1.psth;
            right_slow = psth_struct.(region_name).event_3.psth;
            left_fast = psth_struct.(region_name).event_4.psth;
            left_slow = psth_struct.(region_name).event_6.psth;
            fast_right_left = [];
            slow_right_left = [];
            right_fast_slow = [];
            left_fast_slow = [];
            right_fast_left_slow = [];
            right_slow_left_fast = [];

            for unit = 1:total_region_neurons
                end_index = total_bins * unit;
                start_index = end_index - total_bins + 1;
                fast_right_left = [fast_right_left, sum((right_fast(start_index:end_index) - left_fast(start_index:end_index)).^2)];
                slow_right_left = [slow_right_left, sum((right_slow(start_index:end_index) - left_slow(start_index:end_index)).^2)];
                right_fast_slow = [right_fast_slow, sum((right_fast(start_index:end_index) - right_slow(start_index:end_index)).^2)];
                left_fast_slow = [left_fast_slow, sum((left_fast(start_index:end_index) - left_slow(start_index:end_index)).^2)];
                right_fast_left_slow = [right_fast_left_slow, sum((right_fast(start_index:end_index) - left_slow(start_index:end_index)).^2)];
                right_slow_left_fast = [right_slow_left_fast, sum((right_slow(start_index:end_index) - left_fast(start_index:end_index)).^2)];
            end

            fast_right_left = mean(fast_right_left.^.5);
            slow_right_left = mean(slow_right_left.^.5);
            right_fast_slow = mean(right_fast_slow.^.5);
            left_fast_slow = mean(left_fast_slow.^.5);
            right_fast_left_slow = mean(right_fast_left_slow.^.5);
            right_slow_left_fast = mean(right_slow_left_fast.^.5);

            if day_num < 8
                euclidian_data = [euclidian_data; {{animal_name}, day_num, {'early'}, {animal_type}, {region_name}, {region_type}, ...
                    fast_right_left, slow_right_left, right_fast_slow, left_fast_slow, right_fast_left_slow, right_slow_left_fast}];
            else
                if strcmpi(region_name, 'right')
                    right_late = [right_late; fast_right_left, slow_right_left, right_fast_slow, left_fast_slow, right_fast_left_slow, right_slow_left_fast];
                elseif strcmpi(region_name, 'left')
                    left_late = [left_late; fast_right_left, slow_right_left, right_fast_slow, left_fast_slow, right_slow_left_fast, right_slow_left_fast];
                end
            end
        end
    end

    if contains(right_direct, current_animal)
        euclidian_data = [euclidian_data; {{animal_name}, 25, {'late'}, {animal_type}, {'Left'}, {'Indirect'}, left_late(1), ...
            left_late(2), left_late(3), left_late(4), left_late(5), left_late(6)}];
        euclidian_data = [euclidian_data; {{animal_name}, 25, {'late'}, {animal_type}, {'Right'}, {'Direct'}, right_late(1), ...
            right_late(2), right_late(3), right_late(4), right_late(5), right_late(6)}];
    elseif contains(left_direct, current_animal)
        euclidian_data = [euclidian_data; {{animal_name}, 25, {'late'}, {animal_type}, {'Left'}, {'Direct'}, left_late(1), ...
            left_late(2), left_late(3), left_late(4), left_late(5), left_late(6)}];
        euclidian_data = [euclidian_data; {{animal_name}, 25, {'late'}, {animal_type}, {'Right'}, {'Indirect'}, right_late(1), ...
            right_late(2), right_late(3), right_late(4), right_late(5), right_late(6)}];
    else
        euclidian_data = [euclidian_data; {{animal_name}, day_num, {'late'}, {animal_type}, {'Left'}, {'Indirect'}, left_late(1), ...
            left_late(2), left_late(3), left_late(4), left_late(5), left_late(6)}];
        euclidian_data = [euclidian_data; {{animal_name}, day_num, {'late'}, {animal_type}, {'Right'}, {'Indirect'}, right_late(1), ...
            right_late(2), right_late(3), right_late(4), right_late(5), right_late(6)}];
    end
    new_euclidian_table = cell2table(euclidian_data, 'VariableNames', {'animal', 'day', ...
        'day_type', 'animal_group', 'region', 'region_type', 'fast_right_left', 'slow_right_left', 'right_fast_slow',  ...
        'left_fast_slow', 'right_fast_left_slow', 'right_slow_left_fast'});
    euclidian_table = [euclidian_table; new_euclidian_table];
    writetable(euclidian_table, euclidian_path, 'Delimiter', ',');
end