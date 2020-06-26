path = 'C:\Users\garyh\Box\MoxonLab\Projects\CSM Chronic Sensorimotor Study\Evoked Potential Experiment CODEBASE Data\raw\CSM012';
file_list = dir([path, '/*.rhs']);

for i = 1:length(file_list) 
   
    full_filename = file_list(i).name;
    [~, filename, ~] = fileparts(full_filename);
    filename_meta = get_filename_info(filename);
    
    sort_list(i) = filename_meta; 
    
end

sort_list = struct2table(sort_list); 
sort_list = sortrows(sort_list, [6, 7]); 
sort_list = table2struct(sort_list); 

for i = 1:length(sort_list)
    
    filename = sort_list(i).filename;                
            
    if i < 10
        format_str = '00'; 
    elseif i >=10 && i < 100
        format_str = '0';
    else
        format_str = '';
    end

    final_filename = [sort_list(i).animal_id, '_', 'NoEx', '_', ...
    num2str(sort_list(i).session_num), '-', sort_list(i).experimental_condition, '_', ...
    [format_str, num2str(i)], '_', ...
    num2str(sort_list(i).session_date), '_', sort_list(i).optional_info, '.rhs'];

    sort_list(i).new_filename = final_filename; 
    
    
end

