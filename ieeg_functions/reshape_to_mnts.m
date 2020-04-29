function [mnts_struct, label_log] = reshape_to_mnts(label_table, GTH)
    %TODO select channels - 50ms bin size?

    % if use_zscore
    %     spectrum_names = fieldnames(GTH.zpowspctrm);
    % else
    % end
    spectrum_names = fieldnames(GTH);
    spectrum_names = spectrum_names(~ismember(spectrum_names, ...
        {'anat', 'beh', 'zpowspctrm'}));

    mnts_struct = struct;
    label_log = struct;
    for spectrum_i = 1:length(spectrum_names)
        curr_spectrum = spectrum_names{spectrum_i};
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
            region_powspctrm = powspctrm(:, region_channel_i, 1, :);
            region_zpowspctrm = zpowspctrm(:, region_channel_i, 1, :);
            [~, tot_region_elecs, ~, ~] = size(region_powspctrm);
            mnts = [];
            z_mnts = [];
            for unit_i = 1:tot_region_elecs
                unit_response = [];
                z_response = [];
                for trial_i = 1:tot_trials
                    trial_response = region_powspctrm(trial_i, unit_i, 1, :);
                    trial_response = reshape(trial_response, tot_bins, 1);
                    unit_response = [unit_response; trial_response];
                    %% Z score
                    trial_response = region_zpowspctrm(trial_i, unit_i, 1, :);
                    trial_response = reshape(trial_response, tot_bins, 1);
                    z_response = [z_response; trial_response];
                end
                mnts = [mnts, unit_response];
                z_mnts = [z_mnts, z_response];
            end
            mnts_struct.(curr_spectrum).(region).mnts = mnts;
            mnts_struct.(curr_spectrum).(region).z_mnts = z_mnts;

            %% Add to label log
            label_log.(region) = label_table(ismember(label_table.label, region), :);
        end
    end
end