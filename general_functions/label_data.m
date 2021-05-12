function [session_table] = label_data(channel_table, label_table, session_num)
    if isempty(channel_table)
        error('Channel map is empty so cannot label any channels')
    end
    session_table = label_table(label_table.recording_session == session_num ...
        & label_table.selected_channels == 1, :);

    %% Join tables
    session_table = innerjoin(channel_table, session_table);

    if isempty(session_table)
        error('labels file failed to label any channels from channel map');
    end
end