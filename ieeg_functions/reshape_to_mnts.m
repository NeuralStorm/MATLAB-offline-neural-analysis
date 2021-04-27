function [label_log, mnts_struct, event_info, band_shifts] = reshape_to_mnts(label_table, power_struct, ...
        select_features, include_events, use_z_score, smooth_power, smoothing_direction, span, downsample_pow, ...
        downsample_rate, slice_time, bin_size, window_start, slice_start, slice_end)

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
    % label_log: table with columns
    %                'sig_channels': String with name of channel
    %                'selected_channels': Boolean if channel is used
    %                'user_channels': String with user defined mapping
    %                'label': String: associated region or grouping of electrodes
    %                'label_id': Int: unique id used for labels
    %                'recording_session': Int: File recording session number that above applies to
    %                'recording_notes': String with user defined notes for channel
    % mnts_struct: struct w/ fields for each feature set matching the feature set in label_log
    %                 feature_name: struct with fields:
    %                               Note: Order of observations are assumed to be group by event types for later separation
    %                               mnts/z_mnts: Numeric input array for PCA (may be z-scored depending on use_z_score)
    %                                     Columns: Features (typically electrodes)
    %                                     Rows: Observations (typically trials * time value)
    % event_info: table w/ following columns:
    %             event_labels: column containing event name for index and time in relative response
    %             event_indices: index of event label in relative response
    %             event_ts: timestamp for event

    if slice_time
        bin_start = round((slice_start - window_start) / bin_size) + 1;
        bin_end = round((slice_end - slice_start) / bin_size) + bin_start - 1;
        slice_i = bin_start:bin_end;
    end

    unique_bands = fieldnames(power_struct);
    unique_bands = unique_bands(~ismember(unique_bands, ...
        {'anat', 'beh', 'fsample', 'time'}));
    unique_regions = unique(power_struct.anat.ROIs);
    label_log = table();
    mnts_struct = struct;
    band_shifts = struct;

    %% Create event table with the first event being all trials
    unique_events = fieldnames(power_struct.beh);
    event_info = table();
    for event_i = 1:numel(unique_events)
        % Add events to event table
        event = unique_events{event_i};
        if ~contains(include_events, event)
            continue
        end
        tot_trials = numel(find(power_struct.beh.(event)));
        event_labels = cellstr(repmat(event, [tot_trials, 1]));
        event_indices = find(power_struct.beh.(event));
        event_ts = NaN(tot_trials, 1);
        event_table = table(event_labels, event_indices, event_ts);
        event_info = [event_info; event_table];
    end
    %% sort event_info chronologically since above method does not
    event_info = sortrows(event_info, 'event_indices');
    if isempty(select_features) ...
            || (~iscell(select_features) && any(isnan(select_features))) ...
            || iscell(select_features) && isempty(select_features{:})
        %% Default: Combine all powers and regions together
        for band_i = 1:numel(unique_bands)
            bandname = unique_bands{band_i};
            for region_i = 1:numel(unique_regions)
                region = unique_regions{region_i};
                region_channel_i = ismember(power_struct.anat.ROIs, region);
                %% Grab region power spectrums
                region_powspctrm = get_powspctrm(power_struct.(bandname), ...
                    region_channel_i, use_z_score, smooth_power, smoothing_direction, ...
                    span, downsample_pow, downsample_rate);
                if slice_time
                    region_powspctrm = region_powspctrm(:, :, slice_i);
                end
                mnts = create_mnts(region_powspctrm);
                feature = [bandname, '_', region];
                mnts_struct.(feature).mnts = mnts;
                chan_list = append_feature(power_struct.anat.channels(region_channel_i), feature);
                mnts_struct.(feature).label_order = chan_list;
                mnts_struct.(feature).chan_order = chan_list;
                band_shifts.(feature) = [];
                label_log = append_labels(feature, region, label_table, label_log);
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
            mnts_struct.(feature).mnts = [];
            mnts_struct.(feature).chan_order = [];
            mnts_struct.(feature).label_order = [];
            band_shifts.(feature) = [];
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
                    for region_i = 1:numel(split_regions)
                        %% Iterate through regions
                        region = split_regions{region_i};
                        region_channel_i = ismember(power_struct.anat.ROIs, region);
                        %% Grab power spectrums
                        region_powspctrm = get_powspctrm(power_struct.(bandname), ...
                            region_channel_i, use_z_score, smooth_power, smoothing_direction, ...
                            span, downsample_pow, downsample_rate);

                        if slice_time
                            region_powspctrm = region_powspctrm(:, :, slice_i);
                        end
                        %% Reshape into MNTS and store in mnts_struct for feature
                        region_mnts = create_mnts(region_powspctrm);
                        mnts_struct.(feature).mnts = [mnts_struct.(feature).mnts, region_mnts];

                        %% label log
                        chan_list = append_feature(power_struct.anat.channels(region_channel_i), feature);
                        mnts_struct.(feature).label_order = [mnts_struct.(feature).label_order; chan_list];
                        mnts_struct.(feature).chan_order = [mnts_struct.(feature).chan_order; chan_list];
                        label_log = append_labels(feature, region, label_table, label_log);
                    end
                    band_shifts.(feature) = [band_shifts.(feature); {numel(mnts_struct.(feature).chan_order)}];
                end
            end
            if numel(band_shifts.(feature)) <= 1
                %% Only 1 or 0 powers in feature
                band_shifts.(feature) = [];
            else
                %% Combine power shifts with locations
                band_shifts.(feature) = [split_powers', band_shifts.(feature)];
            end
        end
    end
end

function [results] = get_powspctrm(pow_struct, region_channel_i, use_z_score, ...
        smooth_power, smoothing_direction, span, downsample_pow, downsample_rate)
    powspctrm = pow_struct.powspctrm;
    region_powspctrm = powspctrm(:, region_channel_i, :);
    %% Iterate through trials and smooth each trials
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
                    trial_response = smooth_down(region_powspctrm(trial_i, unit_i, :), span, downsample_rate, smoothing_direction);
                else
                    trial_response = region_powspctrm(trial_i, unit_i, :);
                end
                results(trial_i, unit_i, :) = trial_response;
            end
        end
    else
        results = region_powspctrm;
    end
    if use_z_score
        results = zscore(results,0,3);
    end
end

function [mnts] = create_mnts(powspctrm)
    [tot_trials, tot_chans, tot_t] = size(powspctrm);
    mnts = nan((tot_t * tot_trials), tot_chans);
    for chan_i = 1:tot_chans
        trial_s = 1;
        trial_e = tot_t;
        for trial_i = 1:tot_trials
            %% Power spectrum
            mnts(trial_s:trial_e, chan_i) = squeeze(powspctrm(trial_i, chan_i, :));
            %% Update index counters
            trial_s = trial_s + tot_t;
            trial_e = trial_e + tot_t;
        end
    end
end

function [label_log] = append_labels(feature, region, label_table, label_log)
    region_table = label_table(ismember(label_table.label, region), :);
    region_table.label = repmat({feature}, [height(region_table), 1]);
    label_log = [label_log; region_table];
end

function [chan_order] = append_feature(chan_order, feature)
    for chan_i = 1:numel(chan_order)
        chan = chan_order{chan_i};
        new_chan = [feature, '_', chan];
        chan_order{chan_i} = new_chan;
    end
end