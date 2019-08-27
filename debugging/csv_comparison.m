function [] = csv_comparison()
    [template_name, template_path] = uigetfile('*.csv', 'Select CSV Template');
    template_file = fullfile(template_path, template_name);
    [results_name, results_path] = uigetfile('*.csv', 'Select comparison file');
    results_file = fullfile(results_path, results_name);
    template = readtable(template_file);
    results = readtable(results_file);
    prec = 5;

    [template_rows, template_cols] = size(template);
    [result_rows, result_cols] = size(results);
    assert(template_rows == result_rows && template_cols == result_cols, ...
        'csv files must have the same number of rows and columns');

    index_diff_col = 1;
    diff_location = struct;
    diff_location.template_path = template_path;
    diff_location.template_filename = template_name;
    diff_location.results_path = results_path;
    diff_location.results_filename = results_name;

    % read two csv files by column
    for index_col = 1:template_cols
        col_check(index_col) = isequaln(template(:,index_col),results(:,index_col));
        if col_check(index_col) == 0
            index_diff_col = 0;
            col_name = template.Properties.VariableNames{index_col};
            diff_location.(col_name).difference = [];
            for index_row = 1:result_rows
                template_value = template{index_row, index_col};
                template_type = class(template_value);
                results_value = results{index_row, index_col};
                results_type = class(results_value);
                template_data = table2cell(template(index_row, :));
                results_data = table2cell(results(index_row, :));
                combined_data = ['template', template_data; 'results', results_data];

                if ~strcmpi(template_type, results_type)
                    %TODO store that point has different variable types
                    diff_location.(col_name).difference = ...
                        [diff_location.(col_name).difference;{index_row}, {template_type}, {results_type}];
                elseif (isnumeric(template_value) && isnumeric(results_value)) && ...
                        ~isequaln(round(template_value, prec), round(results_value, prec))
                    diff_location.(col_name).difference = [diff_location.(col_name).difference; ...
                        {index_row}, {template_value}, {results_value}, {combined_data}];
                elseif (isstring(template_value) && isstring(results_value)) && ~strcmpi(template_value, results_value)
                    diff_location.(col_name).difference = [diff_location.(col_name).difference; ...
                        {index_row}, {template_value}, {results_value}, {combined_data}];
                end

                % else
                %     diff_location.(col_name).difference = [diff_location.(col_name).difference; setdiff(template_value, results_value)];
                % end
            end
        end
    end

    if index_diff_col == 1
        fprintf('These two csv files are the same. \n')
    else
        disp('not the same');
        matfile = fullfile(template_path, 'csv_difference.mat');
        save(matfile, 'diff_location');
    end
end