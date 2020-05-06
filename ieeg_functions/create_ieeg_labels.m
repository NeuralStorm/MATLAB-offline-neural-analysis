function [label_table] = create_ieeg_labels(label_table, ieeg_anat, filename_meta)
    % Input:
    % label_table read in from labels csv
    % ieeg_anat: struct with channels and regions

    %% set up of channels for labels file
    sig_channels = ieeg_anat.channels;
    selected_channels = ones(size(sig_channels));
    user_channels = sig_channels;

    %% Set up of labels
    labels = ieeg_anat.ROIs;
    assert(length(sig_channels) == length(labels), ...
        'Must have number of labels as channels in file');

    [sig_rows, ~] = size(sig_channels);
    [~, label_cols] = size(labels);
    if sig_rows == label_cols
        labels = labels';
    end

    label_id = zeros(size(labels));
    recording_session = repmat(filename_meta.session_num, size(sig_channels));
    recording_notes = repmat({'n/a'}, size(sig_channels));
    curr_labels = table(sig_channels, selected_channels, user_channels, ...
        labels, label_id, recording_session, recording_notes, ...
        'VariableNames', {'sig_channels', 'selected_channels', ...
        'user_channels', 'label', 'label_id', 'recording_session', ...
        'recording_notes'});
    label_table = [label_table; curr_labels];
end