function [win, winRect] = crwindow(param)

% % 版本：20210602
% % 用途：打开显示窗口
% % 版权：Peng Gui, pgui@ion.ac.cn
% % 参考：http://peterscarfe.com/ptbtutorials.html

Screen('Preference', 'VisualDebuglevel', 3);% disable the startup screen, replace it by a black display until calibration is finished

% % 打开程序窗口
clear screen;
PsychDefaultSetup(2);
screenNumber = max(Screen('Screens')); % external screen if possible
Screen('Preference', 'SkipSyncTests', 1); % 1 = skip
bgcolor = BlackIndex(screenNumber);
% bgcolor = WhiteIndex(screenNumber);
if strcmpi(param.window,'full')
    [win, winRect] = PsychImaging('OpenWindow', screenNumber, bgcolor);
    HideCursor;
    commandwindow;
else
    [win, winRect] = PsychImaging('OpenWindow', screenNumber, bgcolor);
    HideCursor;
%     [win, winRect] = PsychImaging('OpenWindow', screenNumber, bgcolor, [20 50 1400 1000]);
end
Priority(MaxPriority(win)); % Maximum priority level
Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines



% 绘制欢迎语，倒计时
Screen('TextFont', win, '-:lang=zh-cn');
time_cd = 3;
% nominalFrameRate = Screen('NominalFrameRate', win);
for cdi = 1:time_cd
    Screen('TextSize', win, 70);
%     DrawFormattedText(win, '准备好开始了吗？', 'center', winRect(4)/4, [1 0 0]);
    text1 = double(sprintf('准备好开始了吗？\n'));
    DrawFormattedText(win, text1, 'center', winRect(4)/4, [1 0 0]);
    Screen('TextSize', win, 120);
    DrawFormattedText(win, num2str(time_cd-cdi+1), 'center', 'center', [1 0 0]);
    Screen('Flip', win);
    WaitSecs(1);
end

% % 绘制背景动画


% % 绘制小车


end
