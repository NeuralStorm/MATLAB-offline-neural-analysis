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

% Last Modified by GUIDE v2.5 15-Aug-2019 16:17:23

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

original_path = uigetfile('*.mat', 'MultiSelect', 'off');
load(original_path, 'sep_analysis_results');
handles.file_path = original_path;
handles.index = 1;
plot_sep_gui(handles, sep_analysis_results, handles.index);
dcm_obj = datacursormode(handles.figure1);
datacursormode on;
set(dcm_obj,'UpdateFcn', @myupdatefcn )
handles.sep_data = sep_analysis_results;
set(0, 'userdata', []);
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes sep_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function txt = myupdatefcn(handles, event_obj)
    pos = event_obj.Position;
    txt = {['X: ',num2str(pos(1)),', Y: ',num2str(pos(2))]};
    set(0, 'userdata', pos);
%     pos_check = get(handles.pos_check, 'Value');
%     neg_check = get(handles.neg_check, 'Value');
%     if (pos_check || neg_check)
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
    handles.index = handles.index - 1;
    guidata(hObject,handles);
    cla(handles.axes1);
    plot_sep_gui(handles, handles.sep_data, handles.index); 
    set(0, 'userdata', []);
    set(handles.pos_check, 'Enable', 'on');
    set(handles.neg_check, 'Enable', 'on');
    set(handles.pos_check, 'Value', 0); 
    set(handles.neg_check, 'Value', 0);  
    set(handles.change_button, 'Enable', 'off');
end


% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.index < length(handles.sep_data)
    handles.index = handles.index + 1;
    guidata(hObject,handles);
    cla(handles.axes1);
    plot_sep_gui(handles, handles.sep_data, handles.index);    
    set(0, 'userdata', []);
    set(handles.pos_check, 'Enable', 'on');
    set(handles.neg_check, 'Enable', 'on');
    set(handles.pos_check, 'Value', 0); 
    set(handles.neg_check, 'Value', 0);    
    set(handles.change_button, 'Enable', 'off');
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
pos = get(0,'userdata');
if get(handles.pos_check, 'Value')
    if ~isempty(pos)
        handles.sep_data(handles.index).pos_peak_latency = (pos(1)*1000);
        handles.sep_data(handles.index).pos_peak = pos(2);
        guidata(hObject, handles);
    end
    cla(handles.axes1);
    plot_sep_gui(handles, handles.sep_data, handles.index); 
end

if get(handles.neg_check, 'Value')
    if ~isempty(pos)
        handles.sep_data(handles.index).neg_peak_latency = (pos(1)*1000);
        handles.sep_data(handles.index).neg_peak = pos(2);
        guidata(hObject, handles);
    end
    cla(handles.axes1);
    plot_sep_gui(handles, handles.sep_data, handles.index); 
end
set(handles.pos_check, 'Enable', 'on');
set(handles.neg_check, 'Enable', 'on');
set(handles.pos_check, 'Value', 0);
set(handles.neg_check, 'Value', 0);
set(handles.change_button, 'Enable', 'off');
    
    



% --- Executes on button press in pos_check.
function pos_check_Callback(hObject, eventdata, handles)
% hObject    handle to pos_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pos_check
pos_check = get(handles.pos_check, 'Value');
if pos_check == 1
    set(handles.neg_check, 'Enable', 'off');
    set(handles.change_button, 'Enable', 'on');
else
    set(handles.neg_check, 'Enable', 'on');
    set(handles.change_button, 'Enable', 'off');
end


% --- Executes on button press in neg_check.
function neg_check_Callback(hObject, eventdata, handles)
% hObject    handle to neg_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of neg_check
neg_check = get(handles.neg_check, 'Value');
if neg_check == 1
    set(handles.pos_check, 'Enable', 'off');
    set(handles.change_button, 'Enable', 'on');
else
    set(handles.pos_check, 'Enable', 'on');
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
