function add_check(handles)
    if ~isnan(handles.sep_data(handles.index).pos_peak3)
        set(handles.addpos_check, 'Enable', 'off');
    else
        set(handles.addpos_check, 'Enable', 'on');
    end
    if ~isnan(handles.sep_data(handles.index).neg_peak3)
        set(handles.addneg_check, 'Enable', 'off');
    else
        set(handles.addneg_check, 'Enable', 'on');
    end
end