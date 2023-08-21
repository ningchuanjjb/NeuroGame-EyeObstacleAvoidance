%ComboQuery
%ComboOpen
%ComboClose

%ComboGetData
%ComboGetLength


% 1. �򿪴����豸
if ~isempty(instrfind)
    delete(instrfindall);
end
com = ComboQuery							%#ok<*NOPTS> % comΪ�ַ������飬�������еĵ�����һ����豸����
if isempty(com)
    msgbox('û���豸���ӣ���ô�氡��');
    return;
end

obj = ComboOpen(com(1,:));

Fs = 30000; %sample frequency is 30kHz;
GameTime = 3;
readInterval = 20; % set frequency of read signal from Combo each readInterval ms
readCount = 0;
SignalPoint = zeros(GameTime*1000/readInterval,1);
SignalLength = 0;
SignalAll = zeros(Fs*GameTime,1);

t0 = tic;
t = toc(t0);
while t< GameTime    
    t = toc(t0);
    if floor(t*1000/readInterval)>readCount % read data from Combo each readInterval time
        readCount = floor(t*1000/readInterval) +1;
        %read data from Combo 
        [sigtmp,SignalPoint(readCount)] = ReadSignal(obj);
        %SignalLength = SignalLength + SignalPoint(readCount);
        %SignalAll(SignalLength-SignalPoint(readCount)+1:SignalLength) = sigtmp; % concatenate the signals
        if isempty(sigtmp(abs(sigtmp)>0)) == 0  
            fprintf("signal = %.4f\n", mean(sigtmp));
        end
    end    
end


ComboClose(obj);
obj = 0;

close all

