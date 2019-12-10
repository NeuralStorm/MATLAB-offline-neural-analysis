function [raw_table] = calc_cop(raw_data, dimension)
    % f = force
    if dimension == 1
        table_names = raw_data.Properties.VariableNames;
        force_cols = cell2mat(cellfun( ...
            @(x) contains(x, '_f', 'IgnoreCase', true), table_names, 'UniformOutput', false));
        f_table = raw_data(:, force_cols);
        x_pos = [0.5 0 1]; % fl lh rh
        y_pos = [1 0 0]; % fl lh rh
        cop_samples = zeros(height(f_table), 2);
        parfor sample_i = 1:height(f_table)
            %% Go through all samples and calculate cop_x and cop_y for each sample
            tot_f = sum(f_table{sample_i, :});
            if tot_f == 0
                warning('Total forces equal zero. Setting cop_x and cop_y to (0.5, 0.5)');
                cop_x = 0.5;
                cop_y = 0.5;
            else
                cop_x = sum(f_table{sample_i, :} .* x_pos) / tot_f;
                cop_y = sum(f_table{sample_i, :} .* y_pos) / tot_f;
            end
            cop_samples(sample_i, :) = [cop_x, cop_y];
        end
        cop_table = array2table(cop_samples, 'VariableNames', {'cop_x', 'cop_y'});
        raw_table = [raw_data, cop_table];
    else
        error('Invalid dimension parameter');
    end
end
