function [] = rh_parser(parsed_path, failed_path, raw_file, config)
    try
        %% reads and maps data
        if strcmpi(config.rh, 'rhs')
            [amplifier_channels, amplifier_data, board_adda_channels, board_adda_data, ...
                board_dig_in_data, t_amplifier, sample_rate] = read_Intan_RHS2000_file(raw_file);
        elseif strcmpi(config.rh, 'rhd')
            [amplifier_channels, amplifier_data, board_adda_channels, board_adda_data, ...
                board_dig_in_data, t_amplifier, sample_rate] = read_Intan_RHD2000_file(raw_file);
        else
            error('Expected rhs or rhd files, but given %s', config.rh);
        end
        board_band_map = [];
        board_adda_map = [];
        % amplifier data mapping
        [~, tot_amp_channels] = size(amplifier_channels);
        for channel = 1:tot_amp_channels
            board_band_map = [ ...
                board_band_map; ...
                {amplifier_channels(channel).native_channel_name}, ...
                {amplifier_data(channel, :)} ...
            ];
        end
        % ad/da data mapping
        [~, tot_adda_channels] = size(board_adda_channels);
        for channel = 1:tot_adda_channels
            board_adda_map = [ ...
                board_adda_map; ...
                {board_adda_channels(channel).native_channel_name}, ...
                {board_adda_data(channel, :)} ...
            ];
        end
        %% Saves parsed files
        [~, filename, ~] = fileparts(raw_file);
        filename_meta = get_filename_info(filename);
        matfile = fullfile(parsed_path, [filename, '.mat']);
        save(matfile, '-v7.3','board_band_map', 'board_adda_map', ...
            'board_dig_in_data', 't_amplifier', 'sample_rate', 'filename_meta');
    catch ME
        handle_ME(ME, failed_path, filename);
    end
end