function varargout = sep_gui(varargin)
% SEP_GUI MATLAB code for sep_gui.fig
%      SEP_GUI, by itself, creates a new SEP_GUI or raises the existing
%      singleton*.
%
%      H = SEP_GUI returns the handle to a new SEP_GUI or the handle to
%      the existing singleton*.
%
%      SEP_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEP_GUI.M with the given input arguments.
%
%      SEP_GUI('Property','Value',...) creates a new SEP_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sep_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sep_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sep_gui

% Last Modified by GUIDE v2.5 22-Aug-2019 16:03:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sep_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @sep_gui_OutputFcn, ...
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


% --- Executes just before sep_gui is made visible.
function sep_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sep_gui (see VARARGIN)

% Choose default command line output for sep_gui
handles.output = hObject;

[file_name, original_path] = uigetfile('*.mat', 'MultiSelect', 'off');
original_path = [original_path '\' file_name];
load(original_path, 'sep_analysis_results');
handles.file_path = original_path;
handles.index = 1;
plot_sep_gui(handles, sep_analysis_results, handles.index);
dcm_obj = datacursormode(handles.figure1);
datacursormode on;
set(dcm_obj,'UpdateFcn', @myupdatefcn )
handles.sep_data = sep_analysis_results;
set(0, 'userdata', []);
check_check(handles);
add_check(handles);

    
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes sep_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function txt = myupdatefcn(handles, event_obj)
    pos = event_obj.Position;
    txt = {['X: ',num2str(pos(1)),'s, Y: ',num2str(pos(2)), 'mV']};
    set(0, 'userdata', pos);
%     pos1_check = get(handles.pos1_check, 'Value');
%     neg1_check = get(handles.neg1_check, 'Value');
%     if (pos1_check || neg1_check)
%         set(handles.change_button, 'Enable', 'on');
%     end




% --- Outputs from this function are returned to the command line.
function varargout = sep_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;



% --- Executes on button press in prev_button.
function prev_button_Callback(hObject, eventdata, handles)
% hObject    handle to prev_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.index > 1
    handles.sep_data(handles.index).analysis_notes = get(handles.notes_text, 'String');
    handles.index = handles.index - 1;
    guidata(hObject,handles);
    cla(handles.axes1);
    plot_sep_gui(handles, handles.sep_data, handles.index); 
    set(0, 'userdata', []);
    set(handles.pos1_check, 'Enable', 'on');
    set(handles.neg1_check, 'Enable', 'on');
    set(handles.pos1_check, 'Value', 0); 
    set(handles.neg1_check, 'Value', 0);
    check_check(handles);
    set(handles.change_button, 'Enable', 'off');
    
    add_check(handles);
    set(handles.addpos_check, 'Value', 0); 
    set(handles.addneg_check, 'Value', 0);  
    set(handles.add_button, 'Enable', 'off');
end


% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.index < length(handles.sep_data)
    handles.sep_data(handles.index).analysis_notes = get(handles.notes_text, 'String');
    handles.index = handles.index + 1;
    guidata(hObject,handles);
    cla(handles.axes1);
    plot_sep_gui(handles, handles.sep_data, handles.index);    
    set(0, 'userdata', []);
    set(handles.pos1_check, 'Enable', 'on');
    set(handles.neg1_check, 'Enable', 'on');
    set(handles.pos1_check, 'Value', 0); 
    set(handles.neg1_check, 'Value', 0);
    check_check(handles);
    set(handles.change_button, 'Enable', 'off');
    
    add_check(handles);
    set(handles.addpos_check, 'Value', 0); 
    set(handles.addneg_check, 'Value', 0);  
    set(handles.add_button, 'Enable', 'off');
end


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in change_button.
function change_button_Callback(hObject, eventdata, handles)
% hObject    handle to change_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
position = get(0,'userdata');
if get(handles.pos1_check, 'Value')
    if ~isempty(position)
        handles.sep_data(handles.index).pos_peak_latency1 = (position(1)*1000);
        handles.sep_data(handles.index).pos_peak1 = position(2);
    end
end

if get(handles.pos2_check, 'Value')
    if ~isempty(position)
        handles.sep_data(handles.index).pos_peak_latency2 = (position(1)*1000);
        handles.sep_data(handles.index).pos_peak2 = position(2);
    end
end

if get(handles.pos3_check, 'Value')
    if ~isempty(position)
        handles.sep_data(handles.index).pos_peak_latency3 = (position(1)*1000);
        handles.sep_data(handles.index).pos_peak3 = position(2);
    end
end

if get(handles.neg1_check, 'Value')
    if ~isempty(position)
        handles.sep_data(handles.index).neg_peak_latency1 = (position(1)*1000);
        handles.sep_data(handles.index).neg_peak1 = position(2);
    end 
end

if get(handles.neg2_check, 'Value')
    if ~isempty(position)
        handles.sep_data(handles.index).neg_peak_latency2 = (position(1)*1000);
        handles.sep_data(handles.index).neg_peak2 = position(2);
    end
end

if get(handles.neg3_check, 'Value')
    if ~isempty(position)
        handles.sep_data(handles.index).neg_peak_latency3 = (position(1)*1000);
        handles.sep_data(handles.index).neg_peak3 = position(2);
    end
end

guidata(hObject, handles);
cla(handles.axes1);
plot_sep_gui(handles, handles.sep_data, handles.index);
set(handles.pos1_check, 'Enable', 'on');
set(handles.neg1_check, 'Enable', 'on');
set(handles.pos1_check, 'Value', 0);
set(handles.pos2_check, 'Value', 0);
set(handles.pos3_check, 'Value', 0);
set(handles.neg1_check, 'Value', 0);
set(handles.neg2_check, 'Value', 0);
set(handles.neg3_check, 'Value', 0);
check_check(handles);
set(handles.change_button, 'Enable', 'off');
    
    



% --- Executes on button press in pos1_check.
function pos1_check_Callback(hObject, eventdata, handles)
% hObject    handle to pos1_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pos1_check
pos_check = get(handles.pos1_check, 'Value');
if pos_check == 1
    set(handles.pos2_check, 'Enable', 'off');
    set(handles.pos3_check, 'Enable', 'off');
    set(handles.neg1_check, 'Enable', 'off');
    set(handles.neg2_check, 'Enable', 'off');
    set(handles.neg3_check, 'Enable', 'off');
    set(handles.change_button, 'Enable', 'on');
else
    check_check(handles);
    set(handles.change_button, 'Enable', 'off');
end


% --- Executes on button press in neg1_check.
function neg1_check_Callback(hObject, eventdata, handles)
% hObject    handle to neg1_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of neg1_check
neg_check = get(handles.neg1_check, 'Value');
if neg_check == 1
    set(handles.pos2_check, 'Enable', 'off');
    set(handles.pos3_check, 'Enable', 'off');
    set(handles.pos1_check, 'Enable', 'off');
    set(handles.neg2_check, 'Enable', 'off');
    set(handles.neg3_check, 'Enable', 'off');
    set(handles.change_button, 'Enable', 'on');
else
    check_check(handles);
    set(handles.change_button, 'Enable', 'off');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
sep_analysis_results = handles.sep_data;
save(handles.file_path, 'sep_analysis_results'); 

delete(hObject);


% --- Executes on button press in addpos_check.
function addpos_check_Callback(hObject, eventdata, handles)
% hObject    handle to addpos_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addpos_check
addpos_check = get(handles.addpos_check, 'Value');
if addpos_check == 1
    set(handles.addneg_check, 'Enable', 'off');
    set(handles.add_button, 'Enable', 'on');
else
    set(handles.addneg_check, 'Enable', 'on');
    set(handles.add_button, 'Enable', 'off');
end


% --- Executes on button press in addneg_check.
function addneg_check_Callback(hObject, eventdata, handles)
% hObject    handle to addneg_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addneg_check
addneg_check = get(handles.addneg_check, 'Value');
if addneg_check == 1
    set(handles.addpos_check, 'Enable', 'off');
    set(handles.add_button, 'Enable', 'on');
else
    set(handles.addpos_check, 'Enable', 'on');
    set(handles.add_button, 'Enable', 'off');
end


% --- Executes on button press in add_button.
function add_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
position = get(0,'userdata');
if get(handles.addpos_check, 'Value')
    if ~isempty(position)
        if ~isnan(handles.sep_data(handles.index).pos_peak2)
            handles.sep_data(handles.index).pos_peak_latency3 = (position(1)*1000);
            handles.sep_data(handles.index).pos_peak3 = position(2);
        else
            handles.sep_data(handles.index).pos_peak_latency2 = (position(1)*1000);
            handles.sep_data(handles.index).pos_peak2 = position(2);
        end

    end
end

if get(handles.addneg_check, 'Value')
    if ~isempty(position)
        if ~isnan(handles.sep_data(handles.index).neg_peak2)
            handles.sep_data(handles.index).neg_peak_latency3 = (position(1)*1000);
            handles.sep_data(handles.index).neg_peak3 = position(2);
        else
            handles.sep_data(handles.index).neg_peak_latency2 = (position(1)*1000);
            handles.sep_data(handles.index).neg_peak2 = position(2);
        end
    end
end
% guidata(hObject, handles);
%  sort_peaks(hObject, handles);
%     aa = handles.sep_data(handles.index).neg_peak_latency1
guidata(hObject, handles);

cla(handles.axes1);
plot_sep_gui(handles, handles.sep_data, handles.index); 
add_check(handles);

set(handles.addpos_check, 'Value', 0);
set(handles.addneg_check, 'Value', 0);
set(handles.add_button, 'Enable', 'off');

check_check(handles);
set(handles.change_button, 'Enable', 'off');






% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in discard_button.
function discard_button_Callback(hObject, eventdata, handles)
% hObject    handle to discard_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load(handles.file_path, 'sep_analysis_results');
cla(handles.axes1);
plot_sep_gui(handles, sep_analysis_results, handles.index);
handles.sep_data = sep_analysis_results;
check_check(handles);
set(handles.change_button, 'Enable', 'off');
add_check(handles);
set(handles.add_button, 'Enable', 'off');
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pos2_check.
function pos2_check_Callback(hObject, eventdata, handles)
% hObject    handle to pos2_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pos2_check
pos_check = get(handles.pos2_check, 'Value');
if pos_check == 1
    set(handles.pos1_check, 'Enable', 'off');
    set(handles.pos3_check, 'Enable', 'off');
    set(handles.neg1_check, 'Enable', 'off');
    set(handles.neg2_check, 'Enable', 'off');
    set(handles.neg3_check, 'Enable', 'off');
    set(handles.change_button, 'Enable', 'on');
else
    check_check(handles);
    set(handles.change_button, 'Enable', 'off');
end


% --- Executes on button press in neg2_check.
function neg2_check_Callback(hObject, eventdata, handles)
% hObject    handle to neg2_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of neg2_check
neg_check = get(handles.neg2_check, 'Value');
if neg_check == 1
    set(handles.pos2_check, 'Enable', 'off');
    set(handles.pos3_check, 'Enable', 'off');
    set(handles.neg1_check, 'Enable', 'off');
    set(handles.pos1_check, 'Enable', 'off');
    set(handles.neg3_check, 'Enable', 'off');
    set(handles.change_button, 'Enable', 'on');
else
    check_check(handles);
    set(handles.change_button, 'Enable', 'off');
end


% --- Executes on button press in pos3_check.
function pos3_check_Callback(hObject, eventdata, handles)
% hObject    handle to pos3_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pos3_check
pos_check = get(handles.pos3_check, 'Value');
if pos_check == 1
    set(handles.pos2_check, 'Enable', 'off');
    set(handles.pos1_check, 'Enable', 'off');
    set(handles.neg1_check, 'Enable', 'off');
    set(handles.neg2_check, 'Enable', 'off');
    set(handles.neg3_check, 'Enable', 'off');
    set(handles.change_button, 'Enable', 'on');
else
    check_check(handles);
    set(handles.change_button, 'Enable', 'off');
end


% --- Executes on button press in neg3_check.
function neg3_check_Callback(hObject, eventdata, handles)
% hObject    handle to neg3_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of neg3_check
neg_check = get(handles.neg3_check, 'Value');
if neg_check == 1
    set(handles.pos2_check, 'Enable', 'off');
    set(handles.pos3_check, 'Enable', 'off');
    set(handles.neg1_check, 'Enable', 'off');
    set(handles.neg2_check, 'Enable', 'off');
    set(handles.pos1_check, 'Enable', 'off');
    set(handles.change_button, 'Enable', 'on');
else
    check_check(handles);
    set(handles.change_button, 'Enable', 'off');
end


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sep_analysis_results = handles.sep_data;
save(handles.file_path, 'sep_analysis_results'); 


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2



function notes_text_Callback(hObject, eventdata, handles)
% hObject    handle to notes_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notes_text as text
%        str2double(get(hObject,'String')) returns contents of notes_text as a double


% --- Executes during object creation, after setting all properties.
function notes_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notes_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
