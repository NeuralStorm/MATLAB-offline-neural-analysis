function [mnts_struct, label_log] = reshape_to_mnts(label_table, GTH, ...
    select_powers, select_regions)
    %TODO select channels - 50ms bin size?
    spectrum_names = fieldnames(GTH);
    spectrum_names = spectrum_names(~ismember(spectrum_names, ...
        {'anat', 'beh', 'zpowspctrm'}));
    %% Create label log
    label_log = struct;

    %% If select powers is empty, use all powers in GTH
    if isempty(select_powers) ...
            || (~iscell(select_powers) && any(isnan(select_powers)))
        split_powers = spectrum_names;
    else
        split_powers = strsplit(select_powers, ',');
    end

    %% If select powers is empty, use all powers in GTH
    unique_regions = unique(label_table.label);
    if isempty(select_regions) ...
        || (~iscell(select_regions) && any(isnan(select_regions)))
        split_regions = unique_regions;
    else
        split_regions = strsplit(select_regions, ',');
    end

    mnts_struct = struct;
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
        pow_log = struct;
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
            %% Cycle through selected regions
            for split_region_i = 1:length(split_regions)
                %% Grab current region and remove whitespace
                curr_region = strrep(split_regions{split_region_i}, ' ', '');
                %% Check if current power selection has multiple powers
                if contains(curr_region, '+')
                    combined_regions = strsplit(curr_region, '+');
                    curr_region = strrep(curr_region, '+', '_');
                else
                    combined_regions = {curr_region};
                end

                for region_i = 1:length(combined_regions)
                    region = combined_regions{region_i};
                    %% Verify region is valid
                    if ~ismember(unique_regions, region)
                        warning('%s is not a valid region. Skipping', region);
                        continue
                    end
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
                    %% Check if region already exists and if it does, append to mnts and label log
                    region_chans = label_table(ismember(label_table.label, region), :);
                    if isfield(pow_struct, curr_region)
                        pow_struct.(curr_region).mnts = [pow_struct.(curr_region).mnts, mnts];
                        pow_struct.(curr_region).z_mnts = [pow_struct.(curr_region).z_mnts, z_mnts];
                        pow_log.(curr_region) = [pow_log.(curr_region); region_chans];
                    else
                        pow_struct.(curr_region).mnts = mnts;
                        pow_struct.(curr_region).z_mnts = z_mnts;
                        pow_log.(curr_region) = region_chans;
                    end
                end
            end
            mnts_struct.(selected_pow) = pow_struct;
            label_log.(selected_pow) = pow_log;
            all_events = ['event_1', {GTH.beh.gambles}];
            mnts_struct.(selected_pow).all_events = all_events;
        end
    end
end