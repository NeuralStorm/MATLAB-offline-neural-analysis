function varargout = GUI_NDAT(varargin)
% GUI_NDAT M-file for GUI_NDAT.fig
%      GUI_NDAT, by itself, creates a new GUI_NDAT or raises the existing
%      singleton*.
%
%      H = GUI_NDAT returns the handle to a new GUI_NDAT or the handle to
%      the existing singleton*.
%
%      GUI_NDAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_NDAT.M with the given input arguments.
%
%      GUI_NDAT('Property','Value',...) creates a new GUI_NDAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_NDAT_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_NDAT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_NDAT

% Last Modified by GUIDE v2.5 20-Sep-2010 17:16:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_NDAT_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_NDAT_OutputFcn, ...
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


% --- Executes just before GUI_NDAT is made visible.
function GUI_NDAT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_NDAT (see VARARGIN)

% Choose default command line output for GUI_NDAT
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_NDAT wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_NDAT_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mb_save_Callback(hObject, eventdata, handles)
% hObject    handle to mb_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mb_import_Callback(hObject, eventdata, handles)
% hObject    handle to mb_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mb_quit_Callback(hObject, eventdata, handles)
% hObject    handle to mb_quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mb_plx_import_Callback(hObject, eventdata, handles)
% hObject    handle to mb_plx_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plx_import

% --------------------------------------------------------------------
function mb_ci_Callback(hObject, eventdata, handles)
% hObject    handle to mb_ci (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
