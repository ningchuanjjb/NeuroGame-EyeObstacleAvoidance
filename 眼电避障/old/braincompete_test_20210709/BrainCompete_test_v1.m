function varargout = BrainCompete(varargin)
%BRAINCOMPETE M-file for BrainCompete.fig
%      BRAINCOMPETE, by itself, creates a new BRAINCOMPETE or raises the existing
%      singleton*.
%
%      H = BRAINCOMPETE returns the handle to a new BRAINCOMPETE or the handle to
%      the existing singleton*.
%
%      BRAINCOMPETE('Property','Value',...) creates a new BRAINCOMPETE using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to BrainCompete_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      BRAINCOMPETE('CALLBACK') and BRAINCOMPETE('CALLBACK',hObject,...) call the
%      local function named CALLBACK in BRAINCOMPETE.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BrainCompete

% Last Modified by GUIDE v2.5 19-Jul-2015 19:35:15
%% Set communication messages with Combo
%%
%  global  obj1 obj2 stop runTime;
% % 1. 打开串口设备
% if ~isempty(instrfind)
%     delete(instrfindall);
% end
% com = ComboQuery;							% com为字符串数组，包含所有的电生理一体机设备名称
% if isempty(com)
%     msgbox('没有设备链接，怎么玩啊？');
% end
% if length(com(:,1))<2
%     msgbox('只有一个设备，请检查设备!');
% end
% obj1 = ComboOpen(com(1,:));
% obj2 = ComboOpen(com(2,:));
%%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BrainCompete_OpeningFcn, ...
    'gui_OutputFcn',  @BrainCompete_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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

% --- Executes just before BrainCompete is made visible.
    function BrainCompete_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
        % This function has no output args, see OutputFcn.
        % hObject    handle to figure
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        % varargin   unrecognized PropertyName/PropertyValue pairs from the
        %            command line (see VARARGIN)
        
        % Choose default command line output for BrainCompete
        handles.output = hObject;
        
        % Update handles structure
        guidata(hObject, handles);
        
        % UIWAIT makes BrainCompete wait for user response (see UIRESUME)
        % uiwait(handles.figure1);
    end
% --- Outputs from this function are returned to the command line.
    function varargout = BrainCompete_OutputFcn(hObject, eventdata, handles)
        % varargout  cell array for returning output args (see VARARGOUT);
        % hObject    handle to figure
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        % Get default command line output from handles structure
        varargout{1} = handles.output;
    end
% --- Executes on button press in Stop.
    function Stop_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
        global stop;
        stop = 0;
        
        % hObject    handle to Stop (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
    end

% --- Executes on button press in Start.
    function Start_Callback(hObject, eventdata, handles)
        global stop obj1 obj2 com Closetag isstop;
        if obj1 == 0
            obj1 = ComboOpen(com(1,:));
        end
        if obj2 == 0
            obj2 = ComboOpen(com(2,:));
        end
        
        set(handles.Stop,'Value',0);
        Player1 = get(handles.Name1,'String');
        Player2 = get(handles.Name2,'String');
        gametimeSTR = str2double(get(handles.GameTime,'String'));
        gametimeInd = get(handles.GameTime,'Value');
        gametime = gametimeSTR(gametimeInd);
        
        
        Fs = 30000; %sample frequency is 30kHz;
        GameTime = 60*gametime; % maxmum game tiem is 180s
        FreadSig = 100; % set frequency of read signal from Combo each FreadSig ms
        SigPoint = zeros(GameTime*1000/FreadSig,2);
        SigAll = zeros(Fs*GameTime,2);
        lowestFs = 5; %#ok<*NASGU> % the lowest frequency is 5 Hz %% the shortest time is 200 ms, 6000 point at Fs 30k Hz.
        downFs = 1000; % downsamlpe to 500 Hz
        timeWindow  = 0.5;
        nPointLowFs = Fs*timeWindow;
        SigDown = zeros(nPointLowFs/downFs,2); %#ok<*PREALL>
        slidewindow = 100; % slidewindow 500ms
        
        WinInd = 50;
        % define some counting variables
        slidenum = 0;
        iread = 0;
        SigLength = [0;0];
        isStart =1;
        stop = 1;
        isstop = 0;
        
        h1=handles.PowerDraw;
        h2=handles.GammaWave;
        h3 = handles.AlphaWave;
        t0 = tic;
        t = toc(t0);
        while isStart  && t< GameTime && stop
            
            t = toc(t0);
            if floor(t*1000/FreadSig)>iread % read data from Combo each FreadSig(100ms here) time
                iread = floor(t*1000/FreadSig) +1;
                %read data from Combo 1
                [sigtmp1,SigPoint(iread,1)] = ReadSignal(obj1);
                SigLength(1) = SigLength(1) + SigPoint(iread,1);
                SigAll(SigLength(1)-SigPoint(iread,1)+1:SigLength(1),1) = sigtmp1; % concatenate the signals
                %read data from Combo 2
                [sigtmp2,SigPoint(iread,2)] = ReadSignal(obj2);
                SigLength(2) = SigLength(2) + SigPoint(iread,2);
                SigAll(SigLength(2)-SigPoint(iread,2)+1:SigLength(2),2) = sigtmp2; % concatenate the signals
            end
            %         t2=tic;
            if (SigLength(1) > nPointLowFs && nPointLowFs+slidenum*Fs*slidewindow/1000<SigLength(1)) && ...
                    (SigLength(2) > nPointLowFs && nPointLowFs+slidenum*Fs*slidewindow/1000<SigLength(2))
                %             isStart = isStart + 1;
                % calculate PowerIndex of signal from Combo 1
                tmp1 = SigAll(1+slidenum*Fs*slidewindow/1000:nPointLowFs+slidenum*Fs*slidewindow/1000,1);% extract signal in one sliding window
                SigDown = tmp1(1:Fs/downFs:end); % down sample the data
                [Power1,S_alpha1,S_gamma1] = PowerIndex(SigDown,downFs);
                
                % calculate PowerIndex of signal from Combo 2
                tmp2 = SigAll(1+slidenum*Fs*slidewindow/1000:nPointLowFs+slidenum*Fs*slidewindow/1000,2);% extract signal in one sliding window
                SigDown = tmp2(1:Fs/downFs:end); % down sample the data
                [Power2,S_alpha2,S_gamma2] = PowerIndex(SigDown,downFs);
                %%
                diffInd = (Power1-Power2)/(Power1+Power2);
                % victory judgment
                if isnan(diffInd)
                    diffInd = 0;
                end
                WinInd = WinInd + diffInd;
                %             hold on, stem(slidenum,Power1,'b'); hold on, stem(slidenum, Power2,'r');
                axes(h1); %#ok<*LAXES>
                h=barh([WinInd,100-WinInd;0,0],'Stacked');hold on;
                ylim([0,2]);
                xlim([0 100]);
                set(gca,'XTickLabel','','YTickLabel','');
                ch = get(h,'children');
                set(ch{1},'FaceColor','r');
                set(ch{2},'FaceColor','g');
                stem([100*0.37,50,100*0.63],[2 2 2],'-k','Marker','none'); hold off
                %{
            % display gamma wave
            tmp = tabulate(floor(log10(abs(S_gamma1)))); ex1 = mean(tmp(tmp(:,2)== max(tmp(:,2)),1));
            tmp = tabulate(floor(log10(abs(S_gamma2)))); ex2 = mean(tmp(tmp(:,2)== max(tmp(:,2)),1));
            if ex1<0
                S_gamma1 = S_gamma1*10^abs(ex1);
            else
                S_gamma1 = S_gamma1*10^(-ex1);
            end
            if ex2<0
                S_gamma2 = S_gamma2*10^abs(ex2);
            else
                S_gamma2 = S_gamma2*10^(-ex2);
            end
                %}
                axes(h2);
                plot([1:length(S_gamma1)],S_gamma1,'-r',[1:length(S_gamma2)],S_gamma2,'-g','Linewidth',2) %#ok<*NBRAK>
                %{
            % display alpha wave
            tmp = tabulate(floor(log10(abs(S_alpha1)))); ex1 = mean(tmp(tmp(:,2)== max(tmp(:,2)),1));
            tmp = tabulate(floor(log10(abs(S_alpha2)))); ex2 = mean(tmp(tmp(:,2)== max(tmp(:,2)),1));
            if ex1<0
                S_alpha1 = S_alpha1*10^abs(ex1);
            else
                S_alpha1 = S_alpha1*10^(-ex1);
            end
            if ex2<0
                S_alpha2 = S_alpha2*10^abs(ex2);
            else
                S_alpha2 = S_alpha2*10^(-ex2);
            end
                %}
                axes(h3);
                plot([1:length(S_alpha1)],S_alpha1,'-r',[1:length(S_alpha2)],S_alpha2,'-g','Linewidth',2)
                drawnow;
                %      t3 = toc(t2)
                % if one player wins, stop the game.
                if WinInd <= 0
                    isStart =0;
                    msgbox([Player2, ' 的脑袋好牛B，你确定不是外星人？！！']);
                elseif WinInd >=100
                    isStart =0;
                    msgbox([Player1, ' 的脑袋好牛B， 你确定不是外星人？！！']);
                end
                slidenum = slidenum+1;
                
            end
            if Closetag ==1
                break;
            end
        end
        if stop==1 && isStart ==1 && Closetag ==0
            if WinInd <100*0.37
                msgbox([Player2, ' 的脑袋更牛B一些！！']);
            elseif WinInd > 100*0.63
                msgbox([Player1, ' 的脑袋更牛B一些！！']);
            else
                msgbox('你 俩 脑 袋 差 不 多！！多玩会儿看看吧！！');
            end
        end
        isstop = 1;
        ComboClose(obj1);
        obj1 = 0;
        ComboClose(obj2);
        obj2 = 0;
        if Closetag ==1
            close all
        end
        
        % hObject    handle to Start (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
    end
    function Name1_Callback(hObject, eventdata, handles)
        % hObject    handle to Name1 (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        % Hints: get(hObject,'String') returns contents of Name1 as text
        %        str2double(get(hObject,'String')) returns contents of Name1 as a double
    end

% --- Executes during object creation, after setting all properties.
    function Name1_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to Name1 (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called
        
        % Hint: edit controls usually have a white background on Windows.
        %       See ISPC and COMPUTER.
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end
    end



    function Name2_Callback(hObject, eventdata, handles)
        % hObject    handle to Name2 (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        % Hints: get(hObject,'String') returns contents of Name2 as text
        %        str2double(get(hObject,'String')) returns contents of Name2 as a double
    end

% --- Executes during object creation, after setting all properties.
    function Stop_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to Stop (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called
    end


    function GameTime_Callback(hObject, eventdata, handles)
        % hObject    handle to GameTime (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        % Hints: get(hObject,'String') returns contents of GameTime as text
        %        str2double(get(hObject,'String')) returns contents of GameTime as a double
    end

% --- Executes during object creation, after setting all properties.
    function GameTime_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to GameTime (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called
        
        % Hint: edit controls usually have a white background on Windows.
        %       See ISPC and COMPUTER.
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end
    end

% --- Executes on button press in Close.
    function Close_Callback(hObject, eventdata, handles)
        global Closetag obj1 obj2 isstop;
        Closetag = 1;
        
        if isstop
            if obj1~=0
                ComboClose(obj1);
                obj1=0;
            end
            if obj2~=0
                ComboClose(obj2);
                obj2 = 0;
            end
            close all
        end
        % hObject    handle to Close (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
    end

% --- Executes during object creation, after setting all properties.
    function Close_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to Close (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called
    end

% --- Executes when user attempts to close figure1.
    function figure1_CloseRequestFcn(hObject, eventdata, handles)
        global Closetag obj1 obj2 isstop;
        Closetag = 1;
        if isstop
            if obj1~=0
                ComboClose(obj1);
                obj1=0;
            end
            if obj2~=0
                ComboClose(obj2);
                obj2 = 0;
            end
        end
        % hObject    handle to figure1 (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        % Hint: delete(hObject) closes the figure
        delete(hObject);
    end
end