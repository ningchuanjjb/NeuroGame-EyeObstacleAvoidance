function pahandle = crbgm_jjb(file_name,repetitions,masterVolume)
Screen('Preference','SkipSyncTests', 1);

% % 版本：20210602
% % 用途：循环播放背景音乐
% % 版权：Peng Gui, pgui@ion.ac.cn
% % 参考：http://peterscarfe.com/ptbtutorials.html


% % 初始化
% PsychPortAudio('Close'); % close the audio device
% dv = PsychPortAudio('GetDevices');
deviceID = 2;
InitializePsychSound(1);
% channels = 2;
buffersize = 0;

% % 加载资源
% bgmfile = '03_Fantasy_Forest.ogg';
bgmfile = file_name;

[bgmload,bgmfreq] = audioread(bgmfile);
channels = size(bgmload,2);

if size(bgmload,1) > channels
    bgmload = bgmload';
end

% % 打开音频设备
pahandle = PsychPortAudio('Open', deviceID, [], 1, bgmfreq, channels, buffersize);
PsychPortAudio('FillBuffer', pahandle, bgmload); % loads data into buffer

PsychPortAudio('Volume', pahandle ,masterVolume);

% % 播放背景音乐
PsychPortAudio('Start', pahandle, repetitions, 0, 1); % starts sound immediatley

end
