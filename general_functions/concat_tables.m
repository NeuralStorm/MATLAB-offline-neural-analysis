function [session_table, session_results] = concat_tables(general_column_names, ...
        session_table, session_info, session_results, analysis_results)
    session_results = [session_results; analysis_results];
    total_rows = height(analysis_results);
    session_info = repmat(session_info, [total_rows, 1]);
    session_info = cell2table(session_info, 'VariableNames', general_column_names);
    session_table = [session_table; session_info];
end