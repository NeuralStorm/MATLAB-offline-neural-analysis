function [classify_path] = crude_bootstrapper(original_path, first_iteration, psth_path, animal_name, boot_iterations, bin_size, pre_time, post_time, unit_classification)
    tic;
    % Grabs all the psth formatted files
    psth_mat_path = strcat(psth_path, '/*.mat');
    psth_files = dir(psth_mat_path);

    % Checks if a classify graph directory exists and if not it creates it
    classify_path = strcat(psth_path, '/classifier');
    if ~exist(classify_path, 'dir')
        mkdir(psth_path, 'classifier');
    end

    % Deletes the failed directory if it already exists
    failed_path = [classify_path, '/failed'];
    if exist(failed_path, 'dir') == 7
        delete([failed_path, '/*']);
        rmdir(failed_path);
    end

    %% Animal categories
    learning = ['PRAC03', 'TNC16', 'RAVI19', 'RAVI20', 'RAVI019', 'RAVI020'];
    non_learning = ['LC02', 'TNC06', 'TNC12', 'TNC25'];
    control = ['TNC01', 'TNC03', 'TNC04', 'TNC14'];
    right_direct = ['RAVI19', 'RAVI019', 'PRAC03', 'LC02', 'TNC12'];
    left_direct = ['RAVI20', 'RAVI020', 'TNC16', 'TNC25', 'TNC06'];

    if contains(learning, animal_name)
        animal_type = 'learning';
    elseif contains(non_learning, animal_name)
        animal_type = 'non_learning';
    elseif contains(control, animal_name)
        animal_type = 'control';
    else
        error([animal_name, ' does not fall into learning, non learning, or control groups']);
    end

    column_names = {'animal', 'group', 'day', 'pre_time', 'post_time', 'boot_iterations', 'classification_type', 'region', 'region_type', ...
        'channel', 'accuracy', 'information', 'bootstrapped_info', 'correct_info'};

    %% CSV export set up
    if unit_classification
        csv_path = fullfile(original_path, 'unit_info.csv');
    else
        csv_path = fullfile(original_path, 'pop_info.csv');
    end
    if ~exist(csv_path, 'file') && first_iteration
        info_table = table([], [], [], [], [], [], [], [], [], [], [], [], [], [], 'VariableNames', column_names);
    elseif exist(csv_path, 'file') && first_iteration
        delete(csv_path);
        info_table = table([], [], [], [], [], [], [], [], [], [], [], [], [], [], 'VariableNames', column_names);
    else
        info_table = readtable(csv_path);
    end

    %% Iterates through all the psth formated files and passes them into the clasifier
    information_data = {};
    for h = 1: length(psth_files)
        file = [psth_path, '/', psth_files(h).name];
        [file_path, filename, file_extension] = fileparts(file);
        split_name = strsplit(filename, '.');
        current_day = split_name{6};
        day_num = regexp(current_day,'\d*','Match');
        day_num = str2num(day_num{1});
        current_date = split_name{end};
        current_date = str2num(current_date);
        current_group = split_name{3};
        fprintf('Bootstrapping PSTH for %s on %s\n', animal_name, current_day);
        try
            load(file);

            for i = 1:boot_iterations
                if i == 1
                    classified_struct = struct;

                    % Preforms standard classification
                    classified_struct = crude_classifier(classify_path, failed_path, filename, event_struct.all_events, labeled_neurons, bin_size, pre_time, post_time, unit_classification, i, classified_struct);
                else
                    % Shuffle event labels from the event_ts matrix
                    shuffled_event_labels = event_ts(:,1);
                    shuffled_event_labels = shuffled_event_labels(randperm(length(shuffled_event_labels)));
                    shuffled_events = [shuffled_event_labels, event_ts(:,2)];
                    unique_events = unique(event_ts(:,1));
                    % Recreate the event cell array for PSTH object
                    all_events = {};
                    for event = 1: length(unique_events)
                        %% Slices out the desired trials from the event_ts matrix (Inclusive range)
                        all_events = [all_events; event_strings{event}, {shuffled_events(shuffled_events == unique_events(event), 2)}];
                    end
                    classified_struct = crude_classifier(classify_path, failed_path, filename, all_events, labeled_neurons, bin_size, pre_time, post_time, unit_classification, i, classified_struct);
                end
            end

            % Goes through all the struct fields in the classified struct
            % And corrects the info by subtracting the bootstrapped info off of the original info
            unique_regions = fieldnames(labeled_neurons);
            for region = 1:length(unique_regions)
                current_region = unique_regions{region};
                if (contains(right_direct, animal_name) && strcmpi('Right', current_region)) || (contains(left_direct, animal_name) && strcmpi('Left', current_region))
                    region_type = 'Direct';
                else
                    region_type = 'Indirect';
                end
                if unit_classification
                    for unit = 1:length(labeled_neurons.(current_region)(:,1))
                        current_unit = labeled_neurons.(current_region){unit, 1};
                        unit_info = classified_struct.(current_region).([current_unit, '_information']);
                        avg_boot_info = mean(classified_struct.(current_region).([current_unit, '_bootstrapped_info']));
                        corrected_info = unit_info - avg_boot_info;
                        unit_accuracy = classified_struct.(current_region).([current_unit, '_accuracy']);
                        information_data = [information_data; {animal_name}, {animal_type}, {current_day}, {pre_time}, {post_time}, {boot_iterations}, ...
                            {'unit'}, {current_region}, {region_type}, {current_unit}, {unit_accuracy}, {unit_info}, ...
                            {avg_boot_info}, {corrected_info}];
                            classified_struct.(current_region).([current_unit, '_corrected_info']) = corrected_info;
                            classified_struct.(current_region).([current_unit, '_bootstrapped_info']) = avg_boot_info;
                    end
                else
                    pop_info = classified_struct.(current_region).information;
                    avg_boot_info = mean(classified_struct.(current_region).bootstrapped_info);
                    corrected_info = pop_info - avg_boot_info;
                    pop_accuracy = classified_struct.(current_region).accuracy;
                    information_data = [information_data; {animal_name}, {animal_type}, {current_day}, {pre_time}, {post_time}, {boot_iterations}, ...
                        {'population'}, {current_region}, {region_type}, {'population'}, {pop_accuracy}, {pop_info}, ...
                        {avg_boot_info}, {corrected_info}];
                    classified_struct.(current_region).bootstrapped_info = avg_boot_info;
                    classified_struct.(current_region).corrected_info = corrected_info;
                end
            end

            %% Saving classifier info
            all_events = event_struct.all_events;
            if unit_classification
                unit_path = [classify_path, '/unit'];
                if ~exist(unit_path, 'dir')
                    mkdir(classify_path, 'unit');
                end
                info_filename = strrep(filename, 'PSTH', 'unit');
                info_filename = strrep(info_filename, 'format', 'classified');
                matfile = fullfile(unit_path, ['NEW_', info_filename, '.mat']);
            else
                pop_path = [classify_path, '/population'];
                if ~exist(pop_path, 'dir')
                    mkdir(classify_path, 'population');
                end
                info_filename = strrep(filename, 'PSTH', 'pop');
                info_filename = strrep(info_filename, 'format', 'classified');
                matfile = fullfile(pop_path, ['NEW_', info_filename, '.mat']);
            end
            save(matfile, 'classified_struct', 'all_events', 'labeled_neurons');
        catch ME
            if ~exist(failed_path, 'dir')
                mkdir(classify_path, 'failed');
            end
            filename = ['FAILED.', filename, '.mat'];
            error_message = getReport( ME, 'extended', 'hyperlinks', 'on');
            warning('%s failed to bootstrap\n', filename);
            warning(error_message);
            matfile = fullfile(failed_path, filename);
            save(matfile, 'ME');
        end
    end
    new_info_table = cell2table(information_data, 'VariableNames', column_names);
    info_table = [info_table; new_info_table];
    writetable(info_table, csv_path, 'Delimiter', ',');
    toc;
end