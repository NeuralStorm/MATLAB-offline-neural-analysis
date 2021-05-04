function [label_table] = create_ieeg_labels(label_table, ieeg_anat, session_num)

    %% Purpose: Create/append to labels csv
    %% Input:
    % label_table: table with information of current recordingv
    %              field: table with columns (can be empty, but must have the columns set up)
    %                     'channel': String with name of channel
    %                     'selected_channels': Boolean if channel is used
    %                     'user_channels': String with user defined mapping
    %                     'label': String: associated region or grouping of electrodes
    %                     'label_id': Int: unique id used for labels
    %                     'recording_session': Int: File recording session number that above applies to
    %                     'recording_notes': String with user defined notes for channel
    % ieeg_anat: struct with channels and regions
    %            channels: cell vector with names of channels
    %            ROIs: cell vector with regions channels belong to
    % session_num: Int with session num of current file
    %% Output:
    % label_table: Concated label table from current recording session

    %% set up of channels for labels file
    channel = ieeg_anat.channels;
    selected_channels = ones(size(channel));
    user_channels = channel;

    %% Set up of labels
    labels = ieeg_anat.ROIs;
    assert(length(channel) == length(labels), ...
        'Must have number of labels as channels in file');

    [sig_rows, ~] = size(channel);
    [~, label_cols] = size(labels);
    if sig_rows == label_cols
        labels = labels';
    end

    label_id = zeros(size(labels));
    recording_session = repmat(session_num, size(channel));
    recording_notes = repmat({'n/a'}, size(channel));
    curr_labels = table(channel, selected_channels, user_channels, ...
        labels, label_id, recording_session, recording_notes, ...
        'VariableNames', {'channel', 'selected_channels', ...
        'user_channels', 'label', 'label_id', 'recording_session', ...
        'recording_notes'});
    label_table = [label_table; curr_labels];
end