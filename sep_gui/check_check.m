function check_check(handles)
    %handles.sep_data(handles.index).pos_peak3
    if ~isnan(handles.sep_data(handles.index).pos_peak1)
        set(handles.pos1_check, 'Enable', 'on');
    else
        set(handles.pos1_check, 'Enable', 'off');
    end
    if ~isnan(handles.sep_data(handles.index).pos_peak2)
        set(handles.pos2_check, 'Enable', 'on');
    else
        set(handles.pos2_check, 'Enable', 'off');
    end
    if ~isnan(handles.sep_data(handles.index).pos_peak3)
        set(handles.pos3_check, 'Enable', 'on');
    else
        set(handles.pos3_check, 'Enable', 'off');
    end
    if ~isnan(handles.sep_data(handles.index).neg_peak1)
        set(handles.neg1_check, 'Enable', 'on');
    else
        set(handles.neg1_check, 'Enable', 'off');
    end
    if ~isnan(handles.sep_data(handles.index).neg_peak2)
        set(handles.neg2_check, 'Enable', 'on');
    else
        set(handles.neg2_check, 'Enable', 'off');
    end
    if ~isnan(handles.sep_data(handles.index).neg_peak3)
        set(handles.neg3_check, 'Enable', 'on');
    else
        set(handles.neg3_check, 'Enable', 'off');
    end
end