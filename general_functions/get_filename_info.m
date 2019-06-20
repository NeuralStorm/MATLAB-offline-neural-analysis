function [animal_id, experimental_group, experimental_condition, session_num, session_date, optional_info] = get_filename_info(filename)
    if contains(filename, '.')
        % Handles file with old format
        split_name = strsplit(filename, '.');
        if length(split_name) ~= 5
            error('Not a supported filename format');
        end

        %% Get animal info 
        study_id = split_name{1};
        animal_id = split_name{2};
        animal_id = strcat(study_id, animal_id);
        experimental_group = split_name{3};
        experimental_condition = strings;

        %% Get session num and date
        session = split_name{4};
        session_num = regexp(session,'\d*','Match');
        session_num = str2double(session_num{1});
        session_date = split_name{end};
        session_date = str2double(session_date);

        optional_info = strings;
    elseif contains(filename, '_')
        % Handles file with new format
        split_name = strsplit(filename, '_');
        if length(split_name) ~= 6
            error('Not a supported filename format');
        end

        %% Get animal info 
        animal_id = split_name{1};
        experimental_group = split_name{2};
        experimental_condition = split_name{3};

        %% Get session num and date
        session = split_name{4};
        session_num = regexp(session,'\d*','Match');
        session_num = str2double(session_num{1});
        session_date = split_name{end - 1};
        session_date = str2double(session_date);

        optional_info = split_name{end};
    else
        error('Not a supported filename format');
    end
end