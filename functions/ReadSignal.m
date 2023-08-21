function [ data, Npoint] = ReadSignal( h )
%READSIGNAL  Read signal from Combo Amplifier
%   Input, obj, the COM port connected to Combo Amplifier
%   Output, data，  signal
%           Npoint, number of signal point
% Citing from YQ Wen, Modified by Zhiwei Wang
% 2015/06/27

    len = ComboGetLength(h);				% 取得一体机内已经采集的数据长度
	[data Adc1 DIO] = ComboGetData(h, len);	% 根据已有数据长度，读出数据
    data = double(data).*9.9341e-09;
    Npoint = length(data);
end

