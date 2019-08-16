function plot_sep_gui(handles, sep_analysis_results, i)
sep_data = sep_analysis_results(i).sep_sliced_data;
window = sep_analysis_results(i).window;
animal_id = sep_analysis_results(i).animal_id;
channel_name = sep_analysis_results(i).channel_name;
neg_peak = sep_analysis_results(i).neg_peak;
neg_peak_latency = sep_analysis_results(i).neg_peak_latency;
pos_peak = sep_analysis_results(i).pos_peak;
pos_peak_latency = sep_analysis_results(i).pos_peak_latency;
posthresh = sep_analysis_results(i).posthresh;
negthresh = sep_analysis_results(i).negthresh;

max_point = max(sep_data);
min_point = min(sep_data);


plot(handles.axes1, window(1):(1/(length(sep_data) - 1)):window(2), sep_data);
hold (handles.axes1, 'on')
ylim([1.1 * min_point+eps 1.1 * max_point + eps]);
%mark the peak point
plot(handles.axes1, pos_peak_latency/1000, pos_peak, 'x', 'Color', 'b', 'MarkerSize', 20, 'LineWidth', 1);
plot(handles.axes1, pos_peak_latency/1000, pos_peak, 'o', 'MarkerFaceColor', 'b', 'MarkerSize', 4);
plot(handles.axes1, neg_peak_latency/1000, neg_peak, 'x', 'Color', 'r', 'MarkerSize', 20, 'LineWidth', 1);
plot(handles.axes1, neg_peak_latency/1000, neg_peak, 'o', 'MarkerFaceColor', 'r', 'MarkerSize', 4);
%add peak coordinate to the left side
text(handles.axes1, window(1) + 0.03, max_point - 3, ['pos peak(' num2str(pos_peak_latency/1000) ', ' num2str(pos_peak) ')']);
text(handles.axes1, window(1) + 0.03, min_point + 3, ['neg peak(' num2str(neg_peak_latency/1000) ', ' num2str(neg_peak) ')']);
%add threshold and stimulus time
plot(handles.axes1, xlim,[posthresh posthresh], 'r', 'LineWidth', 0.75, 'LineStyle', ':');
plot(handles.axes1, xlim,[negthresh negthresh], 'r', 'LineWidth', 0.75, 'LineStyle', ':');
line(handles.axes1, [0 0], ylim, 'Color', 'black', 'LineWidth', 0.75);
%add comments
title_text=['Animal: ', animal_id, '     Channel: ', channel_name];
title(handles.axes1, title_text);
xlabel(handles.axes1, 'Time (s)');
ylabel(handles.axes1, 'Voltage');
hold off
end


