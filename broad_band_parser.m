[file, path, filterindex] = ...
    uigetfile({'*.rhd';'*.rhs';'*.pl2'}, 'Select an Data File: RHD2000', 'MultiSelect', 'off');
if (file == 0)
    return;
end
filename = [path,file];
[~,~,extension] = fileparts(filename);
% choose one decoder according to the file type
switch extension
    case '.rhd'    % board_adc_data
    [amplifier_data, board_data, board_dig_in_data, t_amplifier,...
        sample_rate] = read_Intan_RHD2000_file(filename);
    case '.rhs'    % board_dac_data
    [amplifier_data, board_data, board_dig_in_data, t_amplifier,...
           sample_rate] = read_Intan_RHS2000_file(filename);
%     case '.pl2'
        
    otherwise
        error('Unexpected file type.');
end



