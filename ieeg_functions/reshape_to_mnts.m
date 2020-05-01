function [mnts_struct, label_log] = reshape_to_mnts(label_table, GTH, select_powers)
    %TODO select channels - 50ms bin size?
    spectrum_names = fieldnames(GTH);
    spectrum_names = spectrum_names(~ismember(spectrum_names, ...
        {'anat', 'beh', 'zpowspctrm'}));

    %% If select powers is empty, use all powers in GTH
    if isempty(select_powers) ...
            || (~iscell(select_powers) && any(isnan(select_powers)))
        split_powers = spectrum_names;
    else
        split_powers = strsplit(select_powers, ',');
    end

    mnts_struct = struct;
    label_log = struct;
    for pow_i = 1:length(split_powers)
        %% Grab current power and remove whitespace
        selected_pow = strrep(split_powers{pow_i}, ' ', '');

        %% Check if current power selection has multiple powers
        if contains(selected_pow, '+')
            combined_spectrums = strsplit(selected_pow, '+');
            selected_pow = strrep(selected_pow, '+', '_');
        else
            combined_spectrums = {selected_pow};
        end

        %% Cycle through selected powers
        pow_struct = struct;
        for spectrum_i = 1:length(combined_spectrums)
            curr_spectrum = combined_spectrums{spectrum_i};
            %% Verify power spectrum is valid
            if ~ismember(spectrum_names, curr_spectrum)
                warning('%s is not a valid power. Skipping', curr_spectrum);
                continue
            end
            spectrum_channels = GTH.(curr_spectrum).label;
            %% Grab logical indices of selected channels
            channel_i = ismember(spectrum_channels, label_table.sig_channels);
            powspctrm = GTH.(curr_spectrum).powspctrm(:, channel_i, :, :);
            zpowspctrm = GTH.zpowspctrm.(curr_spectrum)(:, channel_i, :, :);
            [tot_trials, ~, tot_pows, tot_bins] = size(powspctrm);
            assert(tot_pows == 1, 'Too many power spectrums. Expected only 1 for reshaping');
            unique_regions = unique(label_table.label);
            for region_i = 1:length(unique_regions)
                region = unique_regions{region_i};
                region_channel_i = ismember(label_table.label, region);
                %% Grab power spectrums
                region_powspctrm = powspctrm(:, region_channel_i, 1, :);
                region_zpowspctrm = zpowspctrm(:, region_channel_i, 1, :);
                [~, tot_region_elecs, ~, ~] = size(region_powspctrm);
                mnts = [];
                z_mnts = [];
                for unit_i = 1:tot_region_elecs
                    unit_response = [];
                    z_response = [];
                    for trial_i = 1:tot_trials
                        %% Power spectrum
                        trial_response = region_powspctrm(trial_i, unit_i, 1, :);
                        trial_response = reshape(trial_response, tot_bins, 1);
                        unit_response = [unit_response; trial_response];
                        %% Z scored power spectrum
                        trial_response = region_zpowspctrm(trial_i, unit_i, 1, :);
                        trial_response = reshape(trial_response, tot_bins, 1);
                        z_response = [z_response; trial_response];
                    end
                    mnts = [mnts, unit_response];
                    z_mnts = [z_mnts, z_response];
                end
                %% Check if region already exists and if it does, append to mnts
                if isfield(pow_struct, region)
                    pow_struct.(region).mnts = [pow_struct.(region).mnts, mnts];
                    pow_struct.(region).z_mnts = [pow_struct.(region).z_mnts, z_mnts];
                else
                    pow_struct.(region).mnts = mnts;
                    pow_struct.(region).z_mnts = z_mnts;
                end
            end
            mnts_struct.(selected_pow) = pow_struct;
            mnts_struct.(selected_pow) = pow_struct;
        end
    end
end