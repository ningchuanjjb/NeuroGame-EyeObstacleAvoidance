function coresult = singleMain(varargin)

% % �汾��20210701
% % ��;���Ե����������Ϸ
% % ��Ȩ��Peng Gui, pgui@ion.ac.cn
% % ��Դ��functions - �������бر�����
% %       icons     - ����ͼ��
% %       music     - ��������
% % �ο���http://peterscarfe.com/ptbtutorials.html


% % ���廷�� 
HideCursor;
addpath(genpath(fileparts(mfilename('fullpath'))));

% % % �������
% param = finputcheck(varargin, { ...
%     'mode' , 'string' , {'demo','play'}, 'demo'; ...
%     'window' , 'string' , {'window','full'}, 'window'; ...
%     });

%====================
param.mode= 'demo';
param.window='window';
%================`=====xy 2021.6.11

% % % ���ű�������
% pahandle = crbgm;

% % ����Ϸ����
if strcmpi(param.mode,'demo')
%     flag_exit = crdemo(param);
    flag_exit = crdemo1(param); % change the 'path' in row 51,crdemo1 !!
else
    [flag_exit, coresult] = crplay(param);
end

% % �˳���Ϸ
if flag_exit == 1
    
%     % % ֹͣ��������
%     PsychPortAudio('Stop', pahandle);
%     PsychPortAudio('Close');
%     WaitSecs(2);
    % % �ر���ʾ����
    sca;
    ShowCursor;
    
end

% % ���ƽ��



end
