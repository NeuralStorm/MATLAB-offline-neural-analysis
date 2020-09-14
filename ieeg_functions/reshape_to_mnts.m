function [mnts_struct, label_log] = reshape_to_mnts(label_table, power_struct, ...
        select_features, use_z_score, smooth_power, span, downsample_pow, downsample_rate)
    %% Purpose: Reshape output from filtering process
    %% Input
    % label_table: table with information of current recording
    %              field: table with columns
    %                     'sig_channels': String with name of channel
    %                     'selected_channels': Boolean if channel is used
    %                     'user_channels': String with user defined mapping
    %                     'label': String: associated region or grouping of electrodes
    %                     'label_id': Int: unique id used for labels
    %                     'recording_session': Int: File recording session number that above applies to
    %                     'recording_notes': String with user defined notes for channel
    % power_struct: Struct with required fields (not exlusive list, but list of fields needed for pipeline):
    %      anat: struct with fields
    %                channels: cell vector with names of channels
    %                ROIs: cell vector with regions channels belong to
    %      beh: struct with fields for event types
    %           event_type: logical array with length of tot_trials where 1 means the event_type occured
    %      bandname: struct with fields:
    %                        dimord: description of 4d dimensions
    %                        powspctrm: 3D matrix with dimension trials x channels x time
    % select_features: string that determines how to combine powers and regions to make features
    %                  format layout: power:region, power+power:region+region;power:region, etc
    %% Output:
    % mnts_struct: struct w/ fields for each feature set matching the feature set in label_log
    %                 'all_events': Nx2 cell array where N is the number of events
    %                               Column 1: event label (ex: event_1)
    %                               Column 2: Numeric array with timestamps for events
    %                 feature_name: struct with fields:
    %                               Note: Order of observations are assumed to be group by event types for later separation
    %                               mnts: Numeric input array for PCA
    %                                     Columns: Features (typically electrodes)
    %                                     Rows: Observations (typically trials * time value)
    %                               z_mnts: Numeric input z scored array for PCA
    %                               tfr: struct with fields for each power
    %                                    bandname: struct with fields for each event type
    %                                              event: struct with fields with tfr & z tfr avg, std, ste
    %                                                     fieldnames: avg_tfr, avg_z_tfr, std_tfr, std_z_tfr, ste_tfr, & ste_z_tfr
    % label_log: struct w/ fields for each feature set
    %            field: table with columns
    %                   'sig_channels': String with name of channel
    %                   'selected_channels': Boolean if channel is used
    %                   'user_channels': String with user defined mapping
    %                   'label': String: associated region or grouping of electrodes
    %                   'label_id': Int: unique id used for labels
    %                   'recording_session': Int: File recording session number that above applies to
    %                   'recording_notes': String with user defined notes for channel

    if use_z_score
        z_type = 'z_';
    else
        '';
    end

    unique_bands = fieldnames(power_struct);
    unique_bands = unique_bands(~ismember(unique_bands, ...
        {'anat', 'beh', 'fsample', 'time'}));
    unique_regions = unique(power_struct.anat.ROIs);
    label_log = struct;

    mnts_struct = struct;
    all_events = [];
    unique_events = fieldnames(power_struct.beh);
    for event_i = 1:numel(unique_events)
        event = unique_events{event_i};
        if event_i == 1
            all_events = [
                all_events;
                'all', {[1:1:numel(power_struct.beh.(event))]'};
            ];
        end
        all_events = [all_events; {event, find(power_struct.beh.(event))}];
    end

    mnts_struct.all_events = all_events;
    if isempty(select_features) ...
            || (~iscell(select_features) && any(isnan(select_features))) ...
            || iscell(select_features) && isempty(select_features{:})
        %% Default: Combine all powers and regions together
        for band_i = 1:numel(unique_bands)
            bandname = unique_bands{band_i};
            tfr_struct = make_tfr_struct(all_events, z_type);
            for region_i = 1:numel(unique_regions)
                region = unique_regions{region_i};
                region_channel_i = ismember(power_struct.anat.ROIs, region);
                %% Grab region power spectrums
                region_powspctrm = get_powspctrm(power_struct.(bandname), ...
                    region_channel_i, use_z_score, smooth_power, span, ...
                    downsample_pow, downsample_rate);
                mnts = create_mnts(region_powspctrm);
                %% Create tfr mean, std, and ste
                for event_i = 1:size(all_events, 1)
                    event = all_events{event_i, 1};
                    if contains(event, 'all')
                        %% Check to make sure all events has same length as beh all events
                        [tot_trials, ~, ~] = size(region_powspctrm);
                        event_trials = numel(all_events{event_i, 2});
                        assert(tot_trials == event_trials);
                    end
                    %% Grab power spectrums
                    event_powspctrm = region_powspctrm(all_events{event_i, 2}, :, :);
                    %% TFR
                    [tfr_struct.(event).(['avg_', z_type, 'tfr']), ...
                        tfr_struct.(event).(['std_', z_type, 'tfr']), ...
                        tfr_struct.(event).(['ste_', z_type, 'tfr'])] = ...
                        get_tfr_stats(event_powspctrm);
                end
                feature = [bandname, '_', region];
                mnts_struct.(feature).([z_type, 'mnts']) = mnts;
                mnts_struct.(feature).tfr.(bandname) = tfr_struct;
                region_chans = label_table(ismember(label_table.label, region), :);
                mnts_struct.(feature).elec_order = power_struct.anat.channels(region_channel_i);
                mnts_struct.(feature).band_shift = [];
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
            mnts_struct.(feature).([z_type, 'mnts']) = [];
            mnts_struct.(feature).elec_order = [];
            mnts_struct.(feature).band_shift = [];
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
                    tfr_struct = make_tfr_struct(all_events, z_type);
                    for region_i = 1:numel(split_regions)
                        %% Iterate through regions
                        region = split_regions{region_i};
                        region_channel_i = ismember(power_struct.anat.ROIs, region);
                        %% Grab power spectrums
                        region_powspctrm = get_powspctrm(power_struct.(bandname), ...
                            region_channel_i, use_z_score, smooth_power, span, ...
                            downsample_pow, downsample_rate);

                        %% Reshape into MNTS and store in mnts_struct for feature
                        region_mnts = create_mnts(region_powspctrm);
                        mnts_struct.(feature).([z_type, 'mnts']) = [mnts_struct.(feature).([z_type, 'mnts']), region_mnts];

                        for event_i = 1:size(all_events, 1)
                            event = all_events{event_i, 1};
                            %% Grab power spectrums
                            event_powspctrm = region_powspctrm(all_events{event_i, 2}, :, :);
                            tfr_struct.(event).(['avg_', z_type, 'tfr']) = cat(2, tfr_struct.(event).(['avg_', z_type, 'tfr']), event_powspctrm);
                        end

                        %% label log
                        region_chans = label_table(ismember(label_table.label, region), :);
                        mnts_struct.(feature).elec_order = [mnts_struct.(feature).elec_order; power_struct.anat.channels(region_channel_i)];
                        label_log.(feature) = [label_log.(feature); region_chans];
                    end
                    for event_i = 1:size(all_events, 1)
                        event = all_events{event_i, 1};
                        %% Find mean, std, and ste of tfr
                        [tfr_struct.(event).(['avg_', z_type, 'tfr']), ...
                            tfr_struct.(event).(['std_', z_type, 'tfr']), ...
                            tfr_struct.(event).(['ste_', z_type, 'tfr'])] = ...
                            get_tfr_stats(tfr_struct.(event).(['avg_', z_type, 'tfr']));
                    end
                    mnts_struct.(feature).band_shift = [mnts_struct.(feature).band_shift; {numel(mnts_struct.(feature).elec_order)}];
                    mnts_struct.(feature).tfr.(bandname) = tfr_struct;
                end
            end
            if numel(mnts_struct.(feature).band_shift) <= 1
                %% Only 1 or 0 powers in feature
                mnts_struct.(feature).band_shift = [];
            else
                %% Combine power shifts with locations
                mnts_struct.(feature).band_shift = [split_powers', mnts_struct.(feature).band_shift];
            end
        end
    end
end

function [results] = get_powspctrm(pow_struct, region_channel_i, use_z_score, ...
        smooth_power, span, downsample_pow, downsample_rate)
    powspctrm = pow_struct.powspctrm;
    region_powspctrm = powspctrm(:, region_channel_i, :);
    if use_z_score
        region_powspctrm = zscore(region_powspctrm,0,3);
    end
    %% Iterate through trials and smooth each trials
    %TODO replace powspctrm with region_powspctrm
    if downsample_pow || smooth_power
        [tot_trials, tot_chans, tot_samples] = size(region_powspctrm);
        if downsample_pow
            down_i = 1:downsample_rate:tot_samples;
            results = nan(tot_trials, tot_chans, (numel(down_i) - 1));
        else
            results = nan(tot_trials, tot_chans, tot_samples);
        end
        parfor unit_i = 1:tot_chans
            for trial_i = 1:tot_trials
                %% smooth
                if smooth_power
                    trial_response = smooth(region_powspctrm(trial_i, unit_i, :), span);
                else
                    trial_response = region_powspctrm(trial_i, unit_i, :);
                end
                %% downsample
                if downsample_pow
                    downsample_trial = [];
                    for i = 1:numel(down_i) - 1
                        start_i = down_i(i);
                        end_i = down_i(i + 1);
                        sample_avg = mean(trial_response(start_i:end_i));
                        downsample_trial = [downsample_trial, sample_avg];
                    end
                    results(trial_i, unit_i, :) = downsample_trial;
                else
                    % Case: smoothing only
                    results(trial_i, unit_i, :) = trial_response;
                end
            end
        end
    else
        results = region_powspctrm;
    end
end

function [mnts] = create_mnts(powspctrm)
    [tot_trials, tot_chans, ~] = size(powspctrm);
    mnts = [];
    for unit_i = 1:tot_chans
        unit_response = [];
        for trial_i = 1:tot_trials
            %% Power spectrum
            trial_response = squeeze(powspctrm(trial_i, unit_i, :));
            unit_response = [unit_response; trial_response];
        end
        mnts = [mnts, unit_response];
    end
end

function [tfr_struct] = make_tfr_struct(all_events, z_type)
    tfr_struct = struct;
    for event_i = 1:size(all_events, 1)
        event = all_events{event_i, 1};
        tfr_struct.(event).(['avg_', z_type, 'tfr']) = [];
    end
end

function [avg_tfr, std_tfr, ste_tfr] = get_tfr_stats(powspctrm)
    [tot_trials, ~, ~] = size(powspctrm);
    avg_tfr = squeeze(mean(powspctrm, [1,2]));
    std_tfr = squeeze(std(powspctrm, 0, [1,2]));
    ste_tfr = std_tfr ./ sqrt(tot_trials);
end