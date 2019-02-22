function [] = readVariables(original_path,varargin)


%set the name of columns of table
array_values=["Variable Name","Value"];

array_values=cellstr(string(array_values));


for number_of_variables=2:nargin
   
     variable_names{number_of_variables-1}=inputname(number_of_variables); %getting each variable name from main function
     
     %checks the number of arguments in each variable
     %if it is anything other than 1, must turn into a joined string to be
     %accepted into the table
        if numel(varargin{number_of_variables-1}) ~=1
            
            varargin{number_of_variables-1}=join(string(varargin{number_of_variables-1}));
        end
     
     %checks if any of the variable values is empty
     %if it is, the empty brackets is replaced with the string "empty"
     %This must be included because table does not accept empty values
        
        if isempty(varargin{number_of_variables-1})
            
            varargin{number_of_variables-1}="empty";
        end
     
     array_values = [array_values; variable_names(number_of_variables-1), cellstr(string(varargin(number_of_variables-1)))]
end

%creates a table from an array
table_of_values=table(array_values) ;

 %adds name of excel file to path 
table_path=fullfile(original_path,'/Variable Names and Values.csv');

%export the table to .csv file
writetable(table_of_values,table_path) ;    


 
end

