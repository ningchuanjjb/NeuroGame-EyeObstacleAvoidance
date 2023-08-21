% Stop���ص�������Ӧ���ϣ���û�еȴ���ͼ��ɾͼ���ѭ���ɼ������»�ͼ������ռCPU���Ӷ��޷���Ӧ��ť�¼���
% ��drawnow�ȴ���ͼ��ɣ��Ϳ�����Ӧ��ť�ˡ�
% 2020��8��18�� 05:38:20

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
delete(instrfindall);						% �ȹر����д���
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
% 1. ���豸

DevNo = 1;					% ʹ�õ�һ���豸
PB6 = 1; PB7 = 2; PB8 = 4; PB9 = 8;		% ����˿ڶ�Ӧ����ֵ
DOPort = 2986;				% DO Port���
DIPort = 1194;				% DI Port����
DAC = 6058;					% DAC���
GetADC = 4778;				% ADC��ͨ���ɼ�һ��
delete(instrfindall)
K = DeviceQuery();
if isempty(K)
	warning('û���ҵ�STM32DAQ�豸��������豸������');
	return;
end

% �°��Matlab��֧����0��β���ַ�����Ϊ�豸����
% ��֧�ִ������豸���ַ��������ֵĳ��ȱ�������豸���ִ����ȣ�
% ���治���а���NUL���ڵ��κ�����
% ����ĳ�����ǽ�ϵͳ���ص��豸����β�ͽظɾ��������浽Ԫ�������С�
% �м����豸��Ԫ��������м���Ԫ�أ�ÿ��Ԫ����һ���ɾ����豸����
for ii = 1:size(K,1)
	for jj = 1:size(K,2)
		if K(ii, jj) ~= 0
            continue;						% �������е���Ч�ַ�
        else
            dev(ii) = {K(ii, 1:(jj-1))};	% ������Ч�ַ����ضϣ�ȡǰ����Ч�Ĳ��ַŵ�Ԫ�������С�
			break;
		end
	end
end

% �򿪵�һ�������豸
hDevice = serial(dev(DevNo),'baudrate',119200);
fopen(hDevice);

com = ComboQuery;							% comΪ�ַ������飬�������еĵ�����һ����豸����
if isempty(com)
	msgbox('û���ҵ��������ۺϲ����ǣ�������豸������');
	fclose(hDevice);
	return;
end

hCombo = ComboOpen(com(1,:));				% �򿪵������ۺϲ������豸

bIsStart = 1;
% 2. �ɼ����ݡ���ο����ظ���ν��С�
nDuration = 10;								% �趨��ʾʱ��10��
Fs = 30000;									% �������ۺϲ�����ԭ��������
nSize = nDuration * Fs;
nLength = (nDuration+1) * Fs;
datal = zeros(nSize, 1);
Aresiduall = [];
nCompress = 100;							% �ź�ʱ��ѹ����Ϊ100��
nFs = Fs / nCompress;						% ѹ����Ĳ�����
dT = 1 / nFs;								% ѹ����Ĳ������
Thresh = 5*10^-12;
t1 = tic;
startPoint = 1;
endPoint = 1;
bIsShow = 1;
freqScale = 0.35;	% [0..1]
strBytes = 0;
ax(1) = handles.axes1;		hold off;
ax(2) = handles.axes2;		hold off;
linkaxes(ax,'x')							% ��������
while bIsStart
	lenl = ComboGetLength(hCombo);			% ȡ��һ������Ѿ��ɼ������ݳ���
	[Al, El, Pl] = ComboGetData(hCombo, lenl);	% �����������ݳ��ȣ���������
	endPoint = startPoint + lenl - 1;
	tdatal = [datal; Aresiduall; double(Al').*9.9341e-09];	% 1 LSB = ��2.5V/30/2^24
	posl = floor(length(tdatal) / nCompress) * nCompress;
	Aresiduall = tdatal((posl+1):end);
	if posl > nSize
		datal = tdatal(posl-nSize+1 : posl);
    end
	viewEEGl = mean(reshape(datal, nCompress, nSize/nCompress), 1);		% EEG����ѹ��nCompress(100)��
   
    plot(ax(1), (1:length(viewEEGl))/nFs, viewEEGl)					% ��ʾADC24����
	xlabel(ax(1), 'ʱ�䣨�룩')
	ylabel(ax(1), '��ѹ�����أ�')
	if bIsShow
		[Sl,Fl,Tl,Pl] = spectrogram(viewEEGl, 256, 250, 1024, 300);			% ����ʱƵͼ
		freqTopl = floor(length(Fl) * freqScale);
% 		surf(ax(2), Tl, Fl(1:freqTopl), 10*log10(Pl(1:freqTopl,:)),'edgecolor','none'), axis tight, view(0,90)	% ��ʾ
    	ssl = surf(ax(2), Tl, Fl(1:freqTopl), 10*log10(Pl(1:freqTopl,:)),'edgecolor','none');view(2);%axis tight 	% ��ʾ
		ylabel(ax(2), 'Ƶ�ʣ�Hz��')
		xlim([0,10]);
	end
    hold off

% 	% fft����Ƶ��
% 	NN = length(viewEEG);
% 	f0 = 1 / (dT*NN);						% ��Ƶ
% 	f = (0:ceil((NN-1)/2)) * f0;			% Ƶ������
% 	y = abs(fft(viewEEG, length(viewEEG)));
% 	figure, plot(f, 2*y(1:ceil((NN-1)/2)+1)), xlabel('Ƶ��/Hz')
	% ȡ4-10Hz : 40-150Hz��������ֵ
	EFl = ceil([25 40] / Fl(2));
    EFlbase = ceil([10 15] / Fl(2));
%     EFr = ceil([20 40] / Fr(2));
	Energyl = mean(mean(Pl(EFl(1):EFl(2), 400:end), 2), 1);
	Energylbase = mean(mean(Pl(EFlbase(1):EFlbase(2), 400:end), 2), 1);
    % ��PA4��DAC1ͨ������PA5�˿ڣ�DAC2ͨ�������ģ���ź�
    CMD(1) = DAC;			% DACָ��
    CMD(2) = 1;				% ѡ��DACͨ����=0, DAC1ͨ����=1, DAC2ͨ��
    CMD(3) = 0;			% ����DAC�����ѹ��DAC�����ѹ = 3.3V��CMD(3)��4095
    CMD(4) = 1;				% �������ģʽ��=0, �ǻ��������=1, �������
    fwrite(hDevice, CMD, 'uint16');
    
    CMD(1) = DAC;			% DACָ��
    CMD(2) = 0;				% ѡ��DACͨ����=0, DAC1ͨ����=1, DAC2ͨ��
    
	fprintf(char(repmat(8, [strBytes,1])));
	strBytes = fprintf('Energyl = %g,\tEnergylbase = %g,\tratio = %g', Energyl, Energylbase, Energyl/Energylbase);
    if Energyl/Energylbase >= 0.5
        CMD(3) = (Energyl/Energylbase - 0.5) * (2 + 0.5) * 4095 / 3.3;	% ����DAC�����ѹ��ratio����0.5��ʱ���ƣ�DAC�����ѹ��0.5-2.5V��DAC�����ѹ = 3.3V��CMD(3)��4095
		%-log10(Energyl/10^-7)*4095;%4000;%floor(Energyl*4095);			% ����DAC�����ѹ��
    else
        CMD(3) = 0;			% ����DAC�����ѹ��DAC�����ѹ = 3.3V��CMD(3)��4095
    end

    CMD(4) = 1;				% �������ģʽ��=0, �ǻ��������=1, �������
    fwrite(hDevice, CMD, 'uint16');
  
	hold off
	drawnow;				% ��ؼ���䣡������Ժ󣬾ͻ�ȴ�ˢ�������ִ�к�����䡣����ͼ�β�ˢ���ˣ���ֹͣ����ťҲ����Ӧ�ˡ�
%	getframe;				% ��ؼ���䣡������Ժ󣬾ͻ�ȴ�ˢ�������ִ�к�����䡣����ͼ�β�ˢ���ˣ���ֹͣ����ťҲ����Ӧ�ˡ�
	startPoint = endPoint + 1;
end

% 3. �ر��豸���˳�
ComboClose(hCombo)								% �ر��豸
fclose(hDevice);
catch err
	ComboClose(hCombo)							% �ر��豸
	fclose(hDevice);
end


% --- Executes on button press in pushbuttonFinish.
function pushbuttonFinish_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bIsStart
bIsStart = 0;
