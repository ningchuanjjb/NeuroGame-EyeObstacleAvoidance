function BrainCompeteMain
% global  obj1 obj2 stop com Closetag isstop;
global  obj1 stop com Closetag isstop;
 Closetag = 0; isstop = 1;
% 1. 打开串口设备
    if ~isempty(instrfind)
        delete(instrfindall);
    end
    com = ComboQuery							% com为字符串数组，包含所有的电生理一体机设备名称
    if isempty(com)
        msgbox('没有设备连接，怎么玩啊？');
        return;
%     elseif length(com(:,1))<2
%         msgbox('只有一个设备，我对抗啥啊？');
%         return;
    end
    obj1 = 0;
%     obj2 = 0;
    BrainCompete;
    
end
