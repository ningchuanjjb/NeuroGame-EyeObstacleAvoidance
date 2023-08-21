% 电生理一体机设备的ComboXxx通讯函数集可以完成Matlab数据采集过程。
% ComboXxx通讯函数集由以下5个函数构成：
%	DeviceNames = ComboQuery;			查询并返回PC上已经连接的所有电生理一体机设备；
%	handle = ComboOpen(DeviceName);		打开指定的设备，并返回该设备的操作句柄；
%	len = ComboGetLength(handle);		查询指定设备当前已经采集到的数据量；
%	data = ComboGetData(handle, len);	读出设备已经采集到的数据，len参数必须要与ComboGetLength()函数返回的长度一致；
%	ComboClose(handle);					关闭已经打开的设备，释放设备。
%
%
% 示例程序
%
% % 1. 打开设备
% com = ComboQuery;						% com为字符串数组，包含所有的电生理一体机设备名称
% h = ComboOpen(com(1,:));				% 打开第一个设备
%										% com(1,:)内含第一个设备，com(2,:)内含第二个设备，其余设备名称依次类推
% % 2. 采集数据。这段可以重复多次进行。
% figure(9)
% data = [];
% for i=1:20
%	len = ComboGetLength(h);				% 取得一体机内已经采集的数据长度
%	[A E P] = ComboGetData(h, len);			% 根据已有数据长度，读出数据
%	data = [data, double(A).*9.9341e-09];	% ADC24数据。1 LSB = ±2.5V/30/2^24
%	ExtAdc = [ExtAdc; E'];					% 扩展ADC数据
%	port = [port, P];						% 数字端口数据
%	data = [data, double(A).*9.9341e-09];	% 1 LSB = ±2.5V/30/2^24
%	figure(9), plot(data)					% 显示这些ADC数据
%	figure(10), plot(bitget(port, 1));		% 显示PB9数据
% end
% % 3. 关闭设备并退出
% ComboClose(h)								% 关闭设备

help ComboHelp

% 1. 打开设备
delete(instrfindall);						% 先关闭所有串口
com = ComboQuery;							% com为字符串数组，包含所有的电生理一体机设备名称
h = ComboOpen(com(1,:));					% 打开第一个设备

% 2. 采集数据。这段可以重复多次进行。
figure(9), clf
data = [];
port = [];
ExtAdc = [];
t1 = tic;
while 1
	len = ComboGetLength(h);				% 取得一体机内已经采集的数据长度
	[A, E, P] = ComboGetData(h, len);	% 根据已有数据长度，读出数据
	data = [data, double(A).*9.9341e-09];	% 1 LSB = ±2.5V/30/2^24
	port = [port, P];
	ExtAdc = [ExtAdc; double((2048 - E') .* 10) / 4095];	% 满度±10V，反相放大输入
	t2 = toc(t1);
	figure(9)
	ax(1) = subplot(3,1,1); plot(data)		% 显示这些ADC24数据
	ax(2) = subplot(3,1,2); plot(ExtAdc)	% 显示这些ExtADC数据
	PB9 = bitget(port, 1) + 0;				% 取出PB9(port端口的0通道)
	PC6 = bitget(port, 2) + 1;				% 取出PC6(port端口的1通道)
	PC7 = bitget(port, 3) + 2;				% 取出PC7(port端口的2通道)
	PC8 = bitget(port, 4) + 3;				% 取出PC8(port端口的3通道)
	ax(3) = subplot(3,1,3); hold on
	plot(PB9, 'b')							% 绘制端口数据
	plot(PC6, 'r')
	plot(PC7, 'k')
	plot(PC8, 'g')
	hold off
	if (t2 >= 15)							% 采集5秒
		break;
	end
end
linkaxes(ax,'x')							% 联轴缩放

% 3. 关闭设备并退出
ComboClose(h)								% 关闭设备
