function [meta_struct] = get_filename_info(filename)
    meta_struct = struct;
    meta_struct.filename = filename;
    if contains(filename, '.')
        % Handles file with old format
        split_name = strsplit(filename, '.');
        %% Must be at least 5 long to have the right number of fields
        if length(split_name) >= 5
            error('Not a supported filename format');
        end

        %% Get animal info 
        study_id = split_name{end - 4};
        animal_id = split_name{end - 3};
        meta_struct.animal_id = strcat(study_id, animal_id);
        meta_struct.experimental_group = split_name{end - 2};
        meta_struct.experimental_condition = strings;

        %% Get session num and date
        session = split_name{end - 1};
        session_num = regexp(session,'\d*','Match');
        meta_struct.session_num = str2double(session_num{1});
        session_date = split_name{end};
        meta_struct.session_date = str2double(session_date);

        meta_struct.optional_info = strings;
    elseif contains(filename, '_')
        % Handles file with new format
        split_name = strsplit(filename, '_');
        %% Must be at least 6 long to have the right number of fields
        if length(split_name) >= 6
            error('Not a supported filename format');
        end

        %% Get animal info 
        meta_struct.animal_id = split_name{end - 5};
        meta_struct.experimental_group = split_name{end - 4};
        meta_struct.experimental_condition = split_name{end - 3};

        %% Get session num and date
        session = split_name{end - 2};
        session_num = regexp(session,'\d*','Match');
        meta_struct.session_num = str2double(session_num{1});
        session_date = split_name{end - 1};
        meta_struct.session_date = str2double(session_date);

        optional_info = split_name{end};
        if strcmpi(optional_info, 'double') && isnan(optional_info)
            optional_info = 'n/a';
        end
        meta_struct.optional_info = optional_info;
    else
        error('Not a supported filename format');
    end
end