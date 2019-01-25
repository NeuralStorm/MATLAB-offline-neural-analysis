function [] = readVariables(original_path,varargin)


 for number_of_variables=2:nargin
   
     variable_names{number_of_variables-1}=inputname(number_of_variables); %getting each variable name from main function
    
 end
 
 variable_names= char(variable_names)  %converting variable names to character

 empty_values=cellfun(@(x) ~isnumeric(x),varargin)  %look at values imported and check all the variables that are not numbers

%empty_values=cellfun('isempty',varargin);  %look at values imported and check all the empty variables
varargin(empty_values)=[];     % if no value is assigned to a variable, we remove the variable from our table

available_values=transpose(~empty_values);   
new_variable_names=variable_names.*available_values; %new_variable_names now becomes the array with same number of variables but the variables with no value become empty

new_variable_names=char(new_variable_names);
empty_variables=isempty(new_variable_names);      
new_variable_names(empty_variables)=[];             

new_variable_names=string(new_variable_names)
new_variable_names=deblank(new_variable_names)
new_variable_names(cellfun('isempty',new_variable_names)) = []    %remove the empty strings to give accurate array size corresponding to values
new_variable_names=transpose(new_variable_names)



values=transpose(varargin)
table_of_variables=array2table(transpose(new_variable_names))   %create a table for variable names

table_of_values=table(values)      %create a table for the values

 table_path=fullfile(original_path,'/Variable Names and Values.csv'); 
 
final_table=[table_of_variables,table_of_values]   %concatenate table's together
writetable(final_table,table_path)     %export the table to .csv file


 
end

