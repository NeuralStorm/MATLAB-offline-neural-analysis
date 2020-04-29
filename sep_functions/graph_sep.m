function [] = graph_sep(save_path, sep_struct, filename_meta, label_log, ...
        sub_rows, sub_cols, visible_plot)
    %TODO verify that graphing sep function will be ran separately or with batch
    %% Set x axis (time)
    time = linspace(sep_struct(1).sep_window(1), sep_struct(1).sep_window(2), ...
        length(sep_struct(1).sep_sliced_data));
    unique_regions = unique({sep_struct.label}); 
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        region_table = label_log.(region);
        region_table = sortrows(region_table, 'user_channels');

        %% extracts data for the current region
        region_list = {sep_struct.label};
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
        figure('visible', visible_plot);
        sgtitle([filename_meta.animal_id, ' ', region]);
        for chan_i = 1:height(region_table)
            curr_chan = region_table.sig_channels{chan_i};
            scrollsubplot(sub_rows, sub_cols, chan_i);
            sep_data = sep_struct(strcmpi({sep_struct.channel_name}, curr_chan)).sep_sliced_data;
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
        if strcmpi(visible_plot, 'off')
            close gcf
        end
    end
end