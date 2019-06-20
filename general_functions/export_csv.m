function [] = export_csv(csv_path, column_names, general_table, analysis_table)
    
    var_types = [];
    for column = 1:width(general_table)
        var_types = [var_types, {class(general_table.(column))}];
    end

    for column = 1:width(analysis_table)
        var_types = [var_types, {class(analysis_table.(column))}];
    end
    results_table = table('Size', [0, length(column_names)], 'VariableTypes', var_types, 'VariableNames', column_names);
    if exist(csv_path, 'file')
        results_table = readtable(csv_path);
    end

    new_results_table = [general_table analysis_table];

    results_table = [results_table; new_results_table];
    writetable(results_table, csv_path, 'Delimiter', ',');
end