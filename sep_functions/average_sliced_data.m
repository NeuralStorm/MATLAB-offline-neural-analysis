function [averaged_sep] = average_sliced_data(data_map, trial_range)

    for index = 1:length(data_map)
       
        if isempty(trial_range)           
            data_map(index).data = mean(data_map(index).data);            
        else
            data_map(index).data = mean(data_map(index).data(trial_range(1):trial_range(2),:));
        end
        
    end

    averaged_sep = data_map; 
end

