function varargout = ZoirayAcquireLED(varargin)
% ZOIRAYACQUIRELED M-file for ZoirayAcquireLED.fig
%      ZOIRAYACQUIRELED, by itself, creates a new ZOIRAYACQUIRELED or raises the existing
%      singleton*.
%
%      H = ZOIRAYACQUIRELED returns the handle to a new ZOIRAYACQUIRELED or the handle to
%      the existing singleton*.
%
%      ZOIRAYACQUIRELED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ZOIRAYACQUIRELED.M with the given input arguments.
%
%      ZOIRAYACQUIRELED('Property','Value',...) creates a new ZOIRAYACQUIRELED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ZoirayAcquireLED_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ZoirayAcquireLED_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ZoirayAcquireLED

% Last Modified by GUIDE v2.5 17-Jan-2012 14:16:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ZoirayAcquireLED_OpeningFcn, ...
    'gui_OutputFcn',  @ZoirayAcquireLED_OutputFcn, ...
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


% --- Outputs from this function are returned to the command line.
function varargout = ZoirayAcquireLED_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes just before ZoirayAcquireLED is made visible.
function ZoirayAcquireLED_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ZoirayAcquireLED (see VARARGIN)

% Choose default command line output for ZoirayAcquireLED
handles.output = hObject;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Log                                                                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('logFiles','dir')~=7
    mkdir logFiles;
end
date_now = clock;
date_now = strcat(num2str(date_now(1)),'_',num2str(date_now(2)),'_', num2str(date_now(3)),'_', num2str(date_now(4)));
diary(['.\logFiles\ZoirayAcquireLED' date_now '.log']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DEFAULTS - Load                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (exist('defaults.txt','file')==2),
    [device_defAns default_roi default_wav_list]=load_defaults;
else
    device_defAns={'0','Dev1','Retiga','IRIS1'}; %Default Answers
    default_wav_list=[455 518 598 635];
    default_roi=[0 0 500 500];
end;

handles.version = 4;
handles.default_path=userpath;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Defaults - Prompt                                                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
device_prompt={'PD Controller','LED Controller','Camera','Instrument'};
device_names=inputdlg(device_prompt,'Enter Device Names',1,device_defAns);
device_names=char(device_names);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Defaults - Store                                                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(device_names)
    %If the user closes out the dialogue box, open ZoirayAcquireLED without
    %connecting to any devices
    PD='none'; LED='none'; 
    camera='none'; instr='none';
else
    %checks to see if arg1 is a number or string
    if isnumeric(deblank(device_names(1,:)))
        PD=str2double(deblank(device_names(1,:)));
    else
        PD=deblank(device_names(1,:));
    end
    
    %checks to see if arg2 is a number or string
    if isnumeric(deblank(device_names(2,:)))
        LED=str2double(deblank(device_names(2,:)));
    else
        LED=deblank(device_names(2,:));
    end
    
    %check to see if arg3 is a number or a string
    if isnumeric(deblank(device_names(3,:)))
        camera=str2double(deblank(device_names(3,:)));
    else
        camera=deblank(device_names(3,:));
    end
    
    %check to see if arg3 is a number or a string
    if isnumeric(deblank(device_names(4,:)))
        instr=str2double(deblank(device_names(4,:)));
    else
        instr=deblank(device_names(4,:));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create a biomux variable                                            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intantiate Biomux class
handles.biomux_obj=biomux(PD,LED,camera,instr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Populate biomux variable                                            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Populate variables
handles.biomux_obj = set(handles.biomux_obj,'wavList',default_wav_list);
handles.biomux_obj = set(handles.biomux_obj,'exposure',get(handles.biomux_obj,'exposure'));

% % Set Camera and ROI
% switch camera
%     case {'Retiga','Retiga2000R'}
%         handles.biomux_obj = set(handles.biomux_obj,'Camera','Retiga2000R');
%     case {'Rolera','Rolera-XR'}
%         handles.biomux_obj = set(handles.biomux_obj,'Camera','Rolera');
%     otherwise
%         handles.biomux_obj = set(handles.biomux_obj,'Camera',camera);
% end

handles.original_ROI = get(handles.biomux_obj,'ROI');
% if(default_roi(3) > roi(3) || default_roi(4) > roi(4))
%     handles.biomux_obj.roi=roi;
% else
%     handles.biomux_obj.roi=default_roi;
% end

% Put up logo
% logo=imread('C:\User_Scratch\LocalTools\ZA','bmp');
% axes(handles.Logo); image(logo); axis off;
% axes(handles.axes1);
% set(handles.axes1,'YColor',[1 0.753 0]);
% set(handles.axes1,'XColor',[1 0.753 0]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CAMERA - Update GUI                                                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Update display according to defaults set by biomux_obj
set(handles.Exp,'String',sprintf('%.9f',...
    get(handles.biomux_obj,'exposure')));
set(handles.Gain,'String',sprintf('%.1f',...
    get(handles.biomux_obj,'cameraGain')));
set(handles.Num_ave,'String',sprintf('%d',...
    get(handles.biomux_obj,'numFrames')));
set(handles.ROIox,'String',num2str(get(handles.biomux_obj,'XOffset')));
set(handles.ROIoy,'String',num2str(get(handles.biomux_obj,'YOffset')));
set(handles.ROIwidth,'String',num2str(get(handles.biomux_obj,'width')));
set(handles.ROIHeight,'String',num2str(get(handles.biomux_obj,'height')));
set(handles.disp_filename,'String',get(handles.biomux_obj,'dataFile'));
set(handles.disp_mirrorfile,'String',get(handles.biomux_obj,'mirrorFile'));
set(handles.Use_PD,'Value',get(handles.biomux_obj,'FlagPD'));
set(handles.Use_RefReg,'Value',get(handles.biomux_obj,'FlagRef'));
set(handles.Use_Mirror,'Value',get(handles.biomux_obj,'FlagMir'));
wav_list = get(handles.biomux_obj,'wavList'); list_str={};
for n=1:length(wav_list), list_str{n}=num2str(wav_list(n)); end;
set(handles.WavList,'String',list_str);
set(handles.CPU,'Value',1)
set(handles.SPause,'String',num2str(get(handles.biomux_obj,'superSweepPause')));
set(handles.figure1,'CloseRequestFcn',@closeGUI);

% Update handles structure
guidata(hObject, handles);

function Wavelength_Callback(hObject, eventdata, handles)
% hObject    handle to Wavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Wavelength as text
%        str2double(get(hObject,'String')) returns contents of Wavelength as a double
handles.biomux_obj = set(handles.biomux_obj,'wavelength',str2double(get(hObject,'String')));
disp('Wavelength set');
pause(0.5) %wait then display value biomux object determined

%Update display
set(handles.Wavelength,'String',sprintf('%.3f',get(handles.biomux_obj,'wavelength')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Wavelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Wavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function StepWav_Callback(hObject, eventdata, handles)
% hObject    handle to StepWav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StepWav as text
%        str2double(get(hObject,'String')) returns contents of StepWav as a double
handles.biomux_obj = set(handles.biomux_obj,'stepWav',str2double(get(hObject,'String')));
disp('StepWav set');
pause(0.5); %wait then display value biomux object determined

%Update displays
wav_list=get(handles.biomux_obj,'wavList'); list_str={};
for n=1:length(wav_list), list_str{n}=num2str(wav_list(n)); end;
set(handles.WavList,'String',list_str);
set(handles.StepWav,'String',sprintf('%.3f',get(handles.biomux_obj,'stepWav')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function StepWav_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepWav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in StartSweep.
function StartSweep_Callback(hObject, eventdata, handles)
% hObject    handle to StartSweep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=single_scan(handles.biomux_obj,handles);
guidata(hObject, handles);

% --- Executes on button press in StopSweep.
function StopSweep_Callback(hObject, eventdata, handles)
% hObject    handle to StopSweep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.biomux_obj=stop_supersweep(handles.biomux_obj);
disp('Stop super sweep')
guidata(hObject, handles);

function StartWav_Callback(hObject, eventdata, handles)
% hObject    handle to StartWav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartWav as text
%        str2double(get(hObject,'String')) returns contents of StartWav as a double
handles.biomux_obj = set(handles.biomux_obj,'startWav',str2double(get(hObject,'String')));
disp('Start wavelength set');
pause(0.5); %wait then display value biomux object determined

%Update displays
set(handles.StartWav,'String',sprintf('%.3f',get(handles.biomux_obj,'startWav')));
wav_list=handles.biomux_obj.wav_list; list_str={};
for n=1:length(wav_list), list_str{n}=num2str(wav_list(n)); end;
set(handles.WavList,'String',list_str);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function StartWav_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartWav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function StopWav_Callback(hObject, eventdata, handles)
% hObject    handle to StopWav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StopWav as text
%        str2double(get(hObject,'String')) returns contents of StopWav as a double
handles.biomux_obj = set(handles.biomux_obj,'stopWav',str2double(get(hObject,'String')));
disp('Stop wavelength set');
pause(0.5); %wait then display value biomux object determined

%Update displays
set(handles.StopWav,'String',sprintf('%.3f',get(handles.biomux_obj,'stopWav')));
wav_list=handles.biomux_obj.wav_list; list_str={};
for n=1:length(wav_list), list_str{n}=num2str(wav_list(n)); end;
set(handles.WavList,'String',list_str);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function StopWav_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StopWav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Exp_Callback(hObject, eventdata, handles)
% hObject    handle to Exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Exp as text
%        str2double(get(hObject,'String')) returns contents of Exp as a double
handles.biomux_obj = set(handles.biomux_obj,'exposure',str2double(get(hObject,'String')));
disp('Exposure time set');
pause(0.5); %wait then display value biomux object determined
set(handles.Exp,'String',sprintf('%.9f',get(handles.biomux_obj,'exposure')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Exp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Num_ave_Callback(hObject, eventdata, handles)
% hObject    handle to Num_ave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Num_ave as text
%        str2double(get(hObject,'String')) returns contents of Num_ave as a double
handles.biomux_obj = set(handles.biomux_obj,'numFrames',str2double(get(hObject,'String')));
disp('Num frames to average set');
pause(0.5); %wait then display value biomux object determined
set(handles.Num_ave,'String',sprintf('%d',get(handles.biomux_obj,'numFrames')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Num_ave_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Num_ave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ROIox_Callback(hObject, eventdata, handles)
% hObject    handle to ROIox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIox as text
%        str2double(get(hObject,'String')) returns contents of ROIox as a double
xoffset=str2double(get(hObject,'String'));
handles.biomux_obj = set(handles.biomux_obj,'XOffset',xoffset);
disp('XOffset set');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ROIox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ROIoy_Callback(hObject, eventdata, handles)
% hObject    handle to ROIoy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIoy as text
%        str2double(get(hObject,'String')) returns contents of ROIoy as a double
yoffset=str2double(get(hObject,'String'));
handles.biomux_obj = set(handles.biomux_obj,'YOffset',yoffset);
disp('YOffset set');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ROIoy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIoy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ROIwidth_Callback(hObject, eventdata, handles)
% hObject    handle to ROIwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIwidth as text
%        str2double(get(hObject,'String')) returns contents of ROIwidth as a double
width=str2double(get(hObject,'String'));
handles.biomux_obj = set(handles.biomux_obj,'Width',width);
disp('Width set');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ROIwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ROIHeight_Callback(hObject, eventdata, handles)
% hObject    handle to ROIHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIHeight as text
%        str2double(get(hObject,'String')) returns contents of ROIHeight as a double
height=str2double(get(hObject,'String'));
handles.biomux_obj = set(handles.biomux_obj,'Height',height);
disp('Height set');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ROIHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function FileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in livepreview.
function livepreview_Callback(hObject, eventdata, handles)
% hObject    handle to livepreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
preview(handles.biomux_obj);

% --- Executes on button press in CurvePeek.
function CurvePeek_Callback(hObject, eventdata, handles)
% hObject    handle to CurvePeek (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.biomux_obj=update_scan_num(handles.biomux_obj);
% f_name=data_fname(handles.biomux_obj,handles.biomux_obj.scansTaken,'DataSet');
% if(exist(f_name,'file')),
%     load(f_name);
%     x=ceil(size(data,2)*rand(1,3));
%     y=ceil(size(data,3)*rand(1,3));
%     plot(data_wav,reshape(data(:,x,y),length(data_wav),9));
%     %xlabel('Wavelength (nm)');
%     %ylabel('Intensity (a.u.)');
%     set(handles.axes1,'XColor',[1 0.753 0]);
%     set(handles.axes1,'YColor',[1 0.753 0]);
% else
%     warning(['Previous data set not found  ' f_name]);
% end;
error('Button Disabled');

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes1

% --- Executes on button press in TakeFrame.
function TakeFrame_Callback(hObject, eventdata, handles)
% hObject    handle to TakeFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
take_frame(handles.biomux_obj);

% --- Executes on button press in Save_Frame.
function Save_Frame_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp=take_frame(handles.biomux_obj);
data_wav=get(handles.biomux_obj,'wavelength');
if isfield(temp,'data_pd')
    data_pd=temp.data_pd;
else
    data_pd=1;
end
data_date=datestr(now);
frame = temp.data;
f_name=[get(handles.biomux_obj,'dataFile') 'Frame' data_date(13:14) data_date(16:17) data_date(19:20)];
iris_info.version = handles.version;
iris_info.instr = get(handles.biomux_obj,'Instrument');
save(f_name,'frame','data_pd','data_wav','data_date','iris_info')
disp(['saved: ' f_name]),

% --- Executes on button press in TakeHistogram.
function TakeHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to TakeHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
take_frame(handles.biomux_obj,'hist');
title('Histogram: Normalized to percent full','Color','w');
set(handles.axes1,'XLim',[0 1],'XColor','w','YColor','w');

% --- Executes on button press in DrySystem.
function DrySystem_Callback(hObject, eventdata, handles)
% hObject    handle to DrySystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Start drying system (takes ~10 minutes)')
drysys(handles.biomux_obj);
disp('Drying complete')

% --- Executes on button press in SweepHistogram.
function SweepHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to SweepHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = single_scan(handles.biomux_obj,handles,'hist');
guidata(hObject, handles);

% --- Executes on button press in SuperSweep.
function SuperSweep_Callback(hObject, eventdata, handles)
% hObject    handle to SuperSweep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.biomux_obj = set(handles.biomux_obj,'superSweepPause',str2double(get(handles.SPause,'String')));
handles.biomux_obj=super_sweep(handles.biomux_obj,handles);
guidata(hObject, handles);

% --- Executes on button press in use_mirror.
function Use_Mirror_Callback(hObject, eventdata, handles)
% hObject    handle to use_mirror (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_mirror
handles.biomux_obj = set(handles.biomux_obj,'FlagMir',get(hObject,'Value'));
if get(handles.biomux_obj,'FlagMir')
    disp('Using mirror reference');
else
    disp('Not using mirror reference');
end
pause(0.5); %wait then display value biomux object determined
set(handles.Use_Mirror,'Value',get(handles.biomux_obj,'FlagMir'));
guidata(hObject, handles);

% --- Executes on button press in use_pd.
function Use_PD_Callback(hObject, eventdata, handles)
% hObject    handle to use_pd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_pd
handles.biomux_obj = set(handles.biomux_obj,'FlagPD',get(hObject,'Value'));
if get(handles.biomux_obj,'FlagPD')
    disp('Using PD reference');
else
    disp('Not using PD reference');
end
pause(0.5); %wait then display value biomux object determined
set(handles.Use_PD,'Value',get(handles.biomux_obj,'FlagPD'));
guidata(hObject, handles);

% --- Executes on button press in disp_obj.
function disp_obj_Callback(hObject, eventdata, handles)
% hObject    handle to disp_obj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display(handles.biomux_obj);

% --- Executes on button press in mirror_scan.
function Mirror_Scan_Callback(hObject, eventdata, handles)
% hObject    handle to mirror_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = single_scan(handles.biomux_obj,handles,'mirror');
set(handles.disp_mirrorfile,'String',get(handles.biomux_obj,'mirrorFile'));
guidata(hObject, handles);


% --- Executes on selection change in WavList.
function WavList_Callback(hObject, eventdata, handles)
% hObject    handle to WavList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns WavList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WavList

%display contects of wav_list
wav_list=get(handles.biomux_obj,'wavList');
list_str={};
for n=1:length(wav_list),
    list_str{n}=num2str(wav_list(n));
end
set(handles.WavList,'String',list_str);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function WavList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WavList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function AddWav_Callback(hObject, eventdata, handles)
% hObject    handle to AddWav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AddWav as text
%        str2double(get(hObject,'String')) returns contents of AddWav as a double
wav_list=get(handles.biomux_obj,'wavList');
wav_input=str2double(get(hObject,'String'));
wav_list(length(wav_list)+1)=wav_input;
handles.biomux_obj = set(handles.biomux_obj,'wavList',wav_list);
pause(0.5);
set(handles.AddWav,'String','');

%display contents of wav_list
wav_list=get(handles.biomux_obj,'wavList');
list_str={};
for n=1:length(wav_list),
    list_str{n}=num2str(wav_list(n));
end;
set(handles.WavList,'String',list_str);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function AddWav_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AddWav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FitData.
function FitData_Callback(hObject, eventdata, handles)
% hObject    handle to FitData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get oxide thickness
ox_nominal = str2double(get(handles.Ox_Thickness,'String'));
if( ox_nominal<0 || ox_nominal>50000 )
    warning('Oxide thickness must be between 0 and 50000nm');
    ox_nominal = 500;
    set(handles.Ox_Thickness,'String',sprintf('%.0f',ox_nominal));
end;
disp(['Oxide Thickness is  ' num2str(ox_nominal)]);

fit_method=get(get(handles.fit_method,'SelectedObject'),'Tag');

switch fit_method
    case 'GPU'
        if(get(handles.InSolution,'Value')),
            disp('GPU Wet: Not implemented');
            %             disp('Fit accurately wet on the GPU')
            %             fitdata(handles.biomux_obj,handles.biomux_obj.wav_list,ox_nominal,'GPUwet');
        else
            disp('Fit accurately dry on the GPU')
            fitted = fitdata(handles.biomux_obj,ox_nominal,'GPUdry');
        end
    case 'CPU'
        if(get(handles.InSolution,'Value')),
            disp('CPU Wet: Not implemented');
            %             disp('Fit accurately wet on the CPU')
            %             fitdata(handles.biomux_obj,handles.biomux_obj.wav_list,ox_nominal,'CPUwet');
        else
            disp('CPU Dry: Not implemented');
            %             disp('Fit accurately dry on the CPU')
            %             fitdata(handles.biomux_obj,handles.biomux_obj.wav_list,ox_nominal,'CPUdry');
        end
        %     otherwise
        %         disp('Fit quickly by phase')
        %         fitdata(handles.biomux_obj,handles.biomux_obj.wav_list,ox_nominal,'phase');
end


% --- Executes on button press in FitPeek.
function FitPeek_Callback(hObject, eventdata, handles)
% hObject    handle to FitPeek (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.biomux_obj=update_scan_num(handles.biomux_obj);
f_name=data_fname(handles.biomux_obj,get(handles.biomux_obj,'scansTaken'),'Fitted');
if(exist(f_name,'file')),
    load(f_name);
    show(data_fitted',3);
else
    warning(['Fit data set not found  ' f_name]);
end;


% --- Executes on button press in InSolution.
function InSolution_Callback(hObject, eventdata, handles)
% hObject    handle to InSolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of InSolution



function Ox_Thickness_Callback(hObject, eventdata, handles)
% hObject    handle to Ox_Thickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ox_Thickness as text
%        str2double(get(hObject,'String')) returns contents of Ox_Thickness as a double
val=str2double(get(hObject,'String'));
if( val<0 || val>50000 ),
    warning('oxide thickness must be between 0 and 50000nm');
    set(handles.Ox_Thickness,'String',sprintf('%.0f',500));
else
    disp('Oxide thickness set for fitting');
end;


% --- Executes during object creation, after setting all properties.
function Ox_Thickness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ox_Thickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Apply.
function Apply_Callback(hObject, eventdata, handles)
% hObject    handle to Apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%don't apply if super sweep is running
apply_flag=1;
timerObj = get(handles.biomux_obj,'timerObj');
if(isa(timeObject,'timer') && isvalid(timerObj))
    if(strcmp(get(handles.biomux_obj.timerObj,'running'),'on'))
        apply_flag=0;
        warning(['Supersweep running - cannot apply settings']);
    end;
end;

if(apply_flag),
    %This function does two things
    % 1. it takes all the inputs from the GUI and sets the cooresponsing
    %    values in the object equal to them.  Note the object may reject some
    %    of these settings if they are inappropriate (error checking).
    % 2. it sets the display in the GUI equal to the values in the object.
    %    Note if the values were all ok, nothing will change.  The update is
    %    delayed 1 second for the user to see where values didn't stick.
    %
    %Set object according to GUI inputs
    %     handles.biomux_obj.valve=get(handles.ChanSelect,'Value');
    %     c=get(handles.ChanSelect,'Value');
    %     switch c,
    %         case 1, handles.biomux_obj.flow_bypass='y';
    %         case 0, handles.biomux_obj.flow_bypass='n';
    %     end;
    %     handles.biomux_obj.laser_power=str2double(get(handles.Power,'String'));
    %     handles.biomux_obj.wavelength=str2double(get(handles.Wavelength,'String'));
    %     handles.biomux_obj.step_wav=str2double(get(handles.StepWav,'String'));
    %     handles.biomux_obj.start_wav=str2double(get(handles.StartWav,'String'));
    %     handles.biomux_obj.stop_wav=str2double(get(handles.StopWav,'String'));
    handles.biomux_obj = set(handles.biomux_obj,'exposure',str2double(get(handles.Exp,'String')));
    handles.biomux_obj = set(handles.biomux_obj,'cameraGain',str2double(get(handles.Gain,'String')));
    handles.biomux_obj = set(handles.biomux_obj,'numFrames',str2double(get(handles.Num_ave,'String')));
    handles.biomux_obj = set(handles.biomux_obj,'ROI',[str2double(get(handles.ROIox,'String')) ...
        str2double(get(handles.ROIoy,'String')) ...
        str2double(get(handles.ROIwidth,'String')) ...
        str2double(get(handles.ROIHeight,'String'))]);
    handles.biomux_obj = set(handles.biomux_obj,'FlagPD',get(handles.Use_PD,'Value'));
    handles.biomux_obj = set(handles.biomux_obj,'FlagRef',get(handles.Use_RefReg,'Value'));
    handles.biomux_obj = set(handles.biomux_obj,'FlagMir',get(handles.Use_Mirror,'Value'));
    handles.biomux_obj = set(handles.biomux_obj,'superSweepPause',str2double(get(handles.SPause,'String')));
    
    %Give the user time to see if any display changes
    pause(1);
    
    %Set GUI inputs equal to object values
    %     set(handles.ChanSelect,'Value',handles.biomux_obj.valve);
    %     switch handles.biomux_obj.flow_bypass,
    %         case 'y', set(handles.ByPass,'Value',1);
    %         case 'n', set(handles.ByPass,'Value',0);
    %     end;
    %     set(handles.Power,'String',sprintf('%.3f',handles.biomux_obj.laser_power));
    %     set(handles.Wavelength,'String',sprintf('%.3f',handles.biomux_obj.wavelength));
    %     set(handles.StepWav,'String',sprintf('%.3f',handles.biomux_obj.step_wav));
    %     set(handles.StartWav,'String',sprintf('%.3f',handles.biomux_obj.start_wav));
    %     set(handles.StopWav,'String',sprintf('%.3f',handles.biomux_obj.stop_wav));
    set(handles.Exp,'String',sprintf('%.9f',get(handles.biomux_obj,'exposure')));
    set(handles.Gain,'String',sprintf('%.1f',get(handles.biomux_obj,'cameraGain')));
    set(handles.Num_ave,'String',sprintf('%d',get(handles.biomux_obj,'numFrames')));
    set(handles.ROIox,'String',num2str(get(handles.biomux_obj,'XOffset')));
    set(handles.ROIoy,'String',num2str(get(handles.biomux_obj,'YOffset')));
    set(handles.ROIwidth,'String',num2str(get(handles.biomux_obj,'Width')));
    set(handles.ROIHeight,'String',num2str(get(handles.biomux_obj,'Height')));
    set(handles.Use_PD,'Value',get(handles.biomux_obj,'FlagPD'));
    set(handles.Use_RefReg,'Value',get(handles.biomux_obj,'FlagRef'));
    set(handles.Use_Mirror,'Value',get(handles.biomux_obj,'FlagMir'));
    wav_list=get(handles.biomux_obj,'wavList'); list_str={};
    for n=1:length(wav_list), list_str{n}=num2str(wav_list(n)); end;
    set(handles.SPause,'String',num2str(get(handles.biomux_obj,'superSweepPause')));
    set(handles.WavList,'String',list_str);
    
    disp('Settings applied')
end;



function Gain_Callback(hObject, eventdata, handles)
% hObject    handle to Gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gain as text
%        str2double(get(hObject,'String')) returns contents of Gain as a double
handles.biomux_obj = set(handles.biomux_obj,'cameraGain',str2double(get(hObject,'String')));
disp('Camera gain set');
pause(0.5); %wait then display value biomux object determined
set(handles.Gain,'String',sprintf('%.1f',get(handles.biomux_obj,'cameraGain')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_roi.
function select_roi_Callback(hObject, eventdata, handles)
% hObject    handle to select_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get mouse clicks
waitforbuttonpress;
point1=round(get(gca,'CurrentPoint'));
waitforbuttonpress;
point2=round(get(gca,'CurrentPoint'));

%sort to allow user to select either corner set in any order
mouse_x1=min([point1(1,1) point2(1,1)]);
mouse_x2=max([point1(1,1) point2(1,1)]);
mouse_y1=min([point1(1,2) point2(1,2)]);
mouse_y2=max([point1(1,2) point2(1,2)]);

%check that values are within range
abort_flag=0;
if( mouse_x1<0 || mouse_y1<0 ),
    warning('mouse click beyond figure range - values unchanged');
    abort_flag=1;
elseif( mouse_x2-mouse_x1>handles.original_ROI(3) || mouse_y2-mouse_y1>handles.original_ROI(4) ),
    warning('mouse click beyond figure range - values unchanged');
    abort_flag=1;
end;

if(~abort_flag),
    
    %Calculate the roi values from the mouse clicks
    previous_roi = handles.original_ROI;
    roi(1) = mouse_x1 + previous_roi(1);
    roi(2) = mouse_y1 + previous_roi(2);
    roi(3) = mouse_x2 - mouse_x1;
    roi(4) = mouse_y2 - mouse_y1;
    
    %Set the handles roi values
    set(handles.ROIox,'String',num2str(roi(1)));
    set(handles.ROIoy,'String',num2str(roi(2)));
    set(handles.ROIwidth,'String',num2str(roi(3)));
    set(handles.ROIHeight,'String',num2str(roi(4)));
    
    %Set the biomux object's roi values
    handles.biomux_obj = set(handles.biomux_obj,'ROI',roi);
    
    %Display a new frame
    frame=take_frame(handles.biomux_obj);
    
    guidata(hObject, handles);
end;


% --- Executes on button press in reconnect.
function reconnect_Callback(hObject, eventdata, handles)
% hObject    handle to reconnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%close connection to devices
handles.biomux_obj=close_connections(handles.biomux_obj);

%Reset devices
imaqreset
if handles.las_inst~='none', instrreset, end %reset the laser only if it is connected

%Reintantiate devices
handles.biomux_obj=reinit_hw(handles.biomux_obj);

guidata(hObject, handles);


% --- Executes on button press in zoom_out.
function zoom_out_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Set the roi back to the original values
roi = handles.original_ROI;

%Set the handles roi values
set(handles.ROIox,'String',num2str(roi(1)));
set(handles.ROIoy,'String',num2str(roi(2)));
set(handles.ROIwidth,'String',num2str(roi(3)));
set(handles.ROIHeight,'String',num2str(roi(4)));

%Set the biomux object's roi values
handles.biomux_obj.roi = roi;

%Display a new frame
frame=take_frame(handles.biomux_obj);

guidata(hObject, handles);


% --- Executes on button press in load_file.
function load_file_Callback(hObject, eventdata, handles)
% hObject    handle to load_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% disp(handles.biomux_obj.filename)
%get selected filename
[file_name,path]=uigetfile('*.mat','Select File to Load',handles.default_path);

name_given=strcat(path,file_name);
handles.biomux_obj = set(handles.biomux_obj,'dataFile',name_given);
set(handles.disp_filename,'String',get(handles.biomux_obj,'dataFile'));

%close connection to devices
handles.biomux_obj=close_connections(handles.biomux_obj);

%load in data
p=load(name_given);

if(isa(p.b_obj,'biomux')),
    handles.biomux_obj=p.b_obj;
    
    %Update display according to defaults set by biomux_obj
    %     set(handles.ChanSelect,'Value',handles.biomux_obj.valve);
    %     switch handles.biomux_obj.flow_bypass,
    %         case 'y', set(handles.ByPass,'Value',1);
    %         case 'n', set(handles.ByPass,'Value',0);
    %     end;
    %     set(handles.Power,'String',sprintf('%.3f',handles.biomux_obj.laser_power));
    %     set(handles.Wavelength,'String',sprintf('%.3f',handles.biomux_obj.wavelength));
    %     set(handles.StepWav,'String',sprintf('%.3f',handles.biomux_obj.step_wav));
    %     set(handles.StartWav,'String',sprintf('%.3f',handles.biomux_obj.start_wav));
    set(handles.StopWav,'String',sprintf('%.3f',get(handles.biomux_obj,'stopWav')));
    set(handles.Exp,'String',sprintf('%.9f',get(handles.biomux_obj,'exposure')));
    set(handles.Gain,'String',sprintf('%.1f',get(handles.biomux_obj,'cameraGain')));
    set(handles.Num_ave,'String',sprintf('%d',get(handles.biomux_obj,'numFrames')));
    set(handles.ROIox,'String',num2str(get(handles.biomux_obj,'XOffset')));
    set(handles.ROIoy,'String',num2str(get(handles.biomux_obj,'YOffset')));
    set(handles.ROIwidth,'String',num2str(get(handles.biomux_obj,'Width')));
    set(handles.ROIHeight,'String',num2str(get(handles.biomux_obj,'Height')));
    set(handles.Use_PD,'Value',get(handles.biomux_obj,'FlagPD'));
    set(handles.Use_RefReg,'Value',get(handles.biomux_obj,'FlagRef'));
    set(handles.Use_Mirror,'Value',get(handles.biomux_obj,'FlagMir'));
    set(handles.disp_mirrorfile,'String',get(handles.biomux_obj,'mirrorFile'));
    wav_list=get(handles.biomux_obj,'wavList'); list_str={};
    for n=1:length(wav_list), list_str{n}=num2str(wav_list(n)); end;
    set(handles.WavList,'String',list_str);
    set(handles.SPause,'String',num2str(get(handles.biomux_obj,'superSweepPause')));
    disp('object parameters loaded')
else
    disp('failed to load object paramers')
end;

%Reintantiate devices
handles.biomux_obj=reinit_hw(handles.biomux_obj);
disp('reconnected')

guidata(hObject, handles);

% --- Executes on button press in file_name.
function file_name_Callback(hObject, eventdata, handles)
% hObject    handle to file_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get user's desired output filename and location
[file_name,path]=uiputfile('*.mat','Select Save Name',handles.default_path);
f_name=strcat(path,file_name);
name_given=f_name(1:length(f_name)-4);

handles.biomux_obj = set(handles.biomux_obj,'dataFile',name_given);
set(handles.disp_filename,'String',get(handles.biomux_obj,'dataFile'));
disp('Filename set');
guidata(hObject, handles);


% --- Executes on button press in mirror_file.
function mirror_file_Callback(hObject, eventdata, handles)
% hObject    handle to mirror_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get user's desired mirror file
[file_name,path]=uigetfile('*.mat','Select Mirror File',handles.default_path);
handles.biomux_obj = set(handles.biomux_obj,'mirrorFile',strcat(path,file_name));
set(handles.disp_mirrorfile,'String',get(handles.biomux_obj,'mirrorFile'));

disp('Mirror filename set');

guidata(hObject, handles);

% --- Executes on close of GUI
function closeGUI(hObject, eventdata, handles)
% hObject    handle to ShutDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(gcbo);
handles.biomux_obj=shutdown(handles.biomux_obj);
disp('Shutdown');
delete(gcf)

% --- Executes on button press in Use_RefReg.
function Use_RefReg_Callback(hObject, eventdata, handles)
% hObject    handle to Use_RefReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Use_RefReg
handles.biomux_obj = set(handles.biomux_obj,'FlagRef',get(hObject,'Value'));
if get(handles.biomux_obj,'FlagRef')
    disp('Using Reference Region');
else
    disp('Not using reference region');
end
pause(0.5); %wait then display value biomux object determined
set(handles.Use_RefReg,'Value',get(handles.biomux_obj,'FlagRef'));
guidata(hObject, handles);

% --- Executes on button press in DefineRef.
function DefineRef_Callback(hObject, eventdata, handles)
% hObject    handle to DefineRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get mouse clicks
waitforbuttonpress;
point1=round(get(gca,'CurrentPoint'));
waitforbuttonpress;
point2=round(get(gca,'CurrentPoint'));

%sort to allow user to select either corner set in any order
mouse_x1=min([point1(1,1) point2(1,1)]);
mouse_x2=max([point1(1,1) point2(1,1)]);
mouse_y1=min([point1(1,2) point2(1,2)]);
mouse_y2=max([point1(1,2) point2(1,2)]);

%check that values are within range
abort_flag=0;
XLim=get(gca,'XLim');
YLim=get(gca,'YLim');
if( mouse_x1<0 || mouse_y1<0 ),
    warning('mouse click beyond figure range - values unchanged');
    abort_flag=1;
elseif( mouse_x2>XLim(2) || mouse_y2>YLim(2) ),
    warning('mouse click beyond figure range - values unchanged');
    abort_flag=1;
end;

if(~abort_flag),
    handles.biomux_obj = set(handles.biomux_obj,'refRegion',[mouse_x1 mouse_y1 (mouse_x2-mouse_x1) (mouse_y2-mouse_y1)]);
    rectangle('Position',get(handles.biomux_obj,'refRegion'),'LineStyle','-','EdgeColor','w','LineWidth',1);
end;

guidata(hObject, handles);

% --- Executes on button press in ShowRef.
function ShowRef_Callback(hObject, eventdata, handles)
% hObject    handle to ShowRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of ShowRef
rectangle('Position',get(handles.biomux_obj,'refRegion'),'LineStyle','-','EdgeColor','w','LineWidth',1);

% --- Executes on button press in LED1.
function LED1_Callback(hObject, eventdata, handles)
% hObject    handle to LED1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of LED1
wav_list=get(handles.biomux_obj,'wavList');
if(get(hObject,'Value')),
    wavelength=wav_list(1);
    handles.biomux_obj = set(handles.biomux_obj,'wavelength',wavelength);
end;
disp(['Wavelength set to:  ' num2str(wavelength) ' nm']);
guidata(hObject, handles);

% --- Executes on button press in LED2.
function LED2_Callback(hObject, eventdata, handles)
% hObject    handle to LED2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of LED2
wav_list=get(handles.biomux_obj,'wavList');
wavelength=get(handles.biomux_obj,'wavelength');
if(get(hObject,'Value') && size(wav_list,2)>=2),
    wavelength=wav_list(2);
    set(handles.biomux_obj,'wavelength',wavelength);
end;
disp(['wavelength set to:  ' num2str(wavelength) ' nm']);
guidata(hObject, handles);

% --- Executes on button press in LED3.
function LED3_Callback(hObject, eventdata, handles)
% hObject    handle to LED3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of LED3
wav_list=get(handles.biomux_obj,'wavList');
wavelength=get(handles.biomux_obj,'wavelength');
if(get(hObject,'Value') && size(wav_list,2)>=3),
    wavelength=wav_list(3);
    handles.biomux_obj = set(handles.biomux_obj,'wavelength',wavelength);
end;
disp(['wavelength set to:  ' num2str(wavelength) ' nm']);
guidata(hObject, handles);

% --- Executes on button press in LED4.
function LED4_Callback(hObject, eventdata, handles)
% hObject    handle to LED4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of LED4
wav_list=get(handles.biomux_obj,'wavList');
wavelength=get(handles.biomux_obj,'wavelength');
if(get(hObject,'Value') && size(wav_list,2)>=4),
    wavelength=wav_list(4);
    handles.biomux_obj = set(handles.biomux_obj,'wavelength',wavelength);
    disp(['wavelength set to:  ' num2str(wavelength) ' nm']);
else
    handles.biomux_obj = set(handles.biomux_obj,'wavelength',wavelength);
    disp(['wavelength unchanged. ' num2str(wavelength) ' nm']);
end;
guidata(hObject, handles);

% --- Executes on button press in LED5.
function LED5_Callback(hObject, eventdata, handles)
% hObject    handle to LED5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of LED5
wav_list=get(handles.biomux_obj,'wavList');
wavelength=get(handles.biomux_obj,'wavelength');
if(get(hObject,'Value') && size(wav_list,2)>=5),
    wavelength=wav_list(5);
    handles.biomux_obj = set(handles.biomux_obj,'wavelength',wavelength);
    disp(['wavelength set to:  ' num2str(wavelength) ' nm']);
else
    handles.biomux_obj = set(handles.biomux_obj,'wavelength',wavelength);
    disp(['wavelength unchanged. ' num2str(wavelength) ' nm']);
end;
guidata(hObject, handles);

% --- Executes on button press in LED6.
function LED6_Callback(hObject, eventdata, handles)
% hObject    handle to LED6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of LED6
wav_list=get(handles.biomux_obj,'wavList');
wavelength=get(handles.biomux_obj,'wavelength');
if(get(hObject,'Value') && size(wav_list,2)>=6),
    wavelength=wav_list(6);
    handles.biomux_obj = set(handles.biomux_obj,'wavelength',wavelength);
    disp(['wavelength set to:  ' num2str(wavelength) ' nm']);
else
    handles.biomux_obj = set(handles.biomux_obj,'wavelength',wavelength);
    disp(['wavelength unchanged. ' num2str(wavelength) ' nm']);
end;
guidata(hObject, handles);

% --- Executes on button press in LED_Off.
function LED_Off_Callback(hObject, eventdata, handles)
% hObject    handle to LED_Off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of LED_Off
if(get(hObject,'Value')),
    handles.biomux_obj = set(handles.biomux_obj,'wavelength',0);
end;
guidata(hObject, handles);

function SPause_Callback(hObject, eventdata, handles)
% hObject    handle to SPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SPause as text
%        str2double(get(hObject,'String')) returns contents of SPause as a double
handles.biomux_obj = set(handles.biomux_obj,'superSweepPause',str2double(get(handles.SPause,'String')));
pause(0.25);
set(handles.SPause,'String',num2str(get(handles.biomux_obj,'superSweepPause')));
disp(['Pause between sweeps set'])
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SPause_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text36_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: get(hObject,'Value') returns toggle state of autofit

