function [sep_res] = norm_sep_peaks(sep_res)
    unique_ch_groups = unique([sep_res.chan_group]);
    unique_events = unique([sep_res.event]);
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        for event_i = 1:numel(unique_events)
            event = unique_events{event_i};
            chan_i = ismember([sep_res.chan_group], ch_group) & ...
                        ismember([sep_res.event], event);
            % Normalized neg and pos peaks to the largest peak within region & event
            %% Negative peak norm
            if ~isempty([sep_res(chan_i).neg_peak1])
                sep_res = norm_peaks(sep_res, chan_i, 'neg_peak1', 'min');
            end
            if ~isempty([sep_res(chan_i).neg_peak2])
                sep_res = norm_peaks(sep_res, chan_i, 'neg_peak2', 'min');
            end
            if ~isempty([sep_res(chan_i).neg_peak3])
                sep_res = norm_peaks(sep_res, chan_i, 'neg_peak3', 'min');
            end
            %% Positive peak norm
            if ~isempty([sep_res(chan_i).pos_peak1])
                sep_res = norm_peaks(sep_res, chan_i, 'pos_peak1', 'max');
            end
            if ~isempty([sep_res(chan_i).pos_peak2])
                sep_res = norm_peaks(sep_res, chan_i, 'pos_peak2', 'max');
            end
            if ~isempty([sep_res(chan_i).pos_peak3])
                sep_res = norm_peaks(sep_res, chan_i, 'pos_peak3', 'max');
            end
        end
    end
end

function [sep_res] = norm_peaks(sep_res, chan_i, field_name, peak_type)
    if strcmpi(peak_type, 'max')
        max_peak = max(cell2mat({sep_res(chan_i).(field_name)}));
        norm_res = num2cell([sep_res(chan_i).(field_name)] / max_peak);
        [sep_res(chan_i).(['norm_', field_name])] = norm_res{1,:};
    elseif strcmpi(peak_type, 'min')
        min_peak = min(cell2mat({sep_res(chan_i).(field_name)}));
        norm_res = num2cell([sep_res(chan_i).(field_name)] / min_peak);
        [sep_res(chan_i).(['norm_', field_name])] = norm_res{1,:};
    else
        error('Invalid peak_type %s, try max or min instead', peak_type);
    end
end