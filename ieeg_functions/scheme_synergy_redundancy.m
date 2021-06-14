function [pop_table] = scheme_synergy_redundancy(pop_table, chan_table, boot_iterations)

    headers = [["scheme", "string"]; ["chan_group", "string"]; ["synergy_redundancy", "double"]; ...
               ["synergistic", "double"]];
    [tot_headers, ~] = size(headers);
    unique_ch_groups = unique(pop_table.chan_group);
    unique_schemes = unique(pop_table.scheme);
    syn_red = prealloc_table(headers, [0, tot_headers]);

    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        for scheme_i = 1:numel(unique_schemes)
            scheme = unique_schemes{scheme_i};
            if boot_iterations > 0
                %% Grab chan_group corrected info
                ch_group_info = pop_table.corrected_info(strcmpi(pop_table.chan_group, ch_group) ...
                    & strcmpi(pop_table.scheme, scheme));

                %% Sum chan info above 0 for current chan_group
                chan_info = sum(chan_table.corrected_info(strcmpi(chan_table.chan_group, ch_group) ...
                    & strcmpi(chan_table.scheme, scheme)));
            else
                %% Grab chan_group info
                ch_group_info = pop_table.mutual_info(strcmpi(pop_table.chan_group, ch_group) ...
                    & strcmpi(pop_table.scheme, scheme));

                %% Sum chan info above 0 for current chan_group
                chan_info = sum(chan_table.mutual_info(strcmpi(chan_table.chan_group, ch_group) ...
                    & strcmpi(chan_table.scheme, scheme)));
            end
            %% Calculate synergy redundancy
            synergy_redundancy = ch_group_info - chan_info;
            synergistic = synergy_redundancy > 0;
            % syn_red(ch_group_i, :) = [{scheme}, {ch_group}, synergy_redundancy, double(synergistic)];
            a = [{scheme}, {ch_group}, synergy_redundancy, double(synergistic)];;
            syn_red = vertcat_cell(syn_red, a, headers(:, 1), "after");
        end
    end
    pop_table = join(pop_table, syn_red, 'Keys', {'scheme', 'chan_group'});
end