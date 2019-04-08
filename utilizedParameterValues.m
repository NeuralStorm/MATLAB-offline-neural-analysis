function [] = utilizedParameterValues(original_path,varargin)

    parameter_array_values = ["Parameter Name", "Parameter Value"];
    parameter_array_values = cellstr(string(parameter_array_values));

    % start at 2 to skip adding the path the function has taken
    for number_of_parameters = 2:nargin
        %getting each variable name from main function
        %substract 1 to start the indexing of variable_names at 1
        parameter_names{number_of_parameters-1} = inputname(number_of_parameters); 

        %checks the number of arguments in each variable
        %if it is anything other than 1, must turn into a joined string to be
        %accepted into the table
        if numel(varargin {number_of_parameters-1}) ~= 1
               varargin{number_of_parameters-1} = join( string( varargin{number_of_parameters-1} ));
        end
        %checks if any of the variable values is empty
        %if it is, the empty brackets is replaced with the string "empty"
        %This must be included because table does not accept empty values      
        if isempty( varargin{number_of_parameters-1} )
            varargin{number_of_parameters-1} = "empty";
        end
        %Create an array loop that adds the variable name and corresponding
        %value to the array
        parameter_array_values = [parameter_array_values; parameter_names(number_of_parameters-1), ...
                                 cellstr( string( varargin( number_of_parameters-1 )))];
    end 

    %creates a table from an array
    table_of_values = table(parameter_array_values) ;
    %adds name of csv file to path 
    table_path = fullfile(original_path,'/Variable Names and Values.csv');
    %export the table to .csv file
    writetable(table_of_values,table_path) ;    
end

