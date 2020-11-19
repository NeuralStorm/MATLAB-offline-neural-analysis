function changeTo_check(handles)

    if isnan(handles.sep_data(handles.index).pos_peak1)
        set(handles.pos1_changeTo, 'Enable', 'on');
        set(handles.pos1_changeTo, 'Value', 0); 
    end
    if isnan(handles.sep_data(handles.index).pos_peak2)
        set(handles.pos2_changeTo, 'Enable', 'on');
        set(handles.pos2_changeTo, 'Value', 0); 
    end
    if isnan(handles.sep_data(handles.index).pos_peak3)
        set(handles.pos3_changeTo, 'Enable', 'on');
        set(handles.pos3_changeTo, 'Value', 0); 
    end
    if isnan(handles.sep_data(handles.index).neg_peak1)
        set(handles.neg1_changeTo, 'Enable', 'on');
        set(handles.neg1_changeTo, 'Value', 0); 
    end
    if isnan(handles.sep_data(handles.index).neg_peak2)
        set(handles.neg2_changeTo, 'Enable', 'on');
        set(handles.neg2_changeTo, 'Value', 0); 
    end
    if isnan(handles.sep_data(handles.index).neg_peak3)
        set(handles.neg3_changeTo, 'Enable', 'on');
        set(handles.neg3_changeTo, 'Value', 0); 
    end
end