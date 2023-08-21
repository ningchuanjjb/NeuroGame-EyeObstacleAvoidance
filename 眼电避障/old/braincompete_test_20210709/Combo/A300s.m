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

% 用 deploytool --> Application Compiler 生成独立可执行程序
% A300s.prj是设置好的deploytool编译项目，可以直接打开编译。

help ComboHelp
clear all
fileName = sprintf('%4d%02d%02d_%02d%02d%02d.mat', year(now),month(now),day(now),hour(now),minute(now),int32(second(now)));

% 1. 打开设备
delete(instrfindall);						% 先关闭所有串口
com = ComboQuery;							% com为字符串数组，包含所有的电生理一体机设备名称
h = ComboOpen(com(1,:));					% 打开第一个设备

% 2. 采集数据。这段可以重复多次进行。
figure(9), clf
nDuration = 300;							% 设定采集30秒时间
nLength = (nDuration+1) * 30000;
data = zeros(nLength, 1);
port = zeros(nLength, 1, 'uint8');
ExtAdc = zeros(nLength, 2);
t1 = tic;
startPoint = 1;
endPoint = 1;
while 1
	len = ComboGetLength(h);				% 取得一体机内已经采集的数据长度
	[A, E, P] = ComboGetData(h, len);	% 根据已有数据长度，读出数据
	endPoint = startPoint + len - 1;
	% data = [data, double(A).*9.9341e-09];	% 1 LSB = ±2.5V/30/2^24
	%ExtAdc = [ExtAdc; double((2048 - E') .* 10) / 4095];	% 满度±10V，反相放大输入
	data(startPoint:endPoint) = double(A).*9.9341e-09;	% 1 LSB = ±2.5V/30/2^24
	port(startPoint:endPoint) = P;
	ExtAdc(startPoint:endPoint,:) = double((2048 - E') .* 10) / 4095;	% 满度±10V，反相放大输入
	t2 = toc(t1);
	% if endPoint < 30000*3
	figure(9)
	subplot(3,1,1), clf											% 必须清除figure中的数据，否则到后来会越画越慢
	subplot(3,1,2), clf
	subplot(3,1,3), clf
	leadPoint = max(1, endPoint-2*30000);
	Ncomp = int32(floor(single(endPoint - leadPoint) / 30));	% 30倍数据压缩后的数据量
	dataRange = endPoint-Ncomp*30+1:endPoint;					% 显示的数据范围
	viewEEG = mean(reshape(data(dataRange), 30, Ncomp), 1);		% EEG数据压缩30倍
	viewExt = squeeze(mean(reshape(ExtAdc(dataRange,:), 30, Ncomp, 2), 1));	% 同步信号压缩30倍
	ax(1) = subplot(3,1,1); plot(viewEEG)						% 显示ADC24数据
	ax(2) = subplot(3,1,2); plot(viewExt)						% 显示同步信号数据
	PB9 = bitget(port(dataRange), 1) + 0;						% 取出PB9(port端口的0通道)
	PC6 = bitget(port(dataRange), 2) + 1;						% 取出PC6(port端口的1通道)
	PC7 = bitget(port(dataRange), 3) + 2;						% 取出PC7(port端口的2通道)
	PC8 = bitget(port(dataRange), 4) + 3;						% 取出PC8(port端口的3通道)
	ax(3) = subplot(3,1,3); hold on
	plot(mean(reshape(PB9, 30, Ncomp), 1), 'b')		% 绘制端口数据
	plot(mean(reshape(PC6, 30, Ncomp), 1), 'r')
	plot(mean(reshape(PC7, 30, Ncomp), 1), 'k')
	plot(mean(reshape(PC8, 30, Ncomp), 1), 'g')
	hold off
	% end
	if (t2 >= nDuration)					% 采集nDuration秒
		break;
	end
	startPoint = endPoint + 1;
	fprintf('.');
	pause(0.001)							% 帮助调度
end
linkaxes(ax,'x')							% 联轴缩放

% 3. 关闭设备并退出
ComboClose(h)								% 关闭设备
save(fileName)
