function coresult = singleMain(varargin)

% % 版本：20210701
% % 用途：脑电合作赛车游戏
% % 版权：Peng Gui, pgui@ion.ac.cn
% % 资源：functions - 程序运行必备函数
% %       icons     - 背景图库
% %       music     - 背景音乐
% % 参考：http://peterscarfe.com/ptbtutorials.html


% % 定义环境 
HideCursor;
addpath(genpath(fileparts(mfilename('fullpath'))));

% % % 定义参数
% param = finputcheck(varargin, { ...
%     'mode' , 'string' , {'demo','play'}, 'demo'; ...
%     'window' , 'string' , {'window','full'}, 'window'; ...
%     });

%====================
param.mode= 'demo';
param.window='window';
%================`=====xy 2021.6.11

% % % 播放背景音乐
% pahandle = crbgm;

% % 打开游戏窗口
if strcmpi(param.mode,'demo')
%     flag_exit = crdemo(param);
    flag_exit = crdemo1(param); % change the 'path' in row 51,crdemo1 !!
else
    [flag_exit, coresult] = crplay(param);
end

% % 退出游戏
if flag_exit == 1
    
%     % % 停止背景音乐
%     PsychPortAudio('Stop', pahandle);
%     PsychPortAudio('Close');
%     WaitSecs(2);
    % % 关闭显示窗口
    sca;
    ShowCursor;
    
end

% % 绘制结果



end
