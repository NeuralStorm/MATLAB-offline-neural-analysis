function find_universal_peaks(handles)
%find the max and min peak in the sep data from all channels
all_channel_sep = [];
for i = 1 : length(handles.sep_data)
    all_channel_sep = [all_channel_sep handles.sep_data(i).sep_sliced_data];
end
max_peak = max(all_channel_sep);
setappdata(0, 'universal_max_peak', max_peak);
min_peak = min(all_channel_sep);
setappdata(0, 'universal_min_peak', min_peak);
end