function varargout = filter_input_panel(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @filter_input_panel_OpeningFcn, ...
                   'gui_OutputFcn',  @filter_input_panel_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before filter_input_panel is made visible.
function filter_input_panel_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for filter_input_panel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes filter_input_panel wait for user response (see UIRESUME)
 uiwait(handles.panel_figure);


% --- Outputs from this function are returned to the command line.
function varargout = filter_input_panel_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
lp_order_str = get(handles.lp_order_edit, 'String');
lp_fc_str = get(handles.lp_fc_edit, 'String');
hp_order_str = get(handles.hp_order_edit, 'String');
hp_fc_str = get(handles.hp_fc_edit, 'String');
retrun_value = [str2double(lp_order_str) str2double(lp_fc_str) ...
    str2double(hp_order_str) str2double(hp_fc_str)];
varargout{1} = retrun_value;

% The figure can be deleted now
delete(handles.panel_figure);



function lp_order_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lp_order_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lp_order_edit as text
%        str2double(get(hObject,'String')) returns contents of lp_order_edit as a double


% --- Executes during object creation, after setting all properties.
function lp_order_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lp_order_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lp_fc_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lp_fc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lp_fc_edit as text
%        str2double(get(hObject,'String')) returns contents of lp_fc_edit as a double


% --- Executes during object creation, after setting all properties.
function lp_fc_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lp_fc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OKbutton.
function OKbutton_Callback(hObject, eventdata, handles)
close(handles.panel_figure);



function hp_order_edit_Callback(hObject, eventdata, handles)
% hObject    handle to hp_order_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function hp_order_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hp_order_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hp_fc_edit_Callback(hObject, eventdata, handles)
% hObject    handle to hp_fc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hp_fc_edit as text
%        str2double(get(hObject,'String')) returns contents of hp_fc_edit as a double


% --- Executes during object creation, after setting all properties.
function hp_fc_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hp_fc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close panel_figure.
function panel_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to panel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
