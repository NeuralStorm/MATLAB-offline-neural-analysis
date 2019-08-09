% read file path
[file, path, filterindex] = ...
    uigetfile({'*.rhd';'*.rhs'}, 'Select an Data File: .rhd or .rhs', 'MultiSelect', 'off');
if (file == 0)
    return;
end
filename = [path,file];
[~,~,extension] = fileparts(filename);

% choose one decoder according to the file type
switch extension
    case '.rhd'    % board_adc_data
    [amplifier_channels, amplifier_data, board_adc_channels, board_adc_data, ...
        board_dig_in_data, t_amplifier, sample_rate] = read_Intan_RHD2000_file(filename);
    [board_band_map, board_adc_map] = data_mapping(amplifier_channels, amplifier_data, ...
        board_adc_channels, board_adc_data);

    case '.rhs'    % board_dac_data
    [amplifier_channels, amplifier_data, board_dac_channels, board_dac_data, ...
        board_dig_in_data, t_amplifier, sample_rate] = read_Intan_RHS2000_file(filename);
    [board_band_map, board_dac_map] = data_mapping(amplifier_channels, amplifier_data, ...
        board_dac_channels, board_dac_data);
    
%     case '.pl2'
%     [adfreq, ~, ~, ~, ad] = plx_ad_v(filename, 1);
%     [n, ts, sv] = plx_event_ts(filename, 1);

    otherwise
        error('Unexpected file type.');
end
%filter
filter_parameters = filter_input_panel;
[lowpass_filtered_data] = butterworth(filter_parameters(1), filter_parameters(2)/(sample_rate/2), ...
    'low', amplifier_data(1,:));
[highpass_filtered_data] = butterworth(filter_parameters(3), filter_parameters(4)/(sample_rate/2), ...
    'high', amplifier_data(1,:));

figure(1);
plot(amplifier_data(1,:));
figure(2);
plot(lowpass_filtered_data);
figure(3);
plot(highpass_filtered_data);

clearvars -except board_band_map board_adc_map board_dac_map board_dig_in_data highpass_filtered_data ...
    lowpass_filtered_data sample_rate t_amplifier;




