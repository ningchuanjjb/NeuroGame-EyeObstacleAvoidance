%ComboQuery
%ComboOpen
%ComboClose

%ComboGetData
%ComboGetLength


%打开串口设备及其相关变量的初始化
if ~isempty(instrfind)
    delete(instrfindall);
end
com = ComboQuery							%#ok<*NOPTS> % com为字符串数组，包含所有的电生理一体机设备名称
if isempty(com)
    msgbox('没有设备连接，怎么玩啊？');
    return;
end
obj = ComboOpen(com(1,:));

Fs = 30000; %sample frequency is 30kHz;
GameTime = 200;%10
readInterval = 20; % set frequency of read signal from Combo each readInterval ms
readCount = 0;
SignalPoint = zeros(round(GameTime*1000/readInterval),1);
SignalLength = 0;
SignalAll = zeros(Fs*GameTime,1);
temp2 = [];

t0 = tic;
t = toc(t0);
while t< GameTime    
    t = toc(t0);
    if floor(t*1000/readInterval)>readCount % read data from Combo each readInterval time
        readCount = floor(t*1000/readInterval) +1;
        %read data from Combo 
        [sigtmp,SignalPoint(readCount)] = ReadSignal(obj);
        signal = 10000 * sigtmp;
        %SignalLength = SignalLength + SignalPoint(readCount);
        %SignalAll(SignalLength-SignalPoint(readCount)+1:SignalLength) = sigtmp; % concatenate the signals
        if abs(mean(signal)) > 1 
            if mean(signal) > 0
                temp1 = 1;
            else
                temp1 = 0;
            end
            temp2 = [temp2 temp1]; %#ok<*AGROW>
            if length(temp2) <= 3
                temp3 = temp2;
            else
                temp3 = temp2(1:end-3);
            end
            
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
            if temp4(end) > 0
                fprintf("signal = %d\n", sum(temp4));
%                 if mean(signal) > 0
%                     fprintf("signal = %d\n", sum(temp4));
%                 else
%                     fprintf("signal = -%d\n", sum(temp4));
%                 end
            end
            
            %fprintf("signal = %.4f\n", mean(signal));
        end
    end    
end


ComboClose(obj);
obj = 0;
close all

