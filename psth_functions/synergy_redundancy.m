function [pop_table] = synergy_redundancy(pop_table, unit_table, bootstrap_classifier)

    unique_regions = unique(pop_table.region);
    for region = 1:length(unique_regions)
        current_region = unique_regions{region};
        if bootstrap_classifier
            %% Grab region corrected info
            region_info = pop_table.corrected_info(strcmpi(pop_table.region, current_region));

            %% Sum unit info above 0 for current region
            unit_info = sum(unit_table.corrected_info( ...
                strcmpi(unit_table.region, current_region) & unit_table.corrected_info > 0));
        else
            %% Grab region info
            region_info = pop_table.mutual_info(strcmpi(pop_table.region, current_region));

            %% Sum unit info above 0 for current region
            unit_info = sum(unit_table.mutual_info(strcmpi(unit_table.region, current_region) & ...
                unit_table.mutual_info > 0));
        end
        %% Calculate synergy redundancy
        synergy_redundancy = region_info - unit_info;
        synergistic = synergy_redundancy > 0;
        pop_table.synergy_redundancy(strcmpi(pop_table.region, current_region)) = synergy_redundancy;
        pop_table.synergistic(strcmpi(pop_table.region, current_region)) = synergistic;
    end
end