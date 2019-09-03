function [labeled_data] = label_neurons(channel_map, label_table, session_num)
    unique_labels = unique(label_table.label);
    for label_index = 1:length(unique_labels)
        curr_label = unique_labels{label_index};
        label_info = label_table(strcmpi(label_table.label, curr_label) & ...
            (label_table.recording_session == session_num), :);
        % Find intersection between channel map and labels
        [~, map_indices, labels_indices] = intersect(channel_map(:,1), label_info.sig_channels);
        curr_data = label_info(labels_indices, :);
        curr_data = addvars(curr_data, channel_map(map_indices, 2), 'After', 'label_id', 'NewVariableNames', 'channel_data');
        labeled_data.(curr_label) = curr_data;
    end
    struct_names = fieldnames(labeled_data);
    empty = cellfun(@(x) isempty(labeled_data.(x)), struct_names);
    labeled_data = rmfield(labeled_data, struct_names(empty));
end