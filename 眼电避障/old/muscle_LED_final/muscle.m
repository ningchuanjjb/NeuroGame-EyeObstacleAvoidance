% Stop键回调函数响应不上，是没有等待绘图完成就继续循环采集，导致绘图任务抢占CPU，从而无法响应按钮事件。
% 用drawnow等待绘图完成，就可以响应按钮了。
% 2020年8月18日 05:38:20

function varargout = BrainScore(varargin)
% BRAINSCORE MATLAB code for BrainScore.fig
%      BRAINSCORE, by itself, creates a new BRAINSCORE or raises the existing
%      singleton*.
%

%      H = BRAINSCORE returns the handle to a new BRAINSCORE or the handle to
%      the existing singleton*.
%
%      BRAINSCORE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BRAINSCORE.M with the given input arguments.
%
%      BRAINSCORE('Property','Value',...) creates a new BRAINSCORE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BrainScore_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BrainScore_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BrainScore

% Last Modified by GUIDE v2.5 18-Aug-2020 05:47:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BrainScore_OpeningFcn, ...
                   'gui_OutputFcn',  @BrainScore_OutputFcn, ...
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


% --- Executes just before BrainScore is made visible.
function BrainScore_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BrainScore (see VARARGIN)
% global bIsStart  hCombo
% global hr;
% Choose default command line output for BrainScore
delete(instrfindall);						% 先关闭所有串口
handles.output = hObject;
% handles.pushbuttonStart.Enable = 'off';
% handles.pushbuttonFinishi.Enable = 'off';
handles.pushbuttonStart.Enable = 'on';
handles.pushbuttonFinish.Enable = 'on';
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BrainScore wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BrainScore_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global hCombo;
% global hr;
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonStart.
function pushbuttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bIsStart bIsShow hCombo
% global hr;
try
% 1. 打开设备

DevNo = 1;					% 使用第一个设备
PB6 = 1; PB7 = 2; PB8 = 4; PB9 = 8;		% 输出端口对应的数值
DOPort = 2986;				% DO Port输出
DIPort = 1194;				% DI Port输入
DAC = 6058;					% DAC输出
GetADC = 4778;				% ADC多通道采集一次
delete(instrfindall)
K = DeviceQuery();
if isempty(K)
	warning('没有找到STM32DAQ设备，请接入设备后重试');
	return;
end

% 新版的Matlab不支持以0结尾的字符串作为设备名，
% 仅支持纯净的设备名字符串，名字的长度必须等于设备名字串长度，
% 后面不得有包括NUL在内的任何内容
% 下面的程序段是将系统返回的设备名的尾巴截干净，并保存到元胞数组中。
% 有几个设备，元胞数组就有几个元素，每个元素是一个干净的设备名。
for ii = 1:size(K,1)
	for jj = 1:size(K,2)
		if K(ii, jj) ~= 0
            continue;						% 跳过所有的有效字符
        else
            dev(ii) = {K(ii, 1:(jj-1))};	% 遇到无效字符，截断，取前面有效的部分放到元胞数组中。
			break;
		end
	end
end

% 打开第一个串口设备
hDevice = serial(dev(DevNo),'baudrate',119200);
fopen(hDevice);

com = ComboQuery;							% com为字符串数组，包含所有的电生理一体机设备名称
if isempty(com)
	msgbox('没有找到电生理综合测试仪，请接入设备后重试');
	fclose(hDevice);
	return;
end

hCombo = ComboOpen(com(1,:));				% 打开电生理综合测试仪设备

bIsStart = 1;
% 2. 采集数据。这段可以重复多次进行。
nDuration = 10;								% 设定显示时间10秒
Fs = 30000;									% 电生理综合测试仪原生采样率
nSize = nDuration * Fs;
nLength = (nDuration+1) * Fs;
datal = zeros(nSize, 1);
Aresiduall = [];
nCompress = 100;							% 信号时间压缩比为100倍
nFs = Fs / nCompress;						% 压缩后的采样率
dT = 1 / nFs;								% 压缩后的采样间隔
Thresh = 5*10^-12;
t1 = tic;
startPoint = 1;
endPoint = 1;
bIsShow = 1;
freqScale = 0.35;	% [0..1]
strBytes = 0;
ax(1) = handles.axes1;		hold off;
ax(2) = handles.axes2;		hold off;
linkaxes(ax,'x')							% 联轴缩放
while bIsStart
	lenl = ComboGetLength(hCombo);			% 取得一体机内已经采集的数据长度
	[Al, El, Pl] = ComboGetData(hCombo, lenl);	% 根据已有数据长度，读出数据
	endPoint = startPoint + lenl - 1;
	tdatal = [datal; Aresiduall; double(Al').*9.9341e-09];	% 1 LSB = ±2.5V/30/2^24
	posl = floor(length(tdatal) / nCompress) * nCompress;
	Aresiduall = tdatal((posl+1):end);
	if posl > nSize
		datal = tdatal(posl-nSize+1 : posl);
    end
	viewEEGl = mean(reshape(datal, nCompress, nSize/nCompress), 1);		% EEG数据压缩nCompress(100)倍
   
    plot(ax(1), (1:length(viewEEGl))/nFs, viewEEGl)					% 显示ADC24数据
	xlabel(ax(1), '时间（秒）')
	ylabel(ax(1), '电压（伏特）')
	if bIsShow
		[Sl,Fl,Tl,Pl] = spectrogram(viewEEGl, 256, 250, 1024, 300);			% 计算时频图
		freqTopl = floor(length(Fl) * freqScale);
% 		surf(ax(2), Tl, Fl(1:freqTopl), 10*log10(Pl(1:freqTopl,:)),'edgecolor','none'), axis tight, view(0,90)	% 显示
    	ssl = surf(ax(2), Tl, Fl(1:freqTopl), 10*log10(Pl(1:freqTopl,:)),'edgecolor','none');view(2);%axis tight 	% 显示
		ylabel(ax(2), '频率（Hz）')
		xlim([0,10]);
	end
    hold off

% 	% fft计算频谱
% 	NN = length(viewEEG);
% 	f0 = 1 / (dT*NN);						% 基频
% 	f = (0:ceil((NN-1)/2)) * f0;			% 频率序列
% 	y = abs(fft(viewEEG, length(viewEEG)));
% 	figure, plot(f, 2*y(1:ceil((NN-1)/2)+1)), xlabel('频率/Hz')
	% 取4-10Hz : 40-150Hz的能量比值
	EFl = ceil([25 40] / Fl(2));
    EFlbase = ceil([10 15] / Fl(2));
%     EFr = ceil([20 40] / Fr(2));
	Energyl = mean(mean(Pl(EFl(1):EFl(2), 400:end), 2), 1);
	Energylbase = mean(mean(Pl(EFlbase(1):EFlbase(2), 400:end), 2), 1);
    % 在PA4（DAC1通道）、PA5端口（DAC2通道）输出模拟信号
    CMD(1) = DAC;			% DAC指令
    CMD(2) = 1;				% 选择DAC通道。=0, DAC1通道；=1, DAC2通道
    CMD(3) = 0;			% 控制DAC输出电压。DAC输出电压 = 3.3V×CMD(3)÷4095
    CMD(4) = 1;				% 输出缓冲模式。=0, 非缓冲输出；=1, 缓冲输出
    fwrite(hDevice, CMD, 'uint16');
    
    CMD(1) = DAC;			% DAC指令
    CMD(2) = 0;				% 选择DAC通道。=0, DAC1通道；=1, DAC2通道
    
	fprintf(char(repmat(8, [strBytes,1])));
	strBytes = fprintf('Energyl = %g,\tEnergylbase = %g,\tratio = %g', Energyl, Energylbase, Energyl/Energylbase);
    if Energyl/Energylbase >= 0.5
        CMD(3) = (Energyl/Energylbase - 0.5) * (2 + 0.5) * 4095 / 3.3;	% 控制DAC输出电压。ratio超过0.5的时候点灯，DAC输出电压从0.5-2.5V。DAC输出电压 = 3.3V×CMD(3)÷4095
		%-log10(Energyl/10^-7)*4095;%4000;%floor(Energyl*4095);			% 控制DAC输出电压。
    else
        CMD(3) = 0;			% 控制DAC输出电压。DAC输出电压 = 3.3V×CMD(3)÷4095
    end

    CMD(4) = 1;				% 输出缓冲模式。=0, 非缓冲输出；=1, 缓冲输出
    fwrite(hDevice, CMD, 'uint16');
  
	hold off
	drawnow;				% ★关键语句！有这句以后，就会等待刷新完成再执行后续语句。否则图形不刷新了，“停止”按钮也不响应了。
%	getframe;				% ★关键语句！有这句以后，就会等待刷新完成再执行后续语句。否则图形不刷新了，“停止”按钮也不响应了。
	startPoint = endPoint + 1;
end

% 3. 关闭设备并退出
ComboClose(hCombo)								% 关闭设备
fclose(hDevice);
catch err
	ComboClose(hCombo)							% 关闭设备
	fclose(hDevice);
end


% --- Executes on button press in pushbuttonFinish.
function pushbuttonFinish_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bIsStart
bIsStart = 0;
