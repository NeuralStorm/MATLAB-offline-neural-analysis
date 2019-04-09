function [config] = import_config(animal_path, config_names)

    %% Grabs config file and creates labels
    animal_csv_path = [animal_path, '/*.csv'];
    csv_files = dir(animal_csv_path);
    for csv = 1:length(csv_files)
        csv_file = fullfile(animal_path, csv_files(csv).name);
        if contains(csv_files(csv).name, 'config.csv')
            config_table = readtable(csv_file);
        end
    end
    config = struct;

    [~, config_name_index, config_table_index] = intersect(config_names, config_table.key);
    for index = 1:length(config_name_index)
        current_name = config_table.key{index};
        current_value = config_table.value{index};
        if contains(current_value, ' ') || contains(current_value, ',')
            if contains(current_value, ' ')
                split_values = strsplit(current_value, ' ');
            else
                split_values = strsplit(current_value, ',');
            end
            value = [];
            for sub_value = 1:length(split_values)
                current_sub_value = split_values{sub_value};
                value = [value, convert_string(current_sub_value)];
            end
        elseif contains(current_value, ';')
            split_values = strsplit(current_value, ';');
            value = [];
            for sub_value = 1:length(split_values)
                current_sub_value = split_values{sub_value};
                value = [value, convert_string(current_sub_value)];
            end
        else
            value = convert_string(current_value);
        end
        config.(current_name) = value;
    end
end

function [value] = convert_string(string_value)
    if all(ismember(string_value, '0123456789+-.eEdD'))
        value = str2num(string_value);
    elseif strcmpi(string_value, 'true')
        value = true;
    elseif strcmpi(string_value, 'false')
        value = false;
    else
        value = string_value;
    end
end