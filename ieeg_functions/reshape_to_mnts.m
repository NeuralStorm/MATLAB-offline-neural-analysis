function [mnts_struct, label_log] = reshape_to_mnts(label_table, GTH, ...
        select_features, use_z_score)
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
    % GTH: Struct with following fields:
    %      anat: struct with fields
    %                channels: cell vector with names of channels
    %                ROIs: cell vector with regions channels belong to
    %      beh: struct with fields for event types
    %           event_type: logical array with length of tot_trials where 1 means the event_type occured
    %      bandname: struct with fields:
    %                    region: struct with fields
    %                            label: cell vector with electrode names
    %                            dimord: description of 4d dimensions
    %                            freq: frequency of band
    %                            time: time vector stepped by bin size
    %                            powspctrm: 4D matrix with dimension trials x channels x band x time
    %                            cfg: struct log of how data was processed to create powspctrm
    %      zpowspctrm: struct with fields
    %                      bandname: 4D matrix with dimension trials x channels x band x time
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

    unique_bands = fieldnames(GTH);
    unique_bands = unique_bands(~ismember(unique_bands, ...
        {'anat', 'beh', 'fsample'}));
    unique_regions = unique(GTH.anat.ROIs);
    label_log = struct;

    mnts_struct = struct;
    all_events = [];
    unique_events = fieldnames(GTH.beh);
    for event_i = 1:numel(unique_events)
        event = unique_events{event_i};
        if event_i == 1
            all_events = [
                all_events;
                'all', {ones(size(GTH.beh.(event)))}
            ];
        end
        all_events = [all_events; {event, find(GTH.beh.(event))}];
    end

    mnts_struct.all_events = all_events;
    if isempty(select_features) ...
            || (~iscell(select_features) && any(isnan(select_features))) ...
            || iscell(select_features) && isempty(select_features{:})
        %% Default: Combine all powers and regions together
        for band_i = 1:numel(unique_bands)
            bandname = unique_bands{band_i};
            tfr_struct = make_tfr_struct(all_events);
            powspctrm = get_powspctrm(GTH.(bandname), use_z_score);
            for region_i = 1:numel(unique_regions)
                region = unique_regions{region_i};
                region_channel_i = ismember(GTH.anat.ROIs, region);
                %% Grab region power spectrums
                region_powspctrm = powspctrm(:, region_channel_i, :);
                mnts = create_mnts(region_powspctrm);
                %% Create tfr mean, std, and ste
                for event_i = 1:size(all_events, 1)
                    event = all_events{event_i, 1};
                    %% Grab power spectrums
                    event_powspctrm = powspctrm(all_events{event_i, 2}, region_channel_i, :);
                    event_tfr = create_tfr(event_powspctrm);
                    %% TFR
                    [tfr_struct.(event).(['avg_', z_type, 'tfr']), ...
                        tfr_struct.(event).(['std_', z_type, 'tfr']), ...
                        tfr_struct.(event).(['ste_', z_type, 'tfr'])] = ...
                        get_tfr_stats(event_tfr);
                end
                feature = [bandname, '_', region];
                mnts_struct.(feature).([z_type, 'mnts']) = mnts;
                mnts_struct.(feature).tfr.(bandname) = tfr_struct;
                region_chans = label_table(ismember(label_table.label, region), :);
                mnts_struct.(feature).elec_order = region_chans.sig_channels;
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
                    powspctrm = get_powspctrm(GTH.(bandname));
                    tfr_struct = make_tfr_struct(all_events);
                    for region_i = 1:numel(split_regions)
                        %% Iterate through regions
                        region = split_regions{region_i};
                        region_channel_i = ismember(GTH.anat.ROIs, region);
                        %% Grab power spectrums
                        region_powspctrm = powspctrm(:, region_channel_i, :);

                        %% Reshape into MNTS and store in mnts_struct for feature
                        region_mnts = create_mnts(region_powspctrm);
                        mnts_struct.(feature).([z_type, 'mnts']) = [mnts_struct.(feature).([z_type, 'mnts']), region_mnts];

                        for event_i = 1:size(all_events, 1)
                            event = all_events{event_i, 1};
                            %% Grab power spectrums
                            event_powspctrm = powspctrm(all_events{event_i, 2}, region_channel_i, :);
                            event_tfr = create_tfr(event_powspctrm);
                            tfr_struct.(event).(['avg_', z_type, 'tfr']) = [tfr_struct.(event).(['avg_', z_type, 'tfr']); event_tfr];
                        end

                        %% label log
                        region_chans = label_table(ismember(label_table.label, region), :);
                        mnts_struct.(feature).elec_order = [mnts_struct.(feature).elec_order; region_chans.sig_channels];
                        label_log.(feature) = [label_log.(feature); region_chans];
                        [~, ind] = unique(label_log.(feature), 'rows');
                        label_log.(feature) = label_log.(feature)(ind, :);
                    end
                    for event_i = 1:size(all_events, 1)
                        event = all_events{event_i, 1};
                        %% Find mean, std, and ste of tfr
                        [tfr_struct.(event).(['avg_', z_type, 'tfr']), ...
                            tfr_struct.(event).(['std_', z_type, 'tfr']), ...
                            tfr_struct.(event).(['ste_', z_type, 'tfr'])] = ...
                            get_tfr_stats(tfr_struct.(event).avg_tfr);
                    end
                    mnts_struct.(feature).tfr.(bandname) = tfr_struct;
                end
            end
        end
    end
end

function [powspctrm] = get_powspctrm(tfr_struct, use_z_score)
    powspctrm = tfr_struct.powspctrm;
    if use_z_score
        powspctrm = zscore(powspctrm,0,3);
    end
    % spectrum_channels = GTH.(bandname).label;
    % %%TODO Grab logical indices of selected channels
    % channel_i = ismember(spectrum_channels, label_table.sig_channels);
    % powspctrm = GTH.(bandname).powspctrm(:, channel_i, :, :);
    % if ~isfield(GTH, 'zpowspctrm')
    %     zpowspctrm = zscore(GTH.(bandname).powspctrm,0,4);
    % else
    %     zpowspctrm = GTH.zpowspctrm.(bandname)(:, channel_i, :, :);
    % end
end

function [mnts] = create_mnts(powspctrm)
    [tot_trials, tot_elecs, tot_bins] = size(powspctrm);
    mnts = [];
    for unit_i = 1:tot_elecs
        unit_response = [];
        for trial_i = 1:tot_trials
            %% Power spectrum
            trial_response = powspctrm(trial_i, unit_i, :);
            trial_response = reshape(trial_response, tot_bins, 1);
            unit_response = [unit_response; trial_response];
        end
        mnts = [mnts, unit_response];
    end
end

function [tfr_struct] = make_tfr_struct(all_events)
    for event_i = 1:size(all_events, 1)
        event = all_events{event_i, 1};
        tfr_struct.(event).avg_tfr = [];
        tfr_struct.(event).avg_z_tfr = [];
    end
end

function [tfr] = create_tfr(powspctrm)
    %TODO add events
    [tot_trials, tot_elecs, tot_bins] = size(powspctrm);
    tfr = [];
    for unit_i = 1:tot_elecs
        unit_response = [];
        z_response = [];
        for trial_i = 1:tot_trials
            %% Power spectrum
            trial_response = powspctrm(trial_i, unit_i, :);
            trial_response = reshape(trial_response, 1, tot_bins);
            unit_response = [unit_response; trial_response];
        end
        tfr = [tfr; unit_response];
    end
end

function [avg_tfr, std_tfr, ste_tfr] = get_tfr_stats(tfr)
    avg_tfr = mean(tfr);
    std_tfr = std(tfr);
    ste_tfr = std_tfr ./ size(tfr, 1);
end