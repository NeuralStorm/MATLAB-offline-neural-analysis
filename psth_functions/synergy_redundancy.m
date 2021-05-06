function [pop_table] = synergy_redundancy(pop_table, chan_table, boot_iterations)

    headers = [["chan_group", "string"]; ["synergy_redundancy", "double"]; ...
               ["synergistic", "double"]];
    [tot_headers, ~] = size(headers);
    unique_ch_groups = unique(pop_table.chan_group);
    syn_red = prealloc_table(headers, [numel(unique_ch_groups), tot_headers]);

    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        if boot_iterations > 0
            %% Grab chan_group corrected info
            ch_group_info = pop_table.corrected_info(strcmpi(pop_table.chan_group, ch_group));

            %% Sum unit info above 0 for current chan_group
            chan_info = sum(chan_table.corrected_info(strcmpi(chan_table.chan_group, ch_group)));
        else
            %% Grab chan_group info
            ch_group_info = pop_table.mutual_info(strcmpi(pop_table.chan_group, ch_group));

            %% Sum unit info above 0 for current chan_group
            chan_info = sum(chan_table.mutual_info(strcmpi(chan_table.chan_group, ch_group)));
        end
        %% Calculate synergy redundancy
        synergy_redundancy = ch_group_info - chan_info;
        synergistic = synergy_redundancy > 0;
        syn_red(ch_group_i, :) = [{ch_group}, synergy_redundancy, double(synergistic)];
    end
    pop_table = join(pop_table, syn_red, 'Keys', 'chan_group');
end