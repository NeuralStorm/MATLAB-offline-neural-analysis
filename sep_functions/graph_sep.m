function [] = graph_sep(save_path, sep_struct, filename_meta, chan_group_log, ...
        sub_rows, sub_cols)
    %% Set x axis (time)
    time = linspace(sep_struct(1).sep_window(1), sep_struct(1).sep_window(2), ...
        length(sep_struct(1).sep_sliced_data));
    unique_ch_groups = unique([sep_struct.chan_group]);
    unique_events = unique([sep_struct.event]);
    for ch_group_i = 1:length(unique_ch_groups)
        ch_group = unique_ch_groups{ch_group_i};
        region_table = chan_group_log(strcmpi(chan_group_log.chan_group, ch_group), :);
        region_table = sortrows(region_table, 'user_channels');
        for event_i = 1:numel(unique_events)
            event = unique_events{event_i};
            %% extracts data form chan_group and event
            a = sep_struct(strcmpi([sep_struct.chan_group], ch_group) ...
                & strcmpi([sep_struct.event], event));

            %% Get global y limits
            global_sep = [a.sep_sliced_data];
            y_max = max(global_sep);
            y_min = min(global_sep);
            % Add buffer so that y limits don't appear cut off in plots
            y_max = y_max + (y_max * .002) + eps;
            y_min = y_min + (y_min *.002) + eps;

            %% Plot each channel in scroll subplot
            figure('visible', 'off');
            sgtitle([filename_meta.animal_id, ' ', ch_group]);
            for chan_i = 1:height(region_table)
                chan = region_table.channel{chan_i};
                scrollsubplot(sub_rows, sub_cols, chan_i);
                sep_data = a(strcmpi([a.channel], chan)).sep_sliced_data;
                plot(time, sep_data);
                hold on;
                ylim([y_min, y_max]);
                title(chan);
            end
            %% Save fig
            filename = [filename_meta.filename, '_', ch_group, '_', event, '.fig'];
            % Set CreateFcn callback
            set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
            savefig(gcf, fullfile(save_path, filename));
            close gcf
        end
    end
end