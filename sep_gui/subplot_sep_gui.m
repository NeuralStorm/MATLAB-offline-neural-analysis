function subplot_sep_gui(sep_analysis_results, channel_index, eventdata, handles)
%select the handles.figure_sub, or it will change the figure in 'sep_gui'
figure(handles.figure_sub);
scrollsubplot(2, 3, channel_index);
%load the data from 'sep_analysis_results' struct
sep_data = sep_analysis_results(channel_index).sep_sliced_data;
sep_window = sep_analysis_results(channel_index).sep_window;
early_window = sep_analysis_results(channel_index).early_window;
late_window = sep_analysis_results(channel_index).late_window;
channel_name = sep_analysis_results(channel_index).channel;
event_name = sep_analysis_results(channel_index).event;
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
%local max and min peak
max_point = max(sep_data);
min_point = min(sep_data);
%plot sep
plot(sep_window(1):(1/(length(sep_data) - 1)) : sep_window(2), sep_data);
hold ('on')
%select the scale type, universal(1) or specified(2)
scale_type = getappdata(0, 'scale_selection');
global_max_peak = getappdata(0, 'universal_max_peak');
global_min_peak = getappdata(0, 'universal_min_peak');
switch scale_type
case 1
ylim([global_min_peak - 0.1 * abs(global_min_peak) + eps global_max_peak + 0.1 * abs(global_max_peak) + eps]);
case 2
ylim([min_point - 0.1 * abs(min_point) + eps max_point + 0.1 * abs(max_point) + eps]);
end    
%mark the peak point and peak number
%postive peaks
for pos_peak_index = 1:length(pos_peak)
    if ~isnan(pos_peak(pos_peak_index))
        plot(pos_peak_latency(pos_peak_index)/1000, pos_peak(pos_peak_index),...
            'x', 'Color', 'b', 'MarkerSize', 20, 'LineWidth', 1);
        plot(pos_peak_latency(pos_peak_index)/1000, pos_peak(pos_peak_index),...
            'o', 'MarkerFaceColor', 'b', 'MarkerSize', 4);
    end
end
%negtive peaks
for neg_peak_index = 1:length(neg_peak)
    if ~isnan(neg_peak(neg_peak_index))
        plot(neg_peak_latency(neg_peak_index)/1000, neg_peak(neg_peak_index),...
            'x', 'Color', 'r', 'MarkerSize', 20, 'LineWidth', 1);
        plot(neg_peak_latency(neg_peak_index)/1000, neg_peak(neg_peak_index),...
            'o', 'MarkerFaceColor', 'r', 'MarkerSize', 4);
    end
end


%add threshold, stimulus time and window range
plot(xlim,[posthresh posthresh], 'r', 'LineWidth', 0.75, 'LineStyle', ':');
plot(xlim,[negthresh negthresh], 'r', 'LineWidth', 0.75, 'LineStyle', ':');
line([0 0], ylim, 'Color', 'black', 'LineWidth', 0.75);
line([early_window(1) early_window(1)], ylim, 'Color', 'black', 'LineWidth',...
    0.75, 'LineStyle', '--');
line([early_window(2) early_window(2)], ylim, 'Color', 'black', 'LineWidth',...
    0.75, 'LineStyle', '--');
line([late_window(1) late_window(1)], ylim, 'Color', 'black', 'LineWidth',...
    0.75, 'LineStyle', '-.');
line([late_window(2) late_window(2)], ylim, 'Color', 'black', 'LineWidth',...
    0.75, 'LineStyle', '-.');
%set the click response function
set(gca,'tag',num2str(channel_index));
set(gca,'ButtonDownFcn', @channel_select);
%add comments
title_text=[event_name, channel_name];
title(title_text, 'FontSize', 7);
hold off

end

function channel_select(gca, eventdata, handles)
    % Get the sep_gui obj 
    obj_main = findobj('Name', 'sep_gui');
    % Get sep_gui handles
    handles_main = guidata(obj_main);
    select_index = str2num(get(gca,'tag')); %get the selected channel index
    setappdata(0,'select_index',select_index);    
    % Call sep_gui callback from here
    sep_gui('channel_switch_Callback', handles_main.channel_switch,[],handles_main)
end


