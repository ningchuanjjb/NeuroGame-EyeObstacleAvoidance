% 采集60秒的示例程序

% 1. 打开设备
com = ComboQuery;						% com为字符串数组，包含所有的电生理一体机设备名称
h = ComboOpen(com(1,:));				% 打开第一个设备
% com(1,:)内含第一个设备，com(2,:)内含第二个设备，其余设备名称依次类推
% 2. 采集数据。这段可以重复多次进行。
data = [];
tic
while(length(data)<60*30000)			% 采集60秒
len = ComboGetLength(h);				% 取得一体机内已经采集的数据长度
A = ComboGetData(h, len);				% 根据已有数据长度，读出数据
data = [data, double(A).*9.9341e-09];	% 1 LSB = ±2.5V/30/2^24
end
toc
figure(9), plot(data)					% 显示这些数据
% 3. 关闭设备并退出
ComboClose(h)								% 关闭设备
clear h