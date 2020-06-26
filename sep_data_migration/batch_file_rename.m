
[file_name, path_name] = uigetfile;

rename_table = readtable([path_name, file_name], 'FileType', 'spreadsheet'); 

file_list = dir([path_name, '*.rhs']); 


for i = 1:length(file_list)
   
    full_orig_filename = file_list(i).name;
    [~, orig_filename, ~] = fileparts(full_orig_filename);
      
    filename_index = find(ismember(rename_table.filename, orig_filename));
    
    if ~isempty(filename_index)
       
        new_filename = cell2mat(rename_table.new_filename(filename_index));
        movefile([path_name, full_orig_filename], [path_name, new_filename]);
        
        
    end
end