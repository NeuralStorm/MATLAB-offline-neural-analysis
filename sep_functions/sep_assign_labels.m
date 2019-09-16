function [labeled_data] = sep_assign_labels(channel_map, label_table)

    labeled_data = struct('sig_channels', [], 'data', [], 'user_channels', [], ...
        'label', [], 'label_id', [], 'exp_group', [], 'exp_cond', [], 'rec_session', []); 
    
    [~, channel_map_indices, labels_indices] = intersect(channel_map(:,1), label_table.sig_channels);
    
    for labels_indices_index = 1:length(labels_indices)
       
        labeled_data(labels_indices_index).sig_channels = table2cell(label_table(labels_indices_index, 'sig_channels'));       
        labeled_data(labels_indices_index).data = cell2mat(channel_map(channel_map_indices(labels_indices(labels_indices_index)),2));
        labeled_data(labels_indices_index).user_channels = cell2mat(table2cell(label_table(labels_indices_index, 'user_channels')));  
        labeled_data(labels_indices_index).label = cell2mat(table2cell(label_table(labels_indices_index, 'label')));
        labeled_data(labels_indices_index).label_id = cell2mat(table2cell(label_table(labels_indices_index, 'label_id')));  
        labeled_data(labels_indices_index).exp_group = cell2mat(table2cell(label_table(labels_indices_index, 'exp_group')));  
         labeled_data(labels_indices_index).exp_cond = cell2mat(table2cell(label_table(labels_indices_index, 'exp_cond')));
        labeled_data(labels_indices_index).rec_session = cell2mat(table2cell(label_table(labels_indices_index, 'rec_session')));  
    end

%     unique_labels = unique(label_table.label);
%     for label_index = 1:length(unique_labels)
%         curr_label = unique_labels{label_index};
%         label_info = label_table(strcmpi(label_table.label, curr_label) & ...
%             (label_table.recording_session == session_num), :);
%         % Find intersection between channel map and labels
%         [~, map_indices, labels_indices] = intersect(channel_map(:,1), label_info.sig_channels);
%         curr_data = label_info(labels_indices, :);
%         curr_data = addvars(curr_data, channel_map(map_indices, 2), 'After', 'label_id', 'NewVariableNames', 'sliced_data');
%         labeled_data.(curr_label) = curr_data;
%     end
%     struct_names = fieldnames(labeled_data);
%     empty = cellfun(@(x) isempty(labeled_data.(x)), struct_names);
%     labeled_data = rmfield(labeled_data, struct_names(empty));
end
