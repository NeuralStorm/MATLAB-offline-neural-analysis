function sort_peaks(hObject, handles)
    % positive peaks
    pos_peak_array = [handles.sep_data(handles.index).pos_peak_latency1 handles.sep_data(handles.index).pos_peak1;...
        handles.sep_data(handles.index).pos_peak_latency2 handles.sep_data(handles.index).pos_peak2;...
        handles.sep_data(handles.index).pos_peak_latency3 handles.sep_data(handles.index).pos_peak3];
    pos_sorted_peak_array = sortrows(pos_peak_array, 1);
    handles.sep_data(handles.index).pos_peak_latency1 = pos_sorted_peak_array(1, 1);
    handles.sep_data(handles.index).pos_peak1 = pos_sorted_peak_array(1, 2);
    handles.sep_data(handles.index).pos_peak_latency2 = pos_sorted_peak_array(2, 1);
    handles.sep_data(handles.index).pos_peak2 = pos_sorted_peak_array(2, 2);
    handles.sep_data(handles.index).pos_peak_latency3 = pos_sorted_peak_array(3, 1);
    handles.sep_data(handles.index).pos_peak3 = pos_sorted_peak_array(3, 2);
    % negative peaks
    neg_peak_array = [handles.sep_data(handles.index).neg_peak_latency1 handles.sep_data(handles.index).neg_peak1;...
        handles.sep_data(handles.index).neg_peak_latency2 handles.sep_data(handles.index).neg_peak2;...
        handles.sep_data(handles.index).neg_peak_latency3 handles.sep_data(handles.index).neg_peak3];
    neg_sorted_peak_array = sortrows(neg_peak_array, 1);
    handles.sep_data(handles.index).neg_peak_latency1 = neg_sorted_peak_array(1, 1);
    handles.sep_data(handles.index).neg_peak1 = neg_sorted_peak_array(1, 2);
    handles.sep_data(handles.index).neg_peak_latency2 = neg_sorted_peak_array(2, 1);
    handles.sep_data(handles.index).neg_peak2 = neg_sorted_peak_array(2, 2);
    handles.sep_data(handles.index).neg_peak_latency3 = neg_sorted_peak_array(3, 1);
    handles.sep_data(handles.index).neg_peak3 = neg_sorted_peak_array(3, 2);
    
    guidata(hObject, handles);
    
end