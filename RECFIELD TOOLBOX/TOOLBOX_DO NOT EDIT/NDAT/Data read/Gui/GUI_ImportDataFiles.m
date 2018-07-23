function varargout = GUI_ImportDataFiles(varargin)
% GUI_IMPORTDATAFILES M-file for GUI_ImportDataFiles.fig
%      GUI_IMPORTDATAFILES, by itself, creates a new GUI_IMPORTDATAFILES or raises the existing
%      singleton*.
%
%      H = GUI_IMPORTDATAFILES returns the handle to a new GUI_IMPORTDATAFILES or the handle to
%      the existing singleton*.
%
%      GUI_IMPORTDATAFILES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_IMPORTDATAFILES.M with the given input arguments.
%
%      GUI_IMPORTDATAFILES('Property','Value',...) creates a new GUI_IMPORTDATAFILES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before info_plx_tool_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_ImportDataFiles_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_ImportDataFiles

% Last Modified by GUIDE v2.5 20-Sep-2010 17:15:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_ImportDataFiles_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_ImportDataFiles_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI_ImportDataFiles is made visible.
function GUI_ImportDataFiles_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_ImportDataFiles (see VARARGIN)

% Choose default command line output for GUI_ImportDataFiles
handles.output = hObject;

% Update handles structure
movegui(hObject,'center');
guidata(hObject, handles);

% UIWAIT makes GUI_ImportDataFiles wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_ImportDataFiles_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --------------------------------------------------------------------
function Files_Callback(hObject, eventdata, handles)
% hObject    handle to Files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mb_Quit_Callback(hObject, eventdata, handles)
% hObject    handle to mb_Quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close



% --------------------------------------------------------------------
function Analysis_Callback(hObject, eventdata, handles)
% hObject    handle to Analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mb_receptivefield_Callback(hObject, eventdata, handles)
% hObject    handle to mb_receptivefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    Rec_Field_Analysis(handles.dirlist);
catch
    Rec_Field_Analysis();
end


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pre_Callback(hObject, eventdata, handles)
% hObject    handle to pre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pre as text
%        str2double(get(hObject,'String')) returns contents of pre as a double


% --- Executes during object creation, after setting all properties.
function pre_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function post_Callback(hObject, eventdata, handles)
% hObject    handle to post (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of post as text
%        str2double(get(hObject,'String')) returns contents of post as a double


% --- Executes during object creation, after setting all properties.
function post_CreateFcn(hObject, eventdata, handles)
% hObject    handle to post (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bsln_Callback(hObject, eventdata, handles)
% hObject    handle to bsln (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bsln as text
%        str2double(get(hObject,'String')) returns contents of bsln as a double


% --- Executes during object creation, after setting all properties.
function bsln_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bsln (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wndws_Callback(hObject, eventdata, handles)
% hObject    handle to wndws (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wndws as text
%        str2double(get(hObject,'String')) returns contents of wndws as a double


% --- Executes during object creation, after setting all properties.
function wndws_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wndws (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pvl_Callback(hObject, eventdata, handles)
% hObject    handle to pvl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pvl as text
%        str2double(get(hObject,'String')) returns contents of pvl as a double


% --- Executes during object creation, after setting all properties.
function pvl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pvl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bnorm.
function bnorm_Callback(hObject, eventdata, handles)
% hObject    handle to bnorm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bnorm






function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in choicepsra.
function choicepsra_Callback(hObject, eventdata, handles)
% hObject    handle to choicepsra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns choicepsra contents as cell array
%        contents{get(hObject,'Value')} returns selected item from choicepsra


% --- Executes during object creation, after setting all properties.
function choicepsra_CreateFcn(hObject, eventdata, handles)
% hObject    handle to choicepsra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function graphicstool_Callback(hObject, eventdata, handles)
% hObject    handle to graphicstool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --------------------------------------------------------------------
function mb_display_Callback(hObject, eventdata, handles)
% hObject    handle to mb_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.recfield,'visible','off');
set(handles.psthraster,'visible','on');


% --- Executes on button press in displayraspsth.
function displayraspsth_Callback(hObject, eventdata, handles)
% hObject    handle to displayraspsth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

bin=str2num(get(handles.binvis,'string'));
Tpre=str2num(get(handles.tprevis,'string'));
Tpost=str2num(get(handles.tposvis,'string'));
event=str2num(get(handles.fileed,'string'));
electrode=get(handles.electrode,'value');
channel=get(handles.channel,'value');
visualization=get(handles.choicepsra,'value');
data=evalin('base','data');


if data.maxstimuli~=data.minstimuli
    jump=1;
else
    jump=0;
end
jump=0;

[outputmatr]=singleeventmatrix(data,bin,Tpre,Tpost,event,jump);

if visualization==1
    neu=(electrode-1)*4+channel;
    neurwind=round((Tpre+Tpost)/bin)+1;
    PSTH=sum(outputmatr(:,(neu-1)*neurwind+1:neu*neurwind),1)/size(outputmatr,1);
    figure('name','PSTH');bar(-Tpre:bin:Tpost,PSTH);
    axis('tight');
    xlabel('Time in ms');
    ylabel('Spike rate per stimulus');
    title('PSTH');
    
else
    neu=(electrode-1)*4+channel;
    neurwind=round((Tpre+Tpost)/bin)+1;
    raster=outputmatr(:,(neu-1)*neurwind+1:neu*neurwind);
    figure('name','Raster plot');imshow(raster);
    xlabel('Time in ms');
    ylabel('Trials');
    title('Raster plot');
end




function bin_Callback(hObject, eventdata, handles)
% hObject    handle to bin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bin as text
%        str2double(get(hObject,'String')) returns contents of bin as a double


% --- Executes during object creation, after setting all properties.
function bin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in electrode.
function electrode_Callback(hObject, eventdata, handles)
% hObject    handle to electrode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns electrode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from electrode


% --- Executes during object creation, after setting all properties.
function electrode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to electrode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel.
function channel_Callback(hObject, eventdata, handles)
% hObject    handle to channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel


% --- Executes during object creation, after setting all properties.
function channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function binsize_Callback(hObject, eventdata, handles)
% hObject    handle to binsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binsize as text
%        str2double(get(hObject,'String')) returns contents of binsize as a double


% --- Executes during object creation, after setting all properties.
function binsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --------------------------------------------------------------------
function mb_loadmap_Callback(hObject, eventdata, handles)
% hObject    handle to mb_loadmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function mb_savemap_Callback(hObject, eventdata, handles)
% hObject    handle to mb_savemap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --------------------------------------------------------------------
function mb_createstruct_Callback(hObject, eventdata, handles)
% hObject    handle to mb_createstruct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% Variables initialization


handles.dirdata.directory=[];
handles.dirdata.anfiles=[];
handles.dirdata.infile=[];
handles.dirdata.names=[];
handles.dirdata.events=[];






try
    if ischar(handles.directory)
        stdirectory=handles.stdirectory;
    else
        stdirectory='';
    end
catch
    stdirectory='';
end

% dircontent=dir(stdirectory);
% [a,b,C]=cellfun(@fileparts,{dircontent.name},'UniformOutput',false);
% clear a,b;
% C=strcmp(C,'.plx');
% c=find(C==1);
% if isempty(c)
%     C=strcmp(C,'.nex');
%     c=find(C==1);
%     [data,directory,anfiles]=obtainstructdatabynexfile(stdirectory);
%     set(handles.plxnex,'value',2);
%     infile=1;
%     names=[];
% else
%     [data,directory,anfiles,infile,names]=obtainstructdatabyplxfile_v1(stdirectory);
%     set(handles.plxnex,'value',1);
% end

stdirectory= uigetdir(stdirectory,'Select the directory where the files are located');
handles.stdirectory=stdirectory;
dirswithdata=search_files(stdirectory);
data=0;
currfile=1;
for i=1:length(dirswithdata)
    [datat,directory,anfiles,infile,names,events]=obtainstructdatabyplxfile(dirswithdata{i});
    for j=1:length(anfiles)
        handles.file(currfile).directory=directory;
        handles.file(currfile).name=anfiles{j};
        handles.file(currfile).infile=infile{j};
        handles.file(currfile).names=names{j};
        emptyind=1-cellfun(@isempty,(events(:,:,j)));
        handles.file(currfile).events=events(emptyind(:,1)==1,:,j);
        handles.file(currfile).toimport=setdiff(infile{j},[2,3,4,5,6]);
        handles.file(currfile).merged=false;
        
        handles.file(currfile).multiple_stim=true;
        if size(handles.file(currfile).events,1)==5
            handles.file(currfile).stimsel=[2,4,5];
        elseif size(handles.file(currfile).events,1)==4
            handles.file(currfile).stimsel=[2,3,4];
        elseif size(handles.file(currfile).events,1)==2
            handles.file(currfile).multiple_stim=false;
            handles.file(currfile).stimsel=2;
        end
        
        currfile=currfile+1;
    end
    data=datat+data;
end

if data==0
        
else
    
    addlist={'checkbox0','checkbox1','checkbox2','checkbox3','checkbox4'...
        'checkbox5','checkbox6'};
    enable(handles,addlist,'''off''')
    handles.directory=directory;
    onlist={'listtool','bg_extract','lb_filelist','fileload',...
        'pb_createmap','ui_events','tx_events','pb_setev',...
        'ed_identifier','text36','currdir','ui_stim'};
    offlist={'nofile'};
    
    update_listbar(hObject, eventdata, handles);
    
    
    visible(handles,onlist,'''on''')
    visible(handles,offlist,'''off''')
    
    
    
end
guidata(hObject, handles);



function update_listbar(hObject, eventdata, handles)

if isempty({handles.file.name}')
    set(handles.lb_filelist,'string',{});
else
    
    reset_values(handles);
    set(handles.lb_filelist,'string',{handles.file.name}');
    file=get(handles.lb_filelist, 'value');
    
    events={'multiple values'};
    multiple_stim=false;
    evlist={'multiple values'};
    stimsel=[1];
    infile=[];
    toimport=[];
    
    
    if sum([handles.file(file).merged])~=0
        directory={'Contains merged files'};
        if length(file)==1
            directory=handles.file(file).directory{1};
            infile=handles.file(file).infile;
            stimsel=handles.file(file).stimsel{1};
            evlist=handles.file(file).events{1}(:,3);
            events=handles.file(file).events{1};
            toimport=handles.file(file).toimport{1};
            multiple_stim=handles.file(file).multiple_stim{1};
        end
        
    else
        directory=unique({handles.file(file).directory}');
        
    end
    
    
    
    evcell={handles.file(file).events}'; 
    try
        tempeq=[];
        for i=1:length(file)
            if i==1
                tempeq=cellfun(@isequal,...
                    evcell{1}(handles.file(min(file)).stimsel,[3]),...
                    evcell{i}(handles.file(file(i)).stimsel,[3]));
            else
                tempeq=tempeq+cellfun(@isequal,...
                    evcell{1}(handles.file(min(file)).stimsel,[3]),...
                    evcell{i}(handles.file(file(i)).stimsel,[3]));
            end
        end
        if sum(sum(tempeq))==...
                (length(file))*length(handles.file(min(file)).stimsel)
            events=handles.file(min(file)).events;
            multiple_stim=handles.file(min(file)).multiple_stim;
            evlist=handles.file(min(file)).events(:,3);
            stimsel=handles.file(min(file)).stimsel;
            infile=handles.file(min(file)).infile;
            toimport=handles.file(min(file)).toimport;
        end
    catch
          
    end
    set(handles.currdir,'string',directory);
    set(handles.ui_events,'data',events);
    set(handles.cb_multipleEvents,'value',multiple_stim);
    set(handles.lb_event,'String',evlist);
    set(handles.lb_event,'value',stimsel);
    
    
    
    addlist={};
    vallist={};
    for i=1:length(infile)
        addlist=[addlist,['checkbox',num2str(infile(i))]];
    end
    for i=1:length(toimport)
        vallist=[vallist,['checkbox',num2str(toimport(i))]];
    end
    enable(handles,addlist,'''on''');
    
    set_value_to(handles,vallist,1);
    
end


function reset_values(handles)

list={'checkbox0','checkbox1','checkbox2','checkbox3','checkbox4'...
        'checkbox5','checkbox6'};
set_value_to(handles,list,0);
enable(handles,list,'''off''')


function fileed_Callback(hObject, eventdata, handles)
% hObject    handle to fileed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileed as text
%        str2double(get(hObject,'String')) returns contents of fileed as a double


% --- Executes during object creation, after setting all properties.
function fileed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --------------------------------------------------------------------
function mb_loadstructload_Callback(hObject, eventdata, handles)
% hObject    handle to mb_loadstructload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currdir=pwd;
cd(handles.directory)
[file,directory]=uigetfile('*.mat','Select the MAT-file');
data=load([directory,file]);
handles.currentsavfil=[directory,file];
assignin('base','data',data.data);
assignin('base','directory',directory);
guidata(hObject, handles);
cd(currdir)
% --------------------------------------------------------------------
function mb_loadmatrix_Callback(hObject, eventdata, handles)
% hObject    handle to mb_loadmatrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mb_savestruct_Callback(hObject, eventdata, handles)
% hObject    handle to mb_savestruct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
g=evalin('base','who');


if isempty(g) | isempty(cell2mat(strfind(g,'directory')))
    errordlg('No file is currently loaded','File Error');
elsefunction my_disable(handles,list,str)

for i=1:length(list)
    
    eval(['set(handles.',list{i},',''enable'',',str,')']);
    
end
    directory=evalin('base','directory');
    g=max(find(directory=='\'));
    name=directory(g+1:length(directory));
    current=evalin('base','data');
    [file,directory]=uiputfile('*.mat','Select the MAT-file',name);
    save([directory,file],'data');
end

% --------------------------------------------------------------------
function mb_savematrix_Callback(hObject, eventdata, handles)
% hObject    handle to mb_savematrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

matrsave


% --------------------------------------------------------------------
function mb_Display_Receptive_Field_Callback(hObject, eventdata, handles)
% hObject    handle to mb_Display_Receptive_Field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on selection change in lb_filelist.
function lb_filelist_Callback(hObject, eventdata, handles)
% hObject    handle to lb_filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lb_filelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb_filelist


% currsel=get(handles.lb_filelist,'value');
% filelist=get(handles.lb_filelist,'string');
% for i=1:length(currsel)
%     try
%         set(handles.ui_events,'data',handles.events(:,:,currsel(i)));
%     end
% end
% guidata(hObject, handles);

values=get(handles.lb_filelist,'value');

if length(values)>1
    enable(handles,{'cb_merge' 'ed_merge'},'''on''');
    set(handles.ed_merge,'string',['MRG:',handles.file(min(values)).name(1:end-4),'.mrg']);
    
else
    enable(handles,{'cb_merge' 'ed_merge'},'''off''');
    set(handles.ed_merge,'string',[]);
    
    
end

update_listbar(hObject, eventdata, handles)







% --- Executes during object creation, after setting all properties.
function lb_filelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

function my_disable(handles,list,str)

for i=1:length(list)
    
    eval(['set(handles.',list{i},',''enable'',',str,')']);
    
end

% --- Executes on button press in pb_createmap.
function pb_createmap_Callback(hObject, eventdata, handles)
% hObject    handle to pb_createmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
disp('Starting Import...')
for currfile=1:length(handles.file)
    
    if handles.file(currfile).merged==1
        
        my_import_merged(handles.file(currfile));
        
    else
        
        my_import_file(handles.file(currfile))
        
    end
    
    
    
end

function datamrg=my_import_merged(file)

disp('Merged file, start importing individual files')



for i=1:length(file.merge_files)
    
    filetemp.directory=file.directory{i};
    filetemp.name=file.merge_files{i};
    filetemp.infile=file.infile;
    filetemp.toimport=file.toimport{i};
    filetemp.stimsel=file.stimsel{i};
    filetemp.evnames=file.evnames{i};
    
    if i==1
        datamrg=my_import_file(filetemp);
    else
        datamrg=merge_data(datamrg,my_import_file(filetemp));
    end
    
end

function data=my_import_file(file)

directory=file.directory;
name=file.name;
infile=file.infile;
options.toimport=file.toimport;
options.evchannels=file.stimsel;
% options.evames=file.evnames;

[path,name,ext]=fileparts(name);
options.import_engine=ext;

data=import_data([directory,filesep,name,ext],options);





% curr_dir=pwd;
% infile=[];
% for i=1:7
%     
%     eval(['val=get(handles.checkbox',num2str(i-1),',''value'');'])
%     
%     if val
%         
%         infile=[infile i-1];
%         
%     end
%     
% end
% 
% handles.infile=infile;
% 
% %intervals={'int_con' 'int_sal' 'int_x1' 'int_x2' 'int_x3' 'int_x4' 'int_x5' 'int_x6'};
% %intervals={'int_con1' 'int_con2'};
% eventscell=get(handles.ui_events,'data');
% eventscell=handles.events;
% for index=1:1
%     
%     h=1;
%     if handles.filetypeans=='plx'
%         [data,directory,anfiles,infile,names]=obtainstructdatabyplxfile_v1(handles.directory,handles.anfiles,handles.infile,handles.names);
%         set(handles.plxnex,'value',1);
%         if 1
%             
%             oldfiles=data.files;
%             oldnumfile=data.filenum;
%             oldanfiles=data.anfiles;
%             for i=1:data.filenum
%                 
%                 
%                 identifier=get(handles.ed_identifier,'string');
%                 pos=strfind(anfiles,[identifier,'.']);
%                 if isempty(pos{1})
%                     errordlg('Make sure that the Exp.label matches the one present in the filename or that the Exp.label is followed by a dot ''.'' in the name file');
%                     return
%                 end
%                 for j=1:size(eventscell,1)
%                     
%                     if isempty(eventscell{j,3,i})
%                         
%                     else
%                         %02/04/09 corrected a bug. the index of the vector
%                         %pos was mistakenly j and not i. pos goes over the
%                         %filename that could be lower than the number of
%                         %stimuli
%                         anfilesnew{h,1}=[anfiles{i}(1:pos{i}+size(identifier,2)),eventscell{j,3,i},'.',anfiles{i}(pos{i}+size(identifier,2)+1:end)];
%                         data.files(h)=oldfiles(i);
%                         data.files(h).eventts(2:end)=[];
%                         data.files(h).eventts(2)=oldfiles(i).eventts(eventscell{j,2,i});
%                         h=h+1;
%                     end
%                     
%                 end
%                 
%                 
%             end
%             data.filenum=h-1;
%             data.anfiles=anfilesnew;
%             anfiles=anfilesnew;
%             data.stimuli=h-1*2;
%             
%         end
%     else
%         
%         try
%             
%             [data,directory,anfiles,infile,names]=obtainstructdatabynexfile_v1(handles.directory,handles.anfiles);
%             set(handles.plxnex,'value',2);
%             data.anfiles=anfiles;
%             
%             
%         catch
%             
%             [data,directory,anfiles]=obtainstructdatabynexfile_general(handles.directory,handles.anfiles);
%             data=convert_to_oldformat(datanew);
%             data.anfiles=anfiles;
%             assignin('base','data',data);
%             %for melanie's data data=convert_to_oldformat(datanew,intervals(index),{'low','med','hi'},0);
%             
%         end
%         if 1
%             
%             oldfiles=data.files;
%             oldnumfile=data.filenum;
%             oldanfiles=data.anfiles;
%             for i=1:data.filenum
%                 
%                 
%                 identifier=get(handles.ed_identifier,'string');
%                 pos=strfind(anfiles,[identifier,'.']);
%                 if isempty(pos{1})
%                     errordlg('Make sure that the Exp.label matches the one present in the filename or that the Exp.label is followed by a dot ''.'' in the name file');
%                     return
%                 end
%                 for j=1:size(eventscell,1)
%                     
%                     if isempty(eventscell{j,3,i})
%                         
%                     else
%                         %02/04/09 corrected a bug. the index of the vector
%                         %pos was mistakenly j and not i. pos goes over the
%                         %filename that could be lower than the number of
%                         %stimuli
%                         anfilesnew{h,1}=[anfiles{i}(1:pos{i}+size(identifier,2)),eventscell{j,3,i},'.',anfiles{i}(pos{i}+size(identifier,2)+1:end)];
%                         data.files(h)=oldfiles(i);
%                         data.files(h).eventts(2:end)=[];
%                         data.files(h).eventts(2)=oldfiles(i).eventts(eventscell{j,2,i});
%                         h=h+1;
%                     end
%                     
%                 end
%                 
%                 
%             end
%             data.filenum=h-1;
%             data.anfiles=anfilesnew;
%             anfiles=anfilesnew;
%             data.stimuli=h-1*2;
%             
%         end
%     end
%     if index==1
%         avchan=choosenameregiondet(data.avchan);
%         data.elcnumber=ceil(max(find([data.avchan{:,2}]==1))/4)*4;
%         data.elcnumber=max(32,data.elcnumber);
%         for i=1:data.filenum
%             data.files(i).electrodes(data.elcnumber+1:end)=[];
%         end
%     end
%     
%     data.havchan=[];
%     handles.file(file).infile
%     %assignin('base','current',data);
%     %assignin('base','directory',directory);
%     anfiles=data.anfiles;
%     
%     cd('c:\');
%     [status,results]=dos('set userprofile');
%     savedir=('c:\Neuro tool\savetemp\');
%     savedir=[results(13:length(results)-1),'\Neuro tool\'];
%     [status,message,messageid]=mkdir(savedir);
%     assignin('base','data',data);
%     assignin('base','directory',directory)
%     namesize=length(data.anfiles{1});
%     save([savedir,'data.mat'],'data','directory','anfiles','avchan');
%     directoryor=directory;
%     directory=[directory,'\Structfiles'];handles.events(:,:,curr_selection)=[];
% set(handles.lb_filelist,'value',1);
% set(handles.lb_filelist,'string',handles.anfiles);
% lb_filelist_Callback(hObject, eventdata, handles);
%     handles.dirlist={};
%     if get(handles.cb_merge,'value')
%         dataold=data;
%         directoryor=directory;
%         for i=1:oldnumfile
%             
%             directory=directoryor;
%             pos2=(find(oldanfiles{1}(pos{1}:end)=='.'));
%             stimstring=oldanfiles{i}(pos{1}:end-4);
%             directory=[directory,'\',stimstring];
%             directory1=[directory,'\Matlab files',get(handles.ed_sav_dir,'string'),'\'];
%             stiminfile=sum(cellfun(@isempty,handles.events(:,3,i))==0);
%             data.files=dataold.files(1:stiminfile);
%             dataold.files(1:stiminfile)=[];
%             data.filenum=stiminfile;
%             data.numstimuli=stiminfile+1;
%             [status,message,messageid]=mkdir(directory1);
%             anfiles=dataold.anfiles(1:stiminfile);
%             data.anfiles=anfiles;
%             save([directory1,data.anfiles{1}(1:pos{1}+3),stimstring,'.Struct.mat'],'data','directory','anfiles','avchan');
%             handles.dirlist{i,1}=[directory];
%             dataold.anfiles(1:stiminfile)=[];
%             
%         end
%     else
%         directory1=[directory,'\Allplx\Matlab files',get(handles.ed_sav_dir,'string'),'\'];
%         [status,message,messageid]=mkdir(directory1);
%         save([directory1,data.anfiles{1}(1:pos{1}+3),'Struct.mat'],'data','directory','anfiles','avchan');
%         handles.dirlist{1}=[directory,'\Allplx'];
%     end
%     clear('data','directory','anfiles');
%     clear('ans');
%     handles.currentsavfil=[savedir,'data.mat'];
%     guidata(hObject, handles);
%     
%     clear data,
%     directory=directoryor;
% end
% 
% if get(handles.cb_runrecfield,'value')
%     Rec_Field_Analysis(handles.dirlist);
% end
% if get(handles.cb_PSTH_classifier,'value')
%     PSTH_Class_Analysis(handles.currentsavfil);
% end
% cd(curr_dir);



% --- Executes on selection change in plxnex.
function plxnex_Callback(hObject, eventdata, handles)
% hObject    handle to plxnex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns plxnex contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plxnex


% --- Executes during object creation, after setting all properties.
function plxnex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plxnex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --------------------------------------------------------------------
function filelistmenu_Callback(hObject, eventdata, handles)
% hObject    handle to filelistmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function cm_remfile_Callback(hObject, eventdata, handles)
% hObject    handle to cm_remfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%020509 Alessandro function changed to solve bug. Handles.events now
%mirrors changed in the string of handles.lbfilelist

curr_selection=get(handles.lb_filelist,'value');
handles.file(curr_selection)=[];
set(handles.lb_filelist,'Value',min(curr_selection)-1);
update_listbar(hObject, eventdata, handles)

guidata(hObject, handles);


% --- Executes on button press in pb_merge.
function pb_merge_Callback(hObject, eventdata, handles)
% hObject    handle to pb_merge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


values=get(handles.lb_filelist,'value');
mergepos=min(values);

handles.file(mergepos).merge_files={handles.file(values).name}';
handles.file(mergepos).directory={handles.file(values).directory}';
handles.file(mergepos).events={handles.file(values).events}';
handles.file(mergepos).stimsel={handles.file(values).stimsel}';
handles.file(mergepos).toimport={handles.file(values).toimport}';
handles.file(mergepos).multiple_stim={handles.file(values).multiple_stim}';
handles.file(mergepos).name=get(handles.ed_merge,'String');
handles.file(mergepos).merged=true;

values=setdiff(values,mergepos);
handles.file(values)=[];
set(handles.lb_filelist,'value',mergepos);
update_listbar(hObject, eventdata, handles)
guidata(hObject, handles);











% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in checkbox0.
function checkbox0_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox0


% --- Executes on button press in checkbox1.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in checkbox6.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6




% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4

function visible(handles,list,str)

for i=1:length(list)
    
    eval(['set(handles.',list{i},',''visible'',',str,')']);
    
end

function enable(handles,list,str)

for i=1:length(list)
    
    eval(['set(handles.',list{i},',''enable'',',str,')']);
    
end



function set_value_to(handles,list,value)

for i=1:length(list)
    
    eval(['set(handles.',list{i},',''value'',',num2str(value),')']);
    
end

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3




% --- Executes on key press over lb_filelist with no controls selected.
function lb_filelist_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lb_filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in cb_PSTH_classifier.
function cb_PSTH_classifier_Callback(hObject, eventdata, handles)
% hObject    handle to cb_PSTH_classifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_PSTH_classifier


% --------------------------------------------------------------------
function mb_PSTH_Callback(hObject, eventdata, handles)
% hObject    handle to mb_PSTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    PSTH_Class_Analysis(handles.currentsavfil);
catch
    PSTH_Class_Analysis();
end



function ed_sav_dir_Callback(hObject, eventdata, handles)
% hObject    handle to ed_sav_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_sav_dir as text
%        str2double(get(hObject,'String')) returns contents of ed_sav_dir as a double


% --- Executes during object creation, after setting all properties.
function ed_sav_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_sav_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in cb_merge.
function cb_merge_Callback(hObject, eventdata, handles)
% hObject    handle to cb_merge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_merge




% --- Executes when selected cell(s) is changed in ui_events.
function ui_events_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to ui_events (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)




% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over lb_filelist.
function lb_filelist_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to lb_filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when entered data in editable cell(s) in ui_events.
function ui_events_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to ui_events (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
value=get(handles.lb_filelist,'value');
handles.file(value).events=get(handles.ui_events,'data');
update_listbar(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes on button press in pb_setev.
function pb_setev_Callback(hObject, eventdata, handles)
% hObject    handle to pb_setev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for i=1:length(handles.file)
    if size(handles.file(i).events,1)==size(get(handles.ui_events,'data'),1);
        handles.file(i).events=get(handles.ui_events,'data');
    else
        
    end
end
update_listbar(hObject, eventdata, handles)
guidata(hObject, handles);



function ed_identifier_Callback(hObject, eventdata, handles)
% hObject    handle to ed_identifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_identifier as text
%        str2double(get(hObject,'String')) returns contents of ed_identifier as a double


% --- Executes during object creation, after setting all properties.
function ed_identifier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_identifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pb_createmap.
function pb_createmap_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pb_createmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)









function ed_merge_Callback(hObject, eventdata, handles)
% hObject    handle to ed_merge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_merge as text
%        str2double(get(hObject,'String')) returns contents of ed_merge as a double


% --- Executes during object creation, after setting all properties.
function ed_merge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_merge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_up.
function pb_up_Callback(hObject, eventdata, handles)
% hObject    handle to pb_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.lb_filelist,'value')==1
    
else
    
    switch_values(hObject, eventdata,handles,-1)
    
end

% --- Executes on button press in pb_down.
function pb_down_Callback(hObject, eventdata, handles)
% hObject    handle to pb_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if get(handles.lb_filelist,'value')==length(handles.file)
    
else
    
    switch_values(hObject, eventdata,handles,+1)
    
end


function switch_values(hObject, eventdata,handles,offset)

value=get(handles.lb_filelist,'value');
newvalue=value+offset;
temp=handles.file(newvalue);
handles.file(newvalue)=handles.file(value);
handles.file(value)=temp;
set(handles.lb_filelist,'value',newvalue);
update_listbar(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes on button press in cb_multipleEvents.
function cb_multipleEvents_Callback(hObject, eventdata, handles)
% hObject    handle to cb_multipleEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_multipleEvents


% --- Executes on selection change in lb_event.
function lb_event_Callback(hObject, eventdata, handles)
% hObject    handle to lb_event (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lb_event contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb_event


% --- Executes during object creation, after setting all properties.
function lb_event_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_event (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function mb_loadsession_Callback(hObject, eventdata, handles)
% hObject    handle to mb_loadsession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,directory]=uigetfile('*.pses','Select the MAT-file');
load([directory,file],'-mat');
handles.file=filesession;
update_listbar(hObject, eventdata, handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function mb_savesession_Callback(hObject, eventdata, handles)
% hObject    handle to mb_savesession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,directory]=uiputfile('*.pses','set a name');
filesession=handles.file;
save([directory,file],'filesession');


% --------------------------------------------------------------------
function bg_extract_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to bg_extract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

1;
