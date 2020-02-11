function [board_band_map, board_adda_map, board_dig_in_data, t_amplifier, sample_rate] = board_band_parser(file_path)
    [~, ~, extension] = fileparts(file_path);
    %% Select parser based on the extension 
    switch extension
        case '.rhd'    
            [board_band_map, board_adda_map, board_dig_in_data, t_amplifier, ...
                sample_rate] = rhd_parser(file_path);
        
        case '.rhs'    
            [board_band_map, board_adda_map, board_dig_in_data, t_amplifier, ...
                sample_rate] = rhs_parser(file_path);
        
        otherwise
            board_band_map = NaN; board_adda_map = NaN; board_dig_in_data = NaN;
            t_amplifier = NaN; sample_rate = NaN;  
    end

end
 


