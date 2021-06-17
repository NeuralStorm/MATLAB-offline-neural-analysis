function [] = graph_sep(save_path, sep_struct, filename_meta, chan_group_log, ...
        sub_rows, sub_cols)
    %% Set x axis (time)
    time = linspace(sep_struct(1).sep_window(1), sep_struct(1).sep_window(2), ...
        length(sep_struct(1).sep_sliced_data));
    unique_regions = unique(chan_group_log.chan_group); 
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        region_table = chan_group_log(strcmpi(chan_group_log.chan_group, region), :);
        region_table = sortrows(region_table, 'user_channels');

        %% extracts data for the current region
        region_list = {sep_struct.chan_group};
        region_index = cellfun(@(x)contains(x, region), region_list, 'UniformOutput', 1);
        region_data = sep_struct(region_index);
        region_sep = [region_data.sep_sliced_data];

        %% Get global y limits
        y_max = max(region_sep);
        y_min = min(region_sep);
        % Add buffer so that y limits don't appear cut off in plots
        y_max = y_max + (y_max * .002) + eps;
        y_min = y_min + (y_min *.002) + eps;

        %% Plot each channel in scroll subplot
        figure('visible', 'off');
        sgtitle([filename_meta.animal_id, ' ', region]);
        for chan_i = 1:height(region_table)
            curr_chan = region_table.channel{chan_i};
            scrollsubplot(sub_rows, sub_cols, chan_i);
            sep_data = region_data(strcmpi([region_data.channel], curr_chan)).sep_sliced_data;
            plot(time, sep_data);
            hold on;
            ylim([y_min, y_max]);
            title(curr_chan);
        end
        %% Save fig
        filename = [filename_meta.filename, '_', region, '.fig'];
        % Set CreateFcn callback
        set(gcf, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
        savefig(gcf, fullfile(save_path, filename));
        close gcf
    end
end