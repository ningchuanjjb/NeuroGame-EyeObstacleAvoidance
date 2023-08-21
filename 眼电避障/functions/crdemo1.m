function flag_exit = crdemo1(param)

% % 版本：20210602
% % 用途：赛车游戏演示
% % 版权：Peng Gui, pgui@ion.ac.cn
% % 参考：http://peterscarfe.com/ptbtutorials.html

Screen('Preference', 'VisualDebuglevel', 3);% disable the startup screen, replace it by a black display until calibration is finished

flag_exit =1;
[win, winRect] = crwindow(param);
ifi = Screen('GetFlipInterval', win);
[screenXpixels, screenYpixels] = Screen('WindowSize', win);
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(winRect);
% Sync us and get a time stamp
vbl = Screen('Flip', win);
waitframes = 1;
%
% Make a base Rect of 150 by 150 pixels
baseRect = [0 0 150 150];
lu_baseRect =[0 0 100 100]; %#ok<*NASGU>
amplitude = screenYpixels * 0.3;
frequency = 0.2;
angFreq = 2 * pi * frequency;
startPhase = 0;
time = 0;

% % 播放背景音乐
pahandle = crbgm_jjb('singleBGM.ogg',1,0.25);

%% Background
%crwindow(param)
% backgroundLocation = 'icons\Tree_new.png';
backgroundLocation = 'icons\Tree_new2.png';
background = imread(backgroundLocation);
[s1, s2, s3] = size(background); %#ok<*ASGLU>
if s1 > screenXpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end

backBaseRect = [0 0 s2 s1];

backgroundTexture = Screen('MakeTexture', win, background);


%% the car we need control by keys
thecarLocation = 'icons\car0.png';
% thecar = imread(thecarLocation);
[thecar,~,alpha] = imread(thecarLocation);
thecar(:,:,4) = alpha;
carTexture = Screen('MakeTexture', win, thecar);


%% Obstacles
MaxNum = 14; % maximum number of obstacles
GameTime = 60;
MaxRepeat_singleIcon = 1;
% Path = 'D:\program\SummerCamp\电生理赛车游戏_20210701_randObstacle\coracing\obstacles';
Path = 'obstacles';
Dir = dir(Path);
N = length(Dir);
Samp = randi([3,N],[1,MaxNum]);
for i = 1:MaxNum
%     i = 1
    NaMe = Dir(Samp(i)).name;
    obj_1 = [Path, '\', NaMe];
    [obj,~,alpha] = imread(obj_1);
    obj(:,:,4) = alpha;
    objTexture{i} = Screen('MakeTexture', win, obj); %#ok<*SAGROW>
end

% % Initial positions and velocities of obstacles
% randX = xCenter + 25 * randi([-15,4],[1,MaxNum]); % to be adjusted
randX = xCenter + 25 * randi([-12,12],[1,MaxNum]); % to be adjusted
randY = yCenter + 25 * randi([-40,-6],[1,MaxNum]); % to be adjusted
% randT = randi([0,35],[1,MaxNum]); % to be adjusted

tempT = cell(1, MaxRepeat_singleIcon);
tempT2 = [];
for tempi=1:MaxRepeat_singleIcon
    tempT{tempi} = randperm(GameTime/MaxRepeat_singleIcon,MaxNum/MaxRepeat_singleIcon) ...
        * MaxRepeat_singleIcon;
    tempT2 = [tempT2 tempT{tempi}]; %#ok<*AGROW>
end
randT = sort(tempT2);

randSpd = 15 * randi([0,6],[1,MaxNum]); % to be adjusted
% randSpd(randX<-200) = -randSpd(randX<-200); % to be adjusted
randSpd(randX>screenXpixels/2) = -randSpd(randX>screenXpixels/2); % to be adjusted
randSpdY = 0.01 * randi([75,150],[1,MaxNum]); % to be adjusted


%% Parameters
% The avaliable keys to press
escapeKey = KbName('ESCAPE');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
% Set the intial position of the square to be in the centre of the screen
squareX = xCenter;
squareY = yCenter+300;

squareX_leftBoundaryCoeff = 0.39;
squareX_rightBoundaryCoeff = 0.61;


% Set the amount we want our square to move on each button press
% pixelsPerPress = 10;
moveDisPerPress = (squareX_rightBoundaryCoeff - squareX_leftBoundaryCoeff)/2;

% Maximum priority level
topPriorityLevel = MaxPriority(win);
Priority(topPriorityLevel);

% This is the cue which determines whether we exit the demo
exitDemo = false;



%% 打开串口设备及其相关变量的初始化
if ~isempty(instrfind)
    delete(instrfindall);
end
com = ComboQuery;							%#ok<*NOPTS> % com为字符串数组，包含所有的电生理一体机设备名称
if isempty(com)
    msgbox('没有设备连接，怎么玩啊？');
    return;
end
obj = ComboOpen(com(1,:));

Fs = 30000; %sample frequency is 30kHz;
% GameTime = 60;
saccadeThreshold = 0.6;%0.5-->1
RefractoryPeriod = 380; %ms
readInterval = 16.6667; % set frequency of read signal from Combo each readInterval ms
readCount = 0;
SignalPoint = [];
SignalLength = 0;
SignalAll = zeros(Fs*GameTime,1);
signal = 0;
signalFlag = 0;
temp2 = [];

t0 = tic;
t = toc(t0);
t0_read_coldDown = tic;

flag_ongoing0_lose1_win2 = 0;

%% Loop the animation until the escape key is pressed
while exitDemo == false
    t = toc(t0);
    
    % read data from Combo each readInterval time
    if floor(t*1000/readInterval) > readCount 
        readCount = floor(t*1000/readInterval) +1;        
        [sigtmp, SignalPoint(readCount)] = ReadSignal(obj);
        signal = 10000 * sigtmp;
        %signalFlag = 1;               
    end   
    if toc(t0_read_coldDown) > RefractoryPeriod/1000
        signalFlag = 1;
    end
    
    meanSignal = mean(signal);            
    if abs(meanSignal) > saccadeThreshold && signalFlag == 1 
        signal = 0;
        signalFlag = 0;
        t0_read_coldDown = tic; 
        
        
        if meanSignal > 0
            temp1 = 1;
        else
            temp1 = 0;
        end
        temp2 = [temp2 temp1]; %#ok<*AGROW>
        temp3 = temp2;
        temp4 = zeros(1, length(temp3));
        for tempi=1:length(temp3)
            if tempi == 1
                temp4(tempi) = 0;
            elseif tempi > 1
                if temp3(tempi) == temp3(tempi-1)
                    temp4(tempi) = 0;
                else
                    temp4(tempi) = 1;
                end
            end
        end
        
        if temp4(end) == 1
            if meanSignal > saccadeThreshold
                squareX = screenXpixels * squareX_leftBoundaryCoeff;
            elseif meanSignal < -1*saccadeThreshold
                squareX = screenXpixels * squareX_rightBoundaryCoeff;
            end
        end
                
    end
    
     
    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck;

    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if keyCode(escapeKey)
        exitDemo = true;
    elseif keyCode(leftKey) && lastKeyCode(leftKey) == 0
        squareX = squareX - screenXpixels * moveDisPerPress;        
        if squareX < screenXpixels * squareX_leftBoundaryCoeff
            squareX = screenXpixels * squareX_leftBoundaryCoeff;
        end
    elseif keyCode(rightKey) && lastKeyCode(rightKey) == 0
        squareX = squareX + screenXpixels * moveDisPerPress;
        if squareX > screenXpixels * squareX_rightBoundaryCoeff
            squareX = screenXpixels * squareX_rightBoundaryCoeff;
        end
    end

    lastKeyCode = keyCode;
    % Center the rectangle on the centre of the screen
    centeredRect = CenterRectOnPointd(baseRect, squareX, squareY);


    %% Positions of obstacles
%     time_in_period = mod(time, 8);
    for i = 1:MaxNum
       initialX = randX(i); 
       initialY = randY(i);
       objT(i) = time - randT(i); 
%        objT = time - randT(i); 
       objXPos(i) = initialX + randSpd(i)*objT(i) + 30*sin(pi*objT(i));
       objYPos(i) = initialY + amplitude*objT(i);
       obj_dRect{i} = CenterRectOnPointd(baseRect, objXPos(i), objYPos(i));
    end 
    
    %% Positions of background
    initialX = screenXpixels/2;
    initialY = screenYpixels/2;
    backgroundXPos = initialX;
%     backgroundYPos1 = initialY + mod(100*round(time), max(backBaseRect));
    backgroundYPos1 = initialY + mod(200*time, max(backBaseRect));

    %backgroundYPos = initialY;
    backgroundRect1 = CenterRectOnPointd(backBaseRect, backgroundXPos, backgroundYPos1);
    
%     backgroundYPos2 = initialY + mod(100*round(time), max(backBaseRect)) ...
%         - max(backBaseRect);
    backgroundYPos2 = initialY + mod(200*time, max(backBaseRect)) ...
        - max(backBaseRect);

    backgroundRect2 = CenterRectOnPointd(backBaseRect, backgroundXPos, backgroundYPos2);
    
    count_flag=2;
    if count_flag == 1
        Screen('TextSize', win, 20);
        DrawFormattedText(win, double(sprintf('得分：')), 1000, winRect(4)/4, [1 0 0]);
        Screen('TextSize', win, 20);
        DrawFormattedText(win, num2str(roundn(time,-2)), 1100, winRect(4)/4, [1 0 0]);
        Screen('Flip', win);
        WaitSecs(ifi/10);
    end


    %% Score count
    for i = 1:MaxNum
       if abs(squareX - objXPos(i)) < 75 && abs(squareY - objYPos(i)) < 75
            Screen('TextSize', win, 70);
            DrawFormattedText(win,double(sprintf('得分：')), 'center', screenYpixels*0.4, ...
                [1 0 0]);
            Screen('TextSize', win, 120);
            DrawFormattedText(win,double( sprintf('%.2f', roundn(time,-2)) ), ...
                'center', 'center', [1 0 0]);
            Screen('Flip', win);

            PsychPortAudio('Stop', pahandle);
            if time < GameTime
                pahandle_lose = crbgm_jjb('loseSound.mp3',1,1);

                flag_ongoing0_lose1_win2 = 1;
            end
            
            WaitSecs(1);
            %beep
            WaitSecs(2);
            exitDemo = true;
            
       end   
    end
    
    %% Show stimulus
    if exitDemo == false
        %Screen('DrawTexture', win,backgroundTexture, [], [], 0);
        Screen('DrawTexture', win,backgroundTexture, [], backgroundRect1, 0);
        Screen('DrawTexture', win,backgroundTexture, [], backgroundRect2, 0);        
        Screen('DrawTexture', win,carTexture, [],centeredRect);
        for i = 1:MaxNum
            Screen('DrawTexture', win, objTexture{i},[], obj_dRect{i});
        end
        
        text1 = double(sprintf('时间'));
        DrawFormattedText(win,text1, screenXpixels*0.8, winRect(4)/4, [1 0 0]);
        text2 = double(sprintf('\n%.2f', time));
        DrawFormattedText(win,text2, screenXpixels*0.8, winRect(4)/4, [1 0 0]);
    end



    vbl  = Screen('Flip', win, vbl + (waitframes - 0.5) * ifi);
    time = time + ifi;
    if time > GameTime
        exitDemo = true;
        pahandle_win = crbgm_jjb('loseSound.mp3',1,1);

        flag_ongoing0_lose1_win2 = 2;
    end
    if exitDemo == true
        WaitSecs(3);
    end
end

% % 停止背景音乐
PsychPortAudio('Stop', pahandle);
PsychPortAudio('Close');
% WaitSecs(2);

% Clear the screen
sca;


% Wait for one seconds
% WaitSecs(3);

ComboClose(obj);
obj = 0;
close all

end