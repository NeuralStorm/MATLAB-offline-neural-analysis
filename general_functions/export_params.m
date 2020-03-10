function [] = export_params(current_path, name_modifier, config_table)
    table_path = fullfile(current_path, ['/', name_modifier, '_log.csv']);
    writetable(config_table, table_path);
end