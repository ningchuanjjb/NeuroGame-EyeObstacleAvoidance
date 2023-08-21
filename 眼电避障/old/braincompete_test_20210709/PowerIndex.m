function [ Index, S_alpha, S_gamma] = PowerIndex(data, Fs)
%POWERINDEX funciton calcualtes the powerindex by comparing gamma and alpha
% wave power
%  sampling rate of data show be Fs

% filter alpha wave
h  = fdesign.bandpass('N,F3dB1,F3dB2', 10, 8, 13, Fs);
f_alpha = design(h, 'butter');
S_alpha = filtfilt(f_alpha.sosMatrix,f_alpha.ScaleValues,data);
% filter gamma wave 
h  = fdesign.bandpass('N,F3dB1,F3dB2', 10, 30, 90, Fs);
f_gamma = design(h, 'butter');
S_gamma= filtfilt(f_gamma.sosMatrix,f_gamma.ScaleValues,data);
% should filter 60Hz wave here 

Power_alpha = sum(S_alpha.^2);
Power_gamma = sum(S_gamma.^2);
% if Power_alpha < 9.9341e-09 || Power_gamma < 9.9341e-09
%     Index =0;
% else
    Index = Power_gamma/Power_alpha;
% end
end

