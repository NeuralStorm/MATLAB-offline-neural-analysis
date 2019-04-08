function [parameterStruct] = import_config(original_path)
    original_path = uigetdir(pwd);
    parameter_csv_path=[original_path, '/*.csv'];
    parameter_csv_file=dir(parameter_csv_path);
    for csv=1:length(parameter_csv_file)
        csv_file=fullfile(original_path, parameter_csv_file(csv).name);
        if contains(parameter_csv_file(csv).name, 'Variable Names and Values.csv')
            ParameterCsvValues = readtable(csv_file);  
        end
    end 
    % Check main.m line 279 -> enforce that the csv is on that path
    %coverts second column of cell to table
    parameterValues = table2cell( ParameterCsvValues(:,2)); 
    arrayOfParameterNames = table2array( ParameterCsvValues(:, 1)); 

    %function input variables -> moved to main
    parameterNames = ["total_trials", "total_events", "trial_lower_bound", "is_non_strobed_and_strobed",...
        "event_map", "bin_size", "pre_time", "post_time", "wanted_events", "trial_range"];

    [~,parameterNameIndex,parameterValueIndex] = intersect(parameterNames, arrayOfParameterNames);
    %indexing the values for the names and corresponding values that is to
    %be outputed to the struct
    structOutputValue = parameterValues(parameterValueIndex);
    structOutputName = parameterNames(parameterNameIndex);
    %Create a parameter struct by equating each parameter name to corresponding
    %parameter value 
    for parameterStructIndex = 1:length(structOutputName)
        parameterStruct.(structOutputName( parameterStructIndex )) = structOutputValue( parameterStructIndex );
    end 
        
end

