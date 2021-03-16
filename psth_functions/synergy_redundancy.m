function [pop_table] = synergy_redundancy(pop_table, chan_table, boot_iterations)

    headers = [["region", "string"]; ["synergy_redundancy", "double"]; ...
               ["synergistic", "double"]];
    [tot_headers, ~] = size(headers);
    unique_regions = unique(pop_table.region);
    syn_red = prealloc_table(headers, [numel(unique_regions), tot_headers]);

    for reg_i = 1:length(unique_regions)
        region = unique_regions{reg_i};
        if boot_iterations > 0
            %% Grab region corrected info
            region_info = pop_table.corrected_info(strcmpi(pop_table.region, region));

            %% Sum unit info above 0 for current region
            chan_info = sum(chan_table.corrected_info(strcmpi(chan_table.region, region)));
        else
            %% Grab region info
            region_info = pop_table.mutual_info(strcmpi(pop_table.region, region));

            %% Sum unit info above 0 for current region
            chan_info = sum(chan_table.mutual_info(strcmpi(chan_table.region, region)));
        end
        %% Calculate synergy redundancy
        synergy_redundancy = region_info - chan_info;
        synergistic = synergy_redundancy > 0;
        syn_red(reg_i, :) = [{region}, synergy_redundancy, double(synergistic)];
    end
    pop_table = join(pop_table, syn_red, 'Keys', 'region');
end