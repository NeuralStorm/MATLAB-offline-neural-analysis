function [] = crude_synergy_redundancy(original_path, spreadsheet_name)
    % Grabs all the csv files
    csv_mat_path = [original_path, '/*.csv'];
    csv_files = dir(csv_mat_path);
    for file = 1: length(csv_files)
        if contains(csv_files(file).name, 'unit')
            % Auto-generated by MATLAB on 2018/08/14 11:15:11

            %% Initialize variables.
            filename = fullfile(original_path, csv_files(file).name);
            delimiter = ',';

            %% Read columns of data as text:
            % For more information, see the TEXTSCAN documentation.
            formatSpec = '%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%s%s%[^\n\r]';
            
            %% Open the text file.
            fileID = fopen(filename,'r');
            
            %% Read columns of data according to the format.
            % This call is based on the structure of the file used to generate this
            % code. If an error occurs for a different file, try regenerating the code
            % from the Import Tool.
            dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
            
            %% Close the text file.
            fclose(fileID);
            
            %% Convert the contents of columns containing numeric text to numbers.
            % Replace non-numeric text with NaN.
            raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
            for col=1:length(dataArray)-1
                raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
            end
            numericData = NaN(size(dataArray{1},1),size(dataArray,2));
            
            % Converts text in the input cell array to numbers. Replaced non-numeric
            % text with NaN.
            rawData = dataArray{1};
            for row=1:size(rawData, 1)
                % Create a regular expression to detect and remove non-numeric prefixes and
                % suffixes.
                regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
                try
                    result = regexp(rawData(row), regexstr, 'names');
                    numbers = result.numbers;
                    
                    % Detected commas in non-thousand locations.
                    invalidThousandsSeparator = false;
                    if numbers.contains(',')
                        thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                        if isempty(regexp(numbers, thousandsRegExp, 'once'))
                            numbers = NaN;
                            invalidThousandsSeparator = true;
                        end
                    end
                    % Convert numeric text to numbers.
                    if ~invalidThousandsSeparator
                        numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                        numericData(row, 1) = numbers{1};
                        raw{row, 1} = numbers{1};
                    end
                catch
                    raw{row, 1} = rawData{row};
                end
            end
            
            
            %% Split data into numeric and string columns.
            rawNumericColumns = raw(:, 1);
            rawStringColumns = string(raw(:, 2));
            
            
            %% Replace non-numeric cells with NaN
            R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
            rawNumericColumns(R) = {NaN}; % Replace non-numeric cells
            
            %% Make sure any text containing <undefined> is properly converted to an <undefined> categorical
            idx = (rawStringColumns(:, 1) == "<undefined>");
            rawStringColumns(idx, 1) = "";
            
            %% Create output variable
            unit_spreadsheet = table;
            unit_spreadsheet.neuron_corrected_info = cell2mat(rawNumericColumns(:, 1));
            unit_spreadsheet.neuron_label = categorical(rawStringColumns(:, 1));
            
            %% Clear temporary variables
            clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp rawNumericColumns rawStringColumns R idx;


            %% End of auto-generated code
            % neuron_labels = unit_spreadsheet.neuron_label;
            % neuron_labels(1, :) = [];
        elseif contains(csv_files(file).name, 'population')
            pop_spreadsheet = readtable(csv_files(file).name);
            if ismember('syn_red', pop_spreadsheet.Properties.VariableNames)
                pop_spreadsheet = removevars(pop_spreadsheet, 'syn_red');
            end
            if ismember('syn_red_bool', pop_spreadsheet.Properties.VariableNames)
                pop_spreadsheet = removevars(pop_spreadsheet, 'syn_red_bool');
            end
        end
    end

    direct_syn_red = [];
    indirect_syn_red = [];
    direct_syn_red_bool = [];
    indirect_syn_red_bool = [];
    for population = 1: length(pop_spreadsheet.pop_corrected_info)
        direct_unit_corrected_sum = 0;
        indirect_unit_corrected_sum = 0;
        unit_index = 2;
        for neuron = 1: pop_spreadsheet.tot_neurons(population)
            if (unit_spreadsheet.neuron_corrected_info(unit_index, 1) > 0) && (unit_spreadsheet.neuron_label(unit_index, 1) == 'Direct')
                direct_unit_corrected_sum = direct_unit_corrected_sum + unit_spreadsheet.neuron_corrected_info(unit_index, 1);
            elseif (unit_spreadsheet.neuron_corrected_info(unit_index, 1) > 0) && (unit_spreadsheet.neuron_label(unit_index, 1) == 'Indirect')
                indirect_unit_corrected_sum = indirect_unit_corrected_sum + unit_spreadsheet.neuron_corrected_info(unit_index, 1);
            end
            unit_index = unit_index + 1;
        end
        corrected_pop_info = pop_spreadsheet.pop_corrected_info(population);
        current_direct_syn_red = (corrected_pop_info - direct_unit_corrected_sum);
        current_indirect_syn_red = (corrected_pop_info - indirect_unit_corrected_sum);
        direct_syn_red = [direct_syn_red, current_direct_syn_red];
        indirect_syn_red = [indirect_syn_red, current_indirect_syn_red];
        direct_syn_red_bool = [direct_syn_red_bool, (current_direct_syn_red > 0)];
        indirect_syn_red_bool = [indirect_syn_red_bool, (current_indirect_syn_red > 0)];
    end

    pop_spreadsheet.direct_syn_red = direct_syn_red';
    pop_spreadsheet.indirect_syn_red = indirect_syn_red';
    pop_spreadsheet.direct_syn_red_bool = direct_syn_red_bool';
    pop_spreadsheet.indirect_syn_red_bool = indirect_syn_red_bool';
    matfile = fullfile(original_path, ['test_', spreadsheet_name]);
    writetable(pop_spreadsheet, matfile, 'Delimiter', ',');
end