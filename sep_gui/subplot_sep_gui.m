function subplot_sep_gui(sep_analysis_results, channel_index, eventdata, handles)
figure(handles.figure_sub);
scrollsubplot(2, 3, channel_index);
sep_data = sep_analysis_results(channel_index).sep_sliced_data;
sep_window = sep_analysis_results(channel_index).sep_window;
% early_window = sep_analysis_results(channel_index).early_window;
% late_window = sep_analysis_results(channel_index).late_window;
channel_name = sep_analysis_results(channel_index).channel_name;
neg_peak(1) = sep_analysis_results(channel_index).neg_peak1;
neg_peak_latency(1) = sep_analysis_results(channel_index).neg_peak_latency1;
pos_peak(1) = sep_analysis_results(channel_index).pos_peak1;
pos_peak_latency(1) = sep_analysis_results(channel_index).pos_peak_latency1;
neg_peak(2) = sep_analysis_results(channel_index).neg_peak2;
neg_peak_latency(2) = sep_analysis_results(channel_index).neg_peak_latency2;
pos_peak(2) = sep_analysis_results(channel_index).pos_peak2;
pos_peak_latency(2) = sep_analysis_results(channel_index).pos_peak_latency2;
neg_peak(3) = sep_analysis_results(channel_index).neg_peak3;
neg_peak_latency(3) = sep_analysis_results(channel_index).neg_peak_latency3;
pos_peak(3) = sep_analysis_results(channel_index).pos_peak3;
pos_peak_latency(3) = sep_analysis_results(channel_index).pos_peak_latency3;
posthresh = sep_analysis_results(channel_index).posthresh;
negthresh = sep_analysis_results(channel_index).negthresh;

    max_point = max(sep_data);
    min_point = min(sep_data);
    
%     y_range = 1.1 * (max_point - min_point);

%      plot(sep_window(1):(1/(length(sep_data) - 1)) : sep_window(2), sep_data, 'ButtonDownFcn', @channel_switch);
    plot(sep_window(1):(1/(length(sep_data) - 1)) : sep_window(2), sep_data);     
%     plot(sep_window(1):(1/(length(sep_data) - 1)) : sep_window(2), sep_data);
    hold ('on')
    ylim([1.1 * min_point+eps 1.1 * max_point + eps]);
    %mark the peak point, peak number and add the coordinates information at
    %the left side
    %postive peaks
    for pos_peak_index = 1:length(pos_peak)
        if ~isnan(pos_peak(pos_peak_index))
            plot(pos_peak_latency(pos_peak_index)/1000, pos_peak(pos_peak_index), 'x', 'Color', 'b', 'MarkerSize', 20, 'LineWidth', 1);
            plot(pos_peak_latency(pos_peak_index)/1000, pos_peak(pos_peak_index), 'o', 'MarkerFaceColor', 'b', 'MarkerSize', 4);
        end
    end
    %negtive peaks
    for neg_peak_index = 1:length(neg_peak)
        if ~isnan(neg_peak(neg_peak_index))
            plot(neg_peak_latency(neg_peak_index)/1000, neg_peak(neg_peak_index), 'x', 'Color', 'r', 'MarkerSize', 20, 'LineWidth', 1);
            plot(neg_peak_latency(neg_peak_index)/1000, neg_peak(neg_peak_index), 'o', 'MarkerFaceColor', 'r', 'MarkerSize', 4);
        end
    end


    %add threshold and stimulus time
    plot(xlim,[posthresh posthresh], 'r', 'LineWidth', 0.75, 'LineStyle', ':');
    plot(xlim,[negthresh negthresh], 'r', 'LineWidth', 0.75, 'LineStyle', ':');
    line([0 0], ylim, 'Color', 'black', 'LineWidth', 0.75);
    %add comments
    set(gca,'tag',num2str(channel_index));
     set(gca,'ButtonDownFcn', @channel_select);

    title_text=['                                Channel: ', channel_name];
      title(title_text, 'FontSize', 9);
    hold off

end

function channel_select(gca, eventdata, handles)
    % Get the GUI 1 obj 
    obj_main = findobj('Name', 'sep_gui');
    % Get GUI handles
    handles_main = guidata(obj_main);
    select_index = str2num(get(gca,'tag'));
    setappdata(0,'select_index',select_index);
%     handles_main.index = str2num(get(gca,'tag'))
    
    % Call GUI 1 callback from GUI 2 callback
    % master_gui('plot_something_Callback',gd_m.plot_something,[],g_m)
    sep_gui('channel_switch_Callback', handles_main.channel_switch,[],handles_main)

end


