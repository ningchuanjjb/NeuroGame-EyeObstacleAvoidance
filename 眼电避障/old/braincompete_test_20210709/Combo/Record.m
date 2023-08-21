function varargout = Record(varargin)
% 使用电生理一体机设备运行Matlab数据采集程序。
% RECORD MATLAB code for Record.fig
%      RECORD, by itself, creates a new RECORD or raises the existing
%      singleton*.
%
%      H = RECORD returns the handle to a new RECORD or the handle to
%      the existing singleton*.
%
%      RECORD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECORD.M with the given input arguments.
%
%      RECORD('Property','Value',...) creates a new RECORD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Record_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Record_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Record

% Last Modified by GUIDE v2.5 16-May-2016 22:11:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Record_OpeningFcn, ...
                   'gui_OutputFcn',  @Record_OutputFcn, ...
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

% --- Executes just before Record is made visible.
function Record_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Record (see VARARGIN)

% Choose default command line output for Record
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using Record.
if strcmp(get(hObject,'Visible'),'off')
    % plot(rand(5));
end

global dirty
dirty = 0;					% 文档脏标记

% UIWAIT makes Record wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Record_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});



function edit_record_time_Callback(hObject, eventdata, handles)
% hObject    handle to edit_record_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_record_time as text
%        str2double(get(hObject,'String')) returns contents of edit_record_time as a double


% --- Executes during object creation, after setting all properties.
function edit_record_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_record_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_filename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filename as text
%        str2double(get(hObject,'String')) returns contents of edit_filename as a double


% --- Executes during object creation, after setting all properties.
function edit_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dirty
if dirty == 1
	choice = questdlg('数据尚未保存，继续采集会丢失前面采集的数据。是否仍要丢弃数据并开始采集新数据？','警告', 'Yes','No', 'No');
	if strcmp(choice,'No')
		return
	end
end
save('tempData', 'hObject', 'eventdata', 'handles', 'dirty');
clear all
load('tempData', 'hObject', 'eventdata', 'handles', 'dirty');
global data port ExtAdc freeze windowStartPosition windowEndPosition endPoint ax startMark Running Yscale freqScale h
% 0. 设置初值
startMark = 1;								% 给滚动条识别的起始标记
set(handles.pushbutton_stop,'UserData', 0);	% 停止条件
set(handles.slider_data_position, 'Value', 1);		% 滚动条放到最后
if isempty(get(handles.pushbutton_spectrom_hide , 'UserData'))
	set(handles.pushbutton_spectrom_hide , 'UserData', 1);	% 开启时频图显示
end
Yscale = 100;								% 显示范围±100uV
freqScale = 0.12;							% 频率显示到31.25Hz（0.25×500Hz）
Running = 0;								% 正在运行的标记
% 1. 打开设备
delete(instrfindall);						% 先关闭所有串口
com = ComboQuery;							% com为字符串数组，包含所有的电生理一体机设备名称
h = ComboOpen(com(1,:));					% 打开第一个设备

% 2. 采集数据。这段可以重复多次进行。
ax(1) = handles.axes_data;		hold off;
ax(2) = handles.axes_ext_adc;	hold off;
ax(3) = handles.axes_port;		hold off;
linkaxes(ax,'x')							% 联轴缩放
nDuration = str2double(get(handles.edit_record_time, 'String'));	% 取得采集时间，单位秒
nLength = (nDuration+1) * 30000;
data = zeros(nLength, 1);
port = zeros(nLength, 1, 'uint8');
ExtAdc = zeros(nLength, 2);
t1 = tic;
startPoint = 1;
Running = 1;								% 正在运行的标记
dirty = 1;									% 有新数据的标志
while 1
	len = ComboGetLength(h);				% 取得一体机内已经采集的数据长度
	[A, E, P] = ComboGetData(h, len);		% 根据已有数据长度，读出数据
	endPoint = startPoint + len - 1;		% 记录数据末尾的位置
	% data = [data, double(A).*9.9341e-09];	% 1 LSB = ±2.5V/30/2^24
	%ExtAdc = [ExtAdc; double((2048 - E') .* 10) / 4095];	% 满度±10V，反相放大输入
	data(startPoint:endPoint) = double(A).*9.9341e-09;	% 1 LSB = ±2.5V/30/2^24
	port(startPoint:endPoint) = P;
	ExtAdc(startPoint:endPoint,:) = double((2048 - E') .* 10) / 4095;	% 满度±10V，反相放大输入
	t2 = toc(t1);
	% 如果固定显示，则重新计算并设置slider位置
	if (freeze)
		% 不能在这里频繁改变滚动条，否则滚动条消息得到的数值永远是在这里改变后的位置
	else
		windowStartPosition = max(1, endPoint-3*30000);			% 显示最后3秒的数据
		windowEndPosition = endPoint;							% 显示最后3秒的数据
		set(handles.text_time, 'String', strcat(num2str(t2), ' s'));
	end
	plotData(handles);
	if (t2 >= nDuration)										% 采集nDuration秒
		break;
	end
	if (get(handles.pushbutton_stop, 'UserData') == 1)			% 按下了停止键
		break;
	end
	pause(0.001)												% 帮助调度，否则其它程序运行困难
	startPoint = endPoint + 1;
end
Running = 0;								% 正在运行的标记
% linkaxes(ax,'x')							% 联轴缩放
% 截断数据，抛弃未采集的空数据
data = data(1:endPoint);
ExtAdc = ExtAdc(1:endPoint, :);
port = port(1:endPoint);
% 将数据保存在任一控件（此处为start按钮）名下，以防函数返回之后数据丢失
% 注意：不能保存在base workspace中，因为那样只能在matlab环境中运行m脚本，要做成.exe可执行文件，则base workspace不存在，数据就丢失了。
setappdata(handles.pushbutton_start,'data',data);
setappdata(handles.pushbutton_start,'ExtAdc',ExtAdc);
setappdata(handles.pushbutton_start,'port',port);

% 3. 关闭设备并退出
ComboClose(h)								% 关闭设备
delete('tempData.mat');


% 用来画信号曲线图的函数。由Slider和Start回调函数调用
function plotData(handles)
global data port ExtAdc windowStartPosition windowEndPosition ax Yscale freqScale h
try
Ncomp = int32(floor(single(windowEndPosition - windowStartPosition) / 30));	% 30倍数据压缩后的数据量
dataRange = windowEndPosition-Ncomp*30+1:windowEndPosition;					% 显示的数据范围
viewEEG = mean(reshape(data(dataRange), 30, Ncomp), 1);			% EEG数据压缩30倍
viewExt = squeeze(mean(reshape(ExtAdc(dataRange,:), 30, Ncomp, 2), 1));	% 同步信号压缩30倍
plot(ax(1), viewEEG)											% 显示ADC24数据
ylim(ax(1), [-Yscale*1e-6 Yscale*1e-6]);
plot(ax(2), viewExt)											% 显示同步信号数据
% clear DI;
DI(:,1) = bitget(port(dataRange), 1) * 0.8 + 0;					% 取出PB9(port端口的0通道)
DI(:,2) = bitget(port(dataRange), 2) * 0.8 + 1;					% 取出PC6(port端口的1通道)
DI(:,3) = bitget(port(dataRange), 3) * 0.8 + 2;					% 取出PC7(port端口的2通道)
DI(:,4) = bitget(port(dataRange), 4) * 0.8 + 3;					% 取出PC8(port端口的3通道)
plot(ax(3), squeeze(mean(reshape(DI, [30 Ncomp 4]), 1)));		% 绘制端口数据
ylim(ax(3), [0 4])
hold off
% len = (floor(length(viewEEG)/4))*4;								% 做时频图，长度缩短4倍，
% specEEG = mean(reshape(viewEEG(1:len), 4, len/4), 1);			%  重采样到250 sps
% if length(specEEG) >= 64
% 	[S,F,T,P] = spectrogram(specEEG,64,63,1024,250);			% 计算时频图
% 	freqTop = floor(length(F) * freqScale);
% 	surf(handles.axes_spectrom, T,F(1:freqTop),10*log10(P(1:freqTop,:)),'edgecolor','none'), axis tight, view(0,90)	% 显示
% end
bIsShow = get(handles.pushbutton_spectrom_hide , 'UserData');
if bIsShow && (length(viewEEG) >= 512)
	[S,F,T,P] = spectrogram(viewEEG,512,510,2048,1E3);			% 计算时频图
	freqTop = floor(length(F) * freqScale);
	surf(handles.axes_spectrom, T,F(1:freqTop),10*log10(P(1:freqTop,:)),'edgecolor','none'), axis tight, view(0,90)	% 显示
end
catch err
	ComboClose(h)											% 发生错误时关闭设备
	err
	error(err)
end

% --- Executes on slider movement.
function slider_data_position_Callback(hObject, eventdata, handles)
% hObject    handle to slider_data_position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global data port ExtAdc freeze windowStartPosition windowEndPosition endPoint startMark Running
persistent lastPos lastEndPoint;
if startMark										% 第一次回滚时，设置静态变量初值
	startMark = 0;
	lastPos = 1;
	lastEndPoint = 1;
end
if isempty(lastEndPoint)
	lastEndPoint = 1;
end
if isempty(freeze)
	freeze = 0;
end
if isempty(lastPos)
	lastPos = 1;
end
% position范围是[0..1]，点击箭头的步长0.001。
pos = get(hObject,'Value');
% 更新滚动条位置
% if endPoint > 2*30000
% 	position = min(1.0, double(windowStartPosition) / double(endPoint-2*30000));	% 每次采集都更新当前显示窗口在整体数据中的位置
% 	set(handles.slider_data_position, 'Value', position);
% end
% set(hObject, 'Value', (minor+maxor)/2);
if pos==1
	freeze = 0;										% 凝固时间的标志，=0，用新数据刷新窗口
	windowStartPosition = max(1, endPoint-2*30000);	% 显示最后2秒的数据
	windowEndPosition = endPoint;					% 显示最后2秒的数据
else
	if freeze ~= 1							% 刚刚接收到凝固指令
		freeze = 1;								% 凝固时间的标志，=1，不再刷新窗口
		lastPos = 1;
		lastEndPoint = endPoint;
	end
	%else									% 以前就是凝固的，现在更新。要区分是否点击了箭头
		lastPoint = lastPos * lastEndPoint;		% 计算上次位置的点索引号
		thisPoint = pos * endPoint;				% 计算本次位置的点索引号
		posChange = double(abs(thisPoint-lastPoint))/double(endPoint);	% 位置改变的百分比
		if posChange < 0.002					% 通过点击箭头改变的位置
			if thisPoint < lastPoint				% 向前翻篇
				windowStartPosition = max(1, windowStartPosition-0.5*30000);	% 一次翻0.5秒的数据
			else									% 向后翻篇
				windowStartPosition = min(endPoint-2*30000+1, windowStartPosition+0.5*30000);	% 一次翻0.5秒的数据
			end
			windowEndPosition = min(endPoint, windowStartPosition+2*30000);
			if endPoint > 2*30000
				pos = min(1, double(windowStartPosition) / double(endPoint-2*30000));	% 更新当前显示窗口在整体数据中的位置
				set(hObject,'Value', pos);
			end
		else									% 通过拖动滚条改变的位置
			if endPoint > 2*30000
				windowStartPosition = (endPoint-2*30000) * pos;
				windowEndPosition = windowStartPosition + 2*30000;
			else
				windowStartPosition = 1;
				windowEndPosition = endPoint;
			end
		end
		lastPos = pos;
	%end
end
set(handles.text_time, 'String', strcat(num2str(double(windowStartPosition)/30000.0), ' s'));
lastEndPoint = endPoint;
plotData(handles);

% --- Executes on button press in pushbutton_dir.
function pushbutton_dir_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder_name = uigetdir;
set(handles.pushbutton_dir,'UserData',folder_name);


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dirty
folder_name = strcat(get(handles.pushbutton_dir, 'UserData'), '\');
file_name = strcat(folder_name, get(handles.edit_filename, 'String'));
data = getappdata(handles.pushbutton_start,'data');
ExtAdc = getappdata(handles.pushbutton_start,'ExtAdc');
port = getappdata(handles.pushbutton_start,'port');
uisave({'data', 'ExtAdc', 'port'}, file_name);
dirty = 0;

% --- Executes on button press in pushbutton_scale_up.
function pushbutton_scale_up_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_scale_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Yscale Running
switch Yscale
	case 1
		Yscale = 1;
	case 2
		Yscale = 1;
	case 5
		Yscale = 2;
	case 10
		Yscale = 5;
	case 20
		Yscale = 10;
	case 50
		Yscale = 20;
	case 100
		Yscale = 50;
	case 200
		Yscale = 100;
	case 500
		Yscale = 200;
	case 1000
		Yscale = 500;
	case 2000
		Yscale = 1000;
	case 5000
		Yscale = 2000;
	case 10000
		Yscale = 5000;
	case 20000
		Yscale = 10000;
	case 50000
		Yscale = 20000;
	case 100000
		Yscale = 50000;
end
if Running == 0
	plotData(handles);
end

% --- Executes on button press in pushbutton_scale_down.
function pushbutton_scale_down_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_scale_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Yscale Running
switch Yscale
	case 1
		Yscale = 2;
	case 2
		Yscale = 5;
	case 5
		Yscale = 10;
	case 10
		Yscale = 20;
	case 20
		Yscale = 50;
	case 50
		Yscale = 100;
	case 100
		Yscale = 200;
	case 200
		Yscale = 500;
	case 500
		Yscale = 1000;
	case 1000
		Yscale = 2000;
	case 2000
		Yscale = 5000;
	case 5000
		Yscale = 10000;
	case 10000
		Yscale = 20000;
	case 20000
		Yscale = 50000;
	case 50000
		Yscale = 100000;
	case 100000
		Yscale = 100000;
end
if Running == 0
	plotData(handles);
end

% --- Executes during object creation, after setting all properties.
function slider_data_position_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_data_position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_stop.
function pushbutton_stop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton_stop,'UserData',1);


% --- Executes on button press in pushbutton_freq_expand.
function pushbutton_freq_expand_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_freq_expand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global freqScale Running
if freqScale < 1
	freqScale = freqScale / 0.8;
end
if freqScale > 1
	freqScale = 1.0;
end
if Running == 0
	plotData(handles);
end

% --- Executes on button press in pushbutton_freq_shrink.
function pushbutton_freq_shrink_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_freq_shrink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global freqScale Running
if freqScale > 0.01
	freqScale = freqScale * 0.8;
end
if freqScale < 0.01
	freqScale = 0.01;
end
if Running == 0
	plotData(handles);
end


% --- Executes on button press in pushbutton_spectrom_hide.
function pushbutton_spectrom_hide_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_spectrom_hide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
bIsShow = get(hObject, 'UserData');
if (bIsShow == 0)
	bIsShow = 1;
	set(hObject, 'String', '停滞');
else
	bIsShow = 0;
	set(hObject, 'String', '刷新');
end
set(handles.pushbutton_spectrom_hide , 'UserData', bIsShow);
