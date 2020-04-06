function  [board_band_map, board_adda_map, board_dig_in_data, t_amplifier, sample_rate] = rhs_parser(file_path)
        %% reads and maps data
    [amplifier_channels, amplifier_data, board_adda_channels, board_adda_data, ...
        board_dig_in_data, t_amplifier, sample_rate] = read_Intan_RHS2000_file(file_path);
    board_band_map = [];
    board_adda_map = [];
    % amplifier data mapping
    [~, tot_amp_channels] = size(amplifier_channels);
    for channel = 1:tot_amp_channels
        board_band_map = [board_band_map; {amplifier_channels(channel).native_channel_name}, ...
            {amplifier_data(channel, :)}];
    end
    % ad/da data mapping    
    [~, tot_adda_channels] = size(board_adda_channels);    
    for channel = 1:tot_adda_channels
        board_adda_map = [board_adda_map; {board_adda_channels(channel).native_channel_name}, ...
            {board_adda_data(channel, :)}];
    end
     
end