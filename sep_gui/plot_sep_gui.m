function plot_sep_gui(handles, sep_analysis_results, i)
%load the data from 'sep_analysis_results' struct
sep_data = sep_analysis_results(i).sep_sliced_data;
sep_window = sep_analysis_results(i).sep_window;
early_window = sep_analysis_results(i).early_window;
late_window = sep_analysis_results(i).late_window;
animal_id = sep_analysis_results(i).animal_id;
channel_name = sep_analysis_results(i).channel;
neg_peak(1) = sep_analysis_results(i).neg_peak1;
neg_peak_latency(1) = sep_analysis_results(i).neg_peak_latency1;
pos_peak(1) = sep_analysis_results(i).pos_peak1;
pos_peak_latency(1) = sep_analysis_results(i).pos_peak_latency1;
neg_peak(2) = sep_analysis_results(i).neg_peak2;
neg_peak_latency(2) = sep_analysis_results(i).neg_peak_latency2;
pos_peak(2) = sep_analysis_results(i).pos_peak2;
pos_peak_latency(2) = sep_analysis_results(i).pos_peak_latency2;
neg_peak(3) = sep_analysis_results(i).neg_peak3;
neg_peak_latency(3) = sep_analysis_results(i).neg_peak_latency3;
pos_peak(3) = sep_analysis_results(i).pos_peak3;
pos_peak_latency(3) = sep_analysis_results(i).pos_peak_latency3;
posthresh = sep_analysis_results(i).posthresh;
negthresh = sep_analysis_results(i).negthresh;

max_point = max(sep_data);
min_point = min(sep_data);
y_range = 1.1 * (max_point - min_point);
window_range = sep_window(2) + abs(sep_window(1));
y_limits = [min_point - 0.1 * abs(min_point) + eps max_point + 0.1 * abs(max_point) + eps];
%plot the window range(early window and late window)
line(handles.axes1, [early_window(1) early_window(1)], y_limits,...
    'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
hold (handles.axes1, 'on')
line(handles.axes1, [early_window(2) early_window(2)], y_limits,...
    'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '--');
line(handles.axes1, [late_window(1) late_window(1)], y_limits,...
    'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '-.');
line(handles.axes1, [late_window(2) late_window(2)], y_limits,...
    'Color', 'black', 'LineWidth', 0.75, 'LineStyle', '-.');
%plot sep
plot(handles.axes1, sep_window(1):(1/(length(sep_data) - 1)):sep_window(2), sep_data);
ylim(handles.axes1, y_limits);

%plot threshold, stimulus time
plot(handles.axes1, xlim,[posthresh posthresh], 'r', 'LineWidth', 0.75, 'LineStyle', ':');
plot(handles.axes1, xlim,[negthresh negthresh], 'r', 'LineWidth', 0.75, 'LineStyle', ':');
line(handles.axes1, [0 0], y_limits, 'Color', 'black', 'LineWidth', 0.75);

%mark the peak point, peak number and add the coordinates information at
%the left side
%postive peaks
for pos_index = 1:length(pos_peak)
    if ~isnan(pos_peak(pos_index))
        plot(handles.axes1, pos_peak_latency(pos_index)/1000, pos_peak(pos_index),...
            'x', 'Color', 'b', 'MarkerSize', 20, 'LineWidth', 1);
        plot(handles.axes1, pos_peak_latency(pos_index)/1000, pos_peak(pos_index),...
            'o', 'MarkerFaceColor', 'b', 'MarkerSize', 4);
        text(handles.axes1, pos_peak_latency(pos_index)/1000 - 0.004 * window_range,...
            pos_peak(pos_index) - y_range * 0.03, num2str(pos_index), ...
            'FontWeight','bold','FontSize',12 , 'Color', 'b');        
        text(handles.axes1, sep_window(1) + 0.02 * window_range, ...
            max_point - y_range * 0.04 * pos_index, ...
            ['pos peak ' num2str(pos_index) ': latency: ' num2str(pos_peak_latency(pos_index)/1000) 's,']);
        text(handles.axes1, sep_window(1) + 0.25 * window_range,...
            max_point - y_range * 0.04 * pos_index, ...
            [' value: ' num2str(pos_peak(pos_index)) 'mV']);
        
    end
end
%negtive peaks
for neg_index = 1:length(neg_peak)
    if ~isnan(neg_peak(neg_index))
        plot(handles.axes1, neg_peak_latency(neg_index)/1000, neg_peak(neg_index),...
            'x', 'Color', 'r', 'MarkerSize', 20, 'LineWidth', 1);
        plot(handles.axes1, neg_peak_latency(neg_index)/1000, neg_peak(neg_index),...
            'o', 'MarkerFaceColor', 'r', 'MarkerSize', 4);
        text(handles.axes1, neg_peak_latency(neg_index)/1000 - 0.004 * window_range,...
            neg_peak(neg_index) - y_range * 0.03, num2str(neg_index), ...
            'FontWeight','bold','FontSize',12 , 'Color', 'r');    
        text(handles.axes1, sep_window(1) + 0.02 * window_range,...
            min_point + y_range * 0.13 - y_range * 0.04 * neg_index, ...
            ['neg peak ' num2str(neg_index) ': latency: ' num2str(neg_peak_latency(neg_index)/1000) 's,']);
        text(handles.axes1, sep_window(1) + 0.25 * window_range,...
            min_point + y_range * 0.13 - y_range * 0.04 * neg_index, ...
            [' value: ' num2str(neg_peak(neg_index)) 'mV']);
    end
end
        


%add comments
title_text=['Animal: ', animal_id, '     Channel: ', channel_name];
title(handles.axes1, title_text);
xlabel(handles.axes1, 'Time (s)');
ylabel(handles.axes1, 'Voltage (mV)');
hold off

set(handles.notes_text, 'String', sep_analysis_results(i).recording_notes);

end


