function [] = rh_parser(parsed_path, failed_path, raw_file, config, label_table)
    try
        %% Get filename info
        [~, filename, ~] = fileparts(raw_file);
        filename_meta = get_filename_info(filename);
        %% reads and maps data
        if strcmpi(config.rh, 'rhs')
            [amp_chan_meta, amplifier_data, board_adda_channels, board_adda_data, ...
                board_dig_in_data, t_amplifier, sample_rate] = read_Intan_RHS2000_file(raw_file);
        elseif strcmpi(config.rh, 'rhd')
            [amp_chan_meta, amplifier_data, board_adda_channels, board_adda_data, ...
                board_dig_in_data, t_amplifier, sample_rate] = read_Intan_RHD2000_file(raw_file);
        else
            error('Expected rhs or rhd files, but given %s', config.rh);
        end
        %% Store channel data in table
        [~, tot_chans] = size(amp_chan_meta);
        a = cell(tot_chans, 2);
        for chan_i = 1:tot_chans
            a(chan_i, :) = [{strrep(amp_chan_meta(chan_i).native_channel_name, '-', '_')}, ...
                amplifier_data(chan_i, :)];
        end
        channel_map = cell2table(a, 'VariableNames', ["channel", "channel_data"]);

        %% enforce labels is all inclusive
        session_table = label_table(label_table.recording_session == filename_meta.session_num, :);
        enforce_labels(channel_map.channel, session_table.channel, filename_meta.session_num)

        [~, tot_adda_channels] = size(board_adda_channels);
        analog_input_map = cell(tot_adda_channels, 2);
        % ad/da data mapping
        for channel = 1:tot_adda_channels
            analog_input_map = [ ...
                {board_adda_channels(channel).native_channel_name}, ...
                {board_adda_data(channel, :)} ...
            ];
        end

        event_info = find_event_samples(board_dig_in_data);

        %% Saves parsed files
        matfile = fullfile(parsed_path, [filename, '.mat']);
        save(matfile, '-v7.3', 'analog_input_map', ...
            'board_dig_in_data', 't_amplifier', 'sample_rate', ...
            'filename_meta', 'channel_map', 'event_info');
        clear('analog_input_map', 'board_dig_in_data', 't_amplifier', ...
            'sample_rate', 'filename_meta', 'channel_map', 'event_info');
    catch ME
        handle_ME(ME, failed_path, filename);
    end
end

function [event_info] = find_event_samples(dig_sig)
    %TODO figure out how to assert square pulse
    %x contains the time stamp of the low -> high part of the pulse
    %y contains the time stamp of the high -> low part of the pulse

    headers = [["event_labels", "cell"]; ["event_ts", "double"]];
    event_info = prealloc_table(headers, [0, size(headers, 1)]);
    [tot_rows, tot_cols] = size(dig_sig);
    for row_i = 1:tot_rows
        lo_hi = cell(0,2); % prealloc so that empty cell array doesnt cause error
        hi_lo = cell(0,2); % prealloc so that empty cell array doesnt cause error
        x = 1;
        while x <= tot_cols
            if dig_sig(row_i, x) == 1
                a = [{['event_', num2str(row_i), '_start']}, x];
                lo_hi = [lo_hi; a];
                while (dig_sig(row_i, x) ~= 0 && x < tot_cols)
                    x = x + 1;
                end
            end
            x = x + 1;
        end
        y = tot_cols;
        while y >= 1
            if dig_sig(row_i, y) == 1
                a = [{['event_', num2str(row_i), '_end']}, y];
                hi_lo = [hi_lo; a];
                while dig_sig(row_i, y) ~= 0 && y > 1
                    y = y - 1;
                end
            end
            y = y - 1;
        end

        a = [lo_hi; hi_lo];
        event_info = vertcat_cell(event_info, a, headers(:, 1), "after");
    end
    event_info = sortrows(event_info, 'event_ts');
    tot_trials = height(event_info);
    event_i = 1:1:tot_trials;
    event_info.event_indices = event_i';
end