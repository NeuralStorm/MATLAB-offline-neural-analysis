function [mnts_struct, label_log] = reshape_to_mnts(label_table, GTH, ...
        select_features)
    unique_bands = fieldnames(GTH);
    unique_bands = unique_bands(~ismember(unique_bands, ...
        {'anat', 'beh', 'zpowspctrm'}));
    unique_regions = unique(label_table.label);
    label_log = struct;

    mnts_struct = struct;
    gambles = find(GTH.beh.gambles);
    safebet = find(GTH.beh.safebet);
    all_events = [
        'event_1', {ones(size(GTH.beh.gambles))};
        'event_2', {gambles}
        'event_3', {safebet}];
    mnts_struct.all_events = all_events;
    if isempty(select_features) ...
            || (~iscell(select_features) && any(isnan(select_features))) ...
            || iscell(select_features) && isempty(select_features{:})
        %% Default: Combine all powers and regions together
        for band_i = 1:numel(unique_bands)
            bandname = unique_bands{band_i};
            tfr_struct = make_tfr_struct(all_events);
            [powspctrm, zpowspctrm] = get_powspctrm(bandname, GTH, label_table);
            for region_i = 1:numel(unique_regions)
                region = unique_regions{region_i};
                region_channel_i = ismember(label_table.label, region);
                %% Grab region power spectrums
                region_powspctrm = powspctrm(:, region_channel_i, 1, :);
                region_zpowspctrm = zpowspctrm(:, region_channel_i, 1, :);
                [mnts, z_mnts] = create_mnts(region_powspctrm, region_zpowspctrm);
                %% Create tfr mean, std, and ste
                for event_i = 1:size(all_events, 1)
                    %% Grab power spectrums
                    event_powspctrm = powspctrm(all_events{event_i, 2}, region_channel_i, 1, :);
                    event_zpowspctrm = zpowspctrm(all_events{event_i, 2}, region_channel_i, 1, :);
                    [event_tfr, event_z_tfr] = create_tfr(event_powspctrm, event_zpowspctrm);
                    %% TFR
                    [tfr_struct.(['event_', num2str(event_i)]).avg_tfr, ...
                        tfr_struct.(['event_', num2str(event_i)]).std_tfr, ...
                        tfr_struct.(['event_', num2str(event_i)]).ste_tfr] = ...
                        get_tfr_stats(event_tfr);
                    %% Z tfr
                    [tfr_struct.(['event_', num2str(event_i)]).avg_z_tfr, ...
                        tfr_struct.(['event_', num2str(event_i)]).std_z_tfr, ...
                        tfr_struct.(['event_', num2str(event_i)]).ste_z_tfr] = ...
                        get_tfr_stats(event_z_tfr);
                end
                feature = [bandname, '_', region];
                mnts_struct.(feature).mnts = mnts;
                mnts_struct.(feature).z_mnts = z_mnts;
                mnts_struct.(feature).tfr.(bandname) = tfr_struct;
                region_chans = label_table(ismember(label_table.label, region), :);
                label_log.(feature) = region_chans;
            end
        end
    else
        %% Case: Specified feature space with combos of powers + regions
        select_features = strrep(select_features, ' ', '');
        split_features = strsplit(select_features, ';');
        for feature_i = 1:numel(split_features)
            %% Split into separate feature spaces based on ';'
            feature = split_features{feature_i};
            sub_feature = strsplit(feature, ',');
            %% set feature variables
            feature = replace(feature, {':', '+', ','}, '_');
            label_log.(feature) = [];
            mnts_struct.(feature).mnts = [];
            mnts_struct.(feature).z_mnts = [];
            for sub_feature_i = 1:numel(sub_feature)
                %% Split into powers and regions
                pow_regs = sub_feature{sub_feature_i};
                split_pow_reg = strsplit(pow_regs, ':');
                pows = split_pow_reg{1};
                split_powers = strsplit(pows, '+');
                regs = split_pow_reg{2};
                split_regions = strsplit(regs, '+');
                for band_i = 1:numel(split_powers)
                    %% iterate through powers
                    bandname = split_powers{band_i};
                    [powspctrm, zpowspctrm] = get_powspctrm(bandname, GTH, label_table);
                    tfr_struct = make_tfr_struct(all_events);
                    for region_i = 1:numel(split_regions)
                        %% Iterate through regions
                        region = split_regions{region_i};
                        region_channel_i = ismember(label_table.label, region);
                        %% Grab power spectrums
                        region_powspctrm = powspctrm(:, region_channel_i, 1, :);
                        region_zpowspctrm = zpowspctrm(:, region_channel_i, 1, :);

                        %% Reshape into MNTS and store in mnts_struct for feature
                        [region_mnts, region_z_mnts] = create_mnts(region_powspctrm, region_zpowspctrm);
                        mnts_struct.(feature).mnts = [mnts_struct.(feature).mnts, region_mnts];
                        mnts_struct.(feature).z_mnts = [mnts_struct.(feature).z_mnts, region_z_mnts];

                        for event_i = 1:size(all_events, 1)
                            %% Grab power spectrums
                            event_powspctrm = powspctrm(all_events{event_i, 2}, region_channel_i, 1, :);
                            event_zpowspctrm = zpowspctrm(all_events{event_i, 2}, region_channel_i, 1, :);
                            [event_tfr, event_z_tfr] = create_tfr(event_powspctrm, event_zpowspctrm);
                            tfr_struct.(['event_', num2str(event_i)]).avg_tfr = [tfr_struct.(['event_', num2str(event_i)]).avg_tfr; event_tfr];
                            tfr_struct.(['event_', num2str(event_i)]).avg_z_tfr = [tfr_struct.(['event_', num2str(event_i)]).avg_z_tfr; event_z_tfr];
                        end

                        %% label log
                        region_chans = label_table(ismember(label_table.label, region), :);
                        label_log.(feature) = [label_log.(feature); region_chans];
                        [~, ind] = unique(label_log.(feature), 'rows');
                        label_log.(feature) = label_log.(feature)(ind, :);
                    end
                    for event_i = 1:size(all_events, 1)
                        %% Find mean, std, and ste of tfr and z tfr
                        [tfr_struct.(['event_', num2str(event_i)]).avg_tfr, ...
                            tfr_struct.(['event_', num2str(event_i)]).std_tfr, ...
                            tfr_struct.(['event_', num2str(event_i)]).ste_tfr] = ...
                            get_tfr_stats(tfr_struct.(['event_', num2str(event_i)]).avg_tfr);
                        %% Z tfr
                        [tfr_struct.(['event_', num2str(event_i)]).avg_z_tfr, ...
                            tfr_struct.(['event_', num2str(event_i)]).std_z_tfr, ...
                            tfr_struct.(['event_', num2str(event_i)]).ste_z_tfr] = ...
                            get_tfr_stats(tfr_struct.(['event_', num2str(event_i)]).avg_z_tfr);
                    end
                    mnts_struct.(feature).tfr.(bandname) = tfr_struct;
                end
            end
        end
    end
end

function [powspctrm, zpowspctrm] = get_powspctrm(bandname, GTH, label_table)
    spectrum_channels = GTH.(bandname).label;
    %% Grab logical indices of selected channels
    channel_i = ismember(spectrum_channels, label_table.sig_channels);
    powspctrm = GTH.(bandname).powspctrm(:, channel_i, :, :);
    if ~isfield(GTH, 'zpowspctrm')
        zpowspctrm = zscore(GTH.(bandname).powspctrm,0,4);
    else
        zpowspctrm = GTH.zpowspctrm.(bandname)(:, channel_i, :, :);
    end
end

function [mnts, z_mnts] = create_mnts(powspctrm, zpowspctrm)
    [tot_trials, tot_elecs, ~, tot_bins] = size(powspctrm);
    mnts = [];
    z_mnts = [];
    for unit_i = 1:tot_elecs
        unit_response = [];
        z_response = [];
        for trial_i = 1:tot_trials
            %% Power spectrum
            trial_response = powspctrm(trial_i, unit_i, 1, :);
            trial_response = reshape(trial_response, tot_bins, 1);
            unit_response = [unit_response; trial_response];
            %% Z scored power spectrum
            trial_response = zpowspctrm(trial_i, unit_i, 1, :);
            trial_response = reshape(trial_response, tot_bins, 1);
            z_response = [z_response; trial_response];
        end
        mnts = [mnts, unit_response];
        z_mnts = [z_mnts, z_response];
    end
end

function [tfr_struct] = make_tfr_struct(all_events)
    for event_i = 1:size(all_events, 1)
        tfr_struct.(['event_', num2str(event_i)]).avg_tfr = [];
        tfr_struct.(['event_', num2str(event_i)]).avg_z_tfr = [];
    end
end

function [tfr, z_tfr] = create_tfr(powspctrm, zpowspctrm)
    %TODO add events
    [tot_trials, tot_elecs, ~, tot_bins] = size(powspctrm);
    tfr = [];
    z_tfr = [];
    for unit_i = 1:tot_elecs
        unit_response = [];
        z_response = [];
        for trial_i = 1:tot_trials
            %% Power spectrum
            trial_response = powspctrm(trial_i, unit_i, 1, :);
            trial_response = reshape(trial_response, 1, tot_bins);
            unit_response = [unit_response; trial_response];
            %% Z scored power spectrum
            trial_response = zpowspctrm(trial_i, unit_i, 1, :);
            trial_response = reshape(trial_response, 1, tot_bins);
            z_response = [z_response; trial_response];
        end
        tfr = [tfr; unit_response];
        z_tfr = [z_tfr; z_response];
    end
end

function [avg_tfr, std_tfr, ste_tfr] = get_tfr_stats(tfr)
    avg_tfr = mean(tfr);
    std_tfr = std(tfr);
    ste_tfr = std_tfr ./ size(tfr, 1);
end