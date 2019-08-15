function [] = csv_comparison()
    [template_name, template_path] = uigetfile('*.csv', 'Select CSV Template');
    template_file = fullfile(template_path, template_name);
    [results_name, results_path] = uigetfile('*.csv', 'Select comparison file');
    results_file = fullfile(results_path, results_name);
    template = readtable(template_file);
    results = readtable(results_file);

    precision = .000001;
    [template_rows, template_cols] = size(template);
    [result_rows, result_cols] = size(results);
    assert(template_rows == result_rows && template_cols == result_cols, ...
        'csv files must have the same number of rows and columns');

    index_diff_row = 1;
    index_diff_col = 1;
    diff_location = struct;

    % read two csv files by column
    for index_col = 1:template_cols
        col_check(index_col) = isequaln(template(:,index_col),results(:,index_col));
        if col_check(index_col) == 0
            for index_row = 1:total_row
                original_value = template{index_row,index_col};
                new_value = results{index_row,index_col};
                if (isnan(original_value) && isnan(new_value))
                    diff = 0;
                else
                    diff = original_value-new_value;
                    if  (abs(diff) > precision || isnan(diff))
                        diff_index(index_diff_row) = index_row;
                        index_diff_row = index_diff_row+1 ;
                    end
                end
            end
            
            if index_diff_row > 1
                if index_diff_col == 1
                    fprintf('These two csv files are different.\n')
                end
                index_diff_col = index_diff_col+1; 
            end
            if index_diff_row == (total_row + 1)
                diff_location(1).(['column', num2str(index_col)]) = 'all changed';
            else
                for diff_num = 1:length(diff_index)
                    diff_location(diff_num).(['column',num2str(index_col)]) = ...
                        ['row',num2str(diff_index(diff_num))];
                end
            end
            index_diff_row = 1;
            diff_index = [];
        end 
    end

    if index_diff_col == 1
        fprintf('These two csv files are the same. \n')
    end
end