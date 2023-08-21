function flag_exit = crdemo(param)

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
lu_baseRect =[0 0 100 100];
amplitude = screenYpixels * 0.3;
frequency = 0.2;
angFreq = 2 * pi * frequency;
startPhase = 0;
time = 0;

% % 播放背景音乐
pahandle = crbgm;

%% Background
%crwindow(param)
% theImageLocation = 'D:\Program\SummerCamp\AdaptedXyz\coracing\icons\Tree_new.png';
theImageLocation = 'icons\Tree_new.png';
theImage = imread(theImageLocation);
[s1, s2, s3] = size(theImage);
if s1 > screenXpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end

imageTexture = Screen('MakeTexture', win, theImage);
%Screen('Flip', win);
%=====================================================
%% Obstacles
% womanLocation = 'D:\Program\SummerCamp\AdaptedXyz\coracing\icons\icon125.png';
womanLocation = 'icons\icon125.png';
% woman = imread(womanLocation);
[woman,~,alpha] = imread(womanLocation);
woman(:,:,4) = alpha;
womanTexture = Screen('MakeTexture', win, woman);

% Draw all of our dots to the screen in a single line of code adding
% the sine oscilation to the X coordinates of the dots
%Screen('DrawDots', window, [womanX; womanY + womanPos]);
%==================================================================
%treeLocation = 'Z:\Tool_xy\x\coracing\icons\tree_new.png';
%tree = imread(treeLocation);
%treeTexture = Screen('MakeTexture', win, tree);
%===================================================================
%==================================================================
% supermanLocation = 'D:\Program\SummerCamp\AdaptedXyz\coracing\icons\superman.png';
supermanLocation = 'icons\superman.png';
% superman = imread(supermanLocation);
[superman,~,alpha] = imread(supermanLocation);
superman(:,:,4) = alpha;
supermanTexture = Screen('MakeTexture', win, superman);
%===================================================================
%==================================================================
% luLocation = 'D:\Program\SummerCamp\AdaptedXyz\coracing\icons\icon001.png';
luLocation = 'icons\icon001.png';
% lu = imread(luLocation);
[lu,~,alpha] = imread(luLocation);
lu(:,:,4) = alpha;
luTexture = Screen('MakeTexture', win, lu);
%===================================================================
% crowLocation = 'D:\Program\SummerCamp\AdaptedXyz\coracing\icons\crow.png';
crowLocation = 'icons\crow.png';
% crow = imread(crowLocation);
[crow,~,alpha] = imread(crowLocation);
crow(:,:,4) = alpha;
crowTexture = Screen('MakeTexture', win, crow);
%===================================================================
%% the car we need control by keys
% thecarLocation = 'D:\Program\SummerCamp\AdaptedXyz\coracing\icons\car0.png';
thecarLocation = 'icons\car0.png';
% thecar = imread(thecarLocation);
[thecar,~,alpha] = imread(thecarLocation);
thecar(:,:,4) = alpha;
carTexture = Screen('MakeTexture', win, thecar);

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

% Loop the animation until the escape key is pressed
while exitDemo == false
    
    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck;
    
    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if keyCode(escapeKey)
        exitDemo = true;
    elseif keyCode(leftKey) && lastKeyCode(leftKey) == 0
        squareX = squareX - screenXpixels * moveDisPerPress;
        %         squareX = squareX - pixelsPerPress;
        if squareX < screenXpixels * squareX_leftBoundaryCoeff
            squareX = screenXpixels * squareX_leftBoundaryCoeff;
        end
    elseif keyCode(rightKey) && lastKeyCode(rightKey) == 0
        squareX = squareX + screenXpixels * moveDisPerPress;
        %         squareX = squareX + pixelsPerPress;
        if squareX > screenXpixels * squareX_rightBoundaryCoeff
            squareX = screenXpixels * squareX_rightBoundaryCoeff;
        end
        %     elseif keyCode(upKey)
        %         squareY = squareY - pixelsPerPress;
        %     elseif keyCode(downKey)
        %         squareY = squareY + pixelsPerPress;
    end
    
    % We set bounds to make sure our square doesn't go completely off of
    % the screen
    %     if squareX < 0
    %         squareX = 0;
    %     elseif squareX > screenXpixels
    %         squareX = screenXpixels;
    %     end
    %
    %     if squareY < 0
    %         squareY = 0;
    %     elseif squareY > screenYpixels
    %         squareY = screenYpixels;
    %     end
    
    lastKeyCode = keyCode;
    % Center the rectangle on the centre of the screen
    centeredRect = CenterRectOnPointd(baseRect, squareX, squareY);
    
    
    time_in_period = mod(time, 8);
    %========================================================
    womanX = xCenter+100;
    womanY = 0;
    womanPos = amplitude * time_in_period ;
    womanXPos = womanX;
    womanYPos = womanY + womanPos;
    womandRect = CenterRectOnPointd(baseRect, womanX, womanYPos);
    %==============================================================
    %treeX = xCenter+230;
    %treeY = 0;
    %treePos = amplitude * time ;
    %treeXPos = treeX + 35* time;
    %treeYPos = treeY + treePos;
    %treedRect = CenterRectOnPointd(tree_baseRect, treeXPos, treeYPos);
    
    supermanX = xCenter-100;
    supermanY = 0;
    supermanPos = amplitude * (time_in_period-8) ;
    supermanXPos = supermanX + 70* (time_in_period-8);
    supermanYPos = supermanY + supermanPos;
    supermandRect = CenterRectOnPointd(lu_baseRect, supermanXPos, supermanYPos);
    
    luX = xCenter-150;
    luY = 0;
    luPos = amplitude * (time_in_period-3) ;
    luXPos = luX + 33* (time_in_period-3);
    luYPos = luY + luPos;
    ludRect = CenterRectOnPointd(lu_baseRect, luXPos, luYPos);
    
    crowX = xCenter-450;
    crowY = 0;
    crowPos = amplitude * (time_in_period-1) ;
    crowXPos = crowX - 35* (time_in_period-4);
    crowYPos = crowY + crowPos;
    crowdRect = CenterRectOnPointd(lu_baseRect, crowXPos, crowYPos);
    
    count_flag=2;
    if count_flag == 1
        Screen('TextSize', win, 20);
        DrawFormattedText(win, double(sprintf('得分：')), 1000, winRect(4)/4, [1 0 0]);
        Screen('TextSize', win, 20);
        DrawFormattedText(win, num2str(roundn(time,-2)), 1100, winRect(4)/4, [1 0 0]);
        Screen('Flip', win);
        WaitSecs(ifi/10);
    end
    
    
    
    % Draw the rect to the screen
    Screen('DrawTexture', win,imageTexture, [], [], 0);
    %Screen('FillRect', win, rectColor, centeredRect);
    
    
    Screen('DrawTexture', win, womanTexture,[], womandRect);
    %Screen('DrawTexture', win, treeTexture,[], treedRect);
    Screen('DrawTexture', win, supermanTexture,[], supermandRect);
    Screen('DrawTexture', win, luTexture,[], ludRect);
    Screen('DrawTexture', win, crowTexture,[], crowdRect);
    %Screen('DrawTexture', win,carTexture, [],[squareX, squareY]);
    %Screen('DrawTexture', win,womanTexture, [], womandRect);
    % Flip to the screen
    Screen('DrawTexture', win,carTexture, [],centeredRect);
    
    if abs(squareX - womanXPos) < 75 && abs(squareY - womanYPos) < 75
        Screen('TextSize', win, 70);
        DrawFormattedText(win, double(sprintf('得分：')), 'center', winRect(4)/4, [1 0 0]);
        Screen('TextSize', win, 120);
        DrawFormattedText(win, num2str(roundn(time,-2)), 'center', 'center', [1 0 0]);
        Screen('Flip', win);
        WaitSecs(1);
        exitDemo = true;
    end
    if abs(squareX - luXPos) < 75 && abs(squareY - luYPos) < 75
        Screen('TextSize', win, 70);
        DrawFormattedText(win, double(sprintf('得分：')), 'center', winRect(4)/4, [1 0 0]);
        Screen('TextSize', win, 120);
        DrawFormattedText(win, num2str(roundn(time,-2)), 'center', 'center', [1 0 0]);
        Screen('Flip', win);
        WaitSecs(1);
        exitDemo = true;
    end
    if abs(squareX - supermanXPos) < 75 && abs(squareY - supermanYPos) < 75
        Screen('TextSize', win, 70);
        DrawFormattedText(win, double(sprintf('得分：')), 'center', winRect(4)/4, [1 0 0]);
        Screen('TextSize', win, 120);
        DrawFormattedText(win, num2str(roundn(time,-2)), 'center', 'center', [1 0 0]);
        Screen('Flip', win);
        WaitSecs(1);
        exitDemo = true;
    end
    
    
    vbl  = Screen('Flip', win, vbl + (waitframes - 0.5) * ifi);
    time = time + ifi;
end

% % 停止背景音乐
PsychPortAudio('Stop', pahandle);
PsychPortAudio('Close');
% WaitSecs(2);

% Clear the screen
sca;



% Wait for one seconds
WaitSecs(3);



%if
%  flag_exit = 1;
%end

end
