function [] = confusion_matrix_info(classified_path, animal_name, total_events)
    % TODO add error catching
    %             | Stim1 | Stim2 | ...
    %   ----------|-------------------
    %   Stim1(LVQ)|       |       |
    %   ----------|-------|-------|---
    %   Stim2(LVQ)|       |       |
    %   ----------|-------|-------|---

    tic;

    % Grabs all theclassified .mat files
    classified_mat_path = strcat(classified_path, '/*.mat');
    classified_files = dir(classified_mat_path);

    for h = 1: length(classified_files)
        file = [classified_path, '/', classified_files(h).name];
        [~, file_name, ~] = fileparts(file);
        split_name = strsplit(file_name, '.');
        current_day = split_name{6};
        fprintf('Classifying PSTH for %s on %s\n', animal_name, current_day);
        load(file, 'classified_struct', 'all_events');
        
        struct_names = fieldnames(classified_struct);
        for i = 1: length(struct_names)
            if contains(struct_names{i}, '_confusion')

                confusion_matrix = getfield(classified_struct, struct_names{i});              
                confusion_length = length(confusion_matrix);
                % num_trials should be the equivalent of total_trials * total_events
                num_trials = sum(sum(confusion_matrix));
            
                %%%%%Calcution of Ha and Hb
                h_a = 0;
                h_b = 0;
                for confusion_index = 1: confusion_length
                    prob_a = sum(confusion_matrix(:, confusion_index)) / num_trials;
                    prob_b = sum(confusion_matrix(confusion_index, :)) / num_trials;
                    if ~(prob_a == 0)
                        h_a = h_a - prob_a * log2(prob_a);
                    end
                    if ~(prob_b == 0)
                        h_b = h_b - prob_b * log2(prob_b);
                    end
                end
            
                %% Calcution of Hab
                h_a_b = 0;
                for a = 1:confusion_length
                    for b = 1:confusion_length
                        prob_a_b = confusion_matrix(a, b) / num_trials;
                        if ~(prob_a_b == 0)
                            h_a_b = h_a_b - prob_a_b * log2(prob_a_b);
                        end
                    end
                end

                %% Calculation of I
                classified_struct.(replace(struct_names{i}, 'confusion', 'information')) = ...
                    (h_a + h_b - h_a_b);
            end
        end
        save(file, 'classified_struct', 'all_events');
    end
    toc;
end