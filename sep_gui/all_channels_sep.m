function varargout = all_channels_sep(varargin)
% ALL_CHANNELS_SEP MATLAB code for all_channels_sep.fig
%      ALL_CHANNELS_SEP, by itself, creates a new ALL_CHANNELS_SEP or raises the existing
%      singleton*.
%
%      H = ALL_CHANNELS_SEP returns the handle to a new ALL_CHANNELS_SEP or the handle to
%      the existing singleton*.
%
%      ALL_CHANNELS_SEP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALL_CHANNELS_SEP.M with the given input arguments.
%
%      ALL_CHANNELS_SEP('Property','Value',...) creates a new ALL_CHANNELS_SEP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before all_channels_sep_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to all_channels_sep_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help all_channels_sep

% Last Modified by GUIDE v2.5 26-Aug-2019 20:26:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @all_channels_sep_OpeningFcn, ...
                   'gui_OutputFcn',  @all_channels_sep_OutputFcn, ...
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


% --- Executes just before all_channels_sep is made visible.
function all_channels_sep_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to all_channels_sep (see VARARGIN)

% Choose default command line output for all_channels_sep
handles.output = hObject;
original_path = getappdata(0, 'select_path');
load(original_path, 'sep_analysis_results');
clf(handles.figure_sub);
for channel_index = 1 : length(sep_analysis_results)
    subplot_sep_gui(sep_analysis_results, channel_index, eventdata, handles);
end
guidata(hObject, handles);

% UIWAIT makes all_channels_sep wait for user response (see UIRESUME)
% uiwait(handles.figure_sub);


% --- Outputs from this function are returned to the command line.
function varargout = all_channels_sep_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% function  clicksubplot
% while 1 == 1
%     w = waitforbuttonpress;
%       switch w 
%           case 1 % keyboard 
%               key = get(gcf,'currentcharacter'); 
%               if key == 27 % (the Esc key) 
%                   break
%               end
%           case 0 % mouse click 
%               selected_channel_index = get(gca,'tag')
%       end
% end




% --- Executes on mouse press over figure background.
function figure_sub_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure_sub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in subplot_refresh.
function subplot_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to subplot_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

original_path = getappdata(0, 'select_path');
% original_changed_index = getappdata(0, 'changed_channel_index');
% changed_index = unique(original_changed_index);
% if ~isempty(changed_index)
load(original_path, 'sep_analysis_results');
clf(handles.figure_sub);
for channel_index = 1 : length(sep_analysis_results)
    subplot_sep_gui(sep_analysis_results, channel_index, eventdata, handles);
end
% end
