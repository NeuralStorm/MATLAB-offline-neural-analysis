original_csv = readtable('original_receptive_field_results.csv');
new_csv = readtable('new_receptive_field_results.csv');
original_csv = table2cell(original_csv);    
new_csv = table2cell(new_csv);
precision = .000001;
[total_row,total_col] = size(original_csv);
index_diff_row = 1;
index_diff_col = 1;
diff_location = struct;

% read two csv files by column
 for index_col = 1:total_col   
     col_check(index_col) = isequaln(original_csv(:,index_col),new_csv(:,index_col));
     if col_check(index_col) == 0
         for index_row = 1:total_row
             original_value = original_csv{index_row,index_col};
             new_value = new_csv{index_row,index_col};
             
             if (isnan(original_value) & isnan(new_value))
                 diff = 0;
             else
                 diff = original_value-new_value;
                 if  (abs(diff) > precision | isnan(diff))
                     
                      diff_index(index_diff_row) = index_row;
                      index_diff_row = index_diff_row+1 ;
                 end
             end   
         end
         
         if index_diff_row > 1
             if index_diff_col == 1
                 fprintf('¡Á¡Á¡ÁThese two csv files are different. Check the ¡®diff_location¡¯ for details. \n')
             end
             index_diff_col = index_diff_col+1; 
         end
         if index_diff_row == (total_row + 1)
             diff_location(1).(['column',num2str(index_col)]) = 'all changed';
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
     fprintf('¡Ì¡Ì¡ÌThese two csv files are the same. \n')
 end
     



    

