function [] = enforce_labels(channel_list, label_list, session_num)
    missing_labels = setdiff(channel_list, label_list);
    if ~isempty(missing_labels)
        label_str = ['Session: ', num2str(session_num), ':'];
        for label_i = 1:length(missing_labels)
            curr_label = missing_labels{label_i};
            label_str = [label_str, ' ', curr_label];
        end
        ME = MException('missing:labels', '%s', label_str);
        throw(ME);
    end
end