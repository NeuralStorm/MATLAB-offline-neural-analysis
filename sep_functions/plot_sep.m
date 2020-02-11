[path] = uigetdir('MultiSelect', 'on');

file_list = dir([path, '\*.mat']);
if ~exist([path, '/figures'], 'dir')
    mkdir(path, 'figures');
end

chan_order = [8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,...
    23,22,21,20,19,18,17,16,31,30,29,28,27,26,25,24]; 

for file = 1:length(file_list); 
 
    load([path, '/', file_list(file).name]); 
    time = linspace(sep_analysis_results(1).sep_window(1), sep_analysis_results(1).sep_window(2), ...
    length(sep_analysis_results(1).sep_sliced_data));
        
    regions = unique({sep_analysis_results.label}); 
    for current_region = 1:length(regions)
        
        %check the regions in the file and make new directory for new regions
        if ~exist([path, '/figures/', cell2mat(regions(current_region))], 'dir')
                mkdir([path, '/figures/', cell2mat(regions(current_region))]);
        end
        
        %extracts data for the current region
        region_list = {sep_analysis_results.label};
        region_index = cellfun(@(x)contains(x, regions(current_region)), region_list, 'UniformOutput', 1);
        region_data = sep_analysis_results(region_index); 
        
        y_max = max([region_data.sep_sliced_data]) + (0.2 * max([region_data.sep_sliced_data]));
        y_min = min([region_data.sep_sliced_data]) + (0.2 * min([region_data.sep_sliced_data]));
        
        if (y_max < 50) 
            y_max = 50; 
        end
        if (y_min > -50)
            y_min = -50; 
        end       
        %Are the electrode orientations the same for both sides of the
        %cortex???? If not, need code here for chan_order
        
        for region_chan = 1:length(region_data)
            
            subplot(4, 8, (chan_order(region_chan) + 1));
            plot(time, sep_analysis_results(region_chan).sep_sliced_data);
            hold on;
            sgtitle([file_list(file).name, ' ', regions(current_region)]);
            xlim([-0.2, 0.4]); 
            ylim([y_min, y_max]);

        end
        
        savefig([path, '/figures/', cell2mat(regions(current_region)), '/' file_list(file).name, '.fig']);
        close; 
        
    end
    
end
