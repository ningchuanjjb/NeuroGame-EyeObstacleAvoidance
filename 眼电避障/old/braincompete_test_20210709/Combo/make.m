% 编译一体机设备的ComboXxx通讯函数集
% 如果是第一次使用mex编译，需要用以下指令配置编译环境
%	mex -setup
% 

% for Debug version
fprintf('编译 ComboQuery.cpp ...\n');
mex -g ComboQuery.cpp
fprintf('编译 ComboOpen.cpp ...\n');
mex -g ComboOpen.cpp
fprintf('编译 ComboGetLength.cpp ...\n');
mex -g ComboGetLength.cpp
fprintf('编译 ComboGetData.cpp ...\n');
mex -g ComboGetData.cpp -lWinmm.lib
fprintf('编译 ComboClose.cpp ...\n');
mex -g ComboClose.cpp

% % for Release version
% fprintf('编译 ComboQuery.cpp ...\n');
% mex ComboQuery.cpp
% fprintf('编译 ComboOpen.cpp ...\n');
% mex ComboOpen.cpp
% fprintf('编译 ComboGetLength.cpp ...\n');
% mex ComboGetLength.cpp
% fprintf('编译 ComboGetData.cpp ...\n');
% mex ComboGetData.cpp -lWinmm.lib
% fprintf('编译 ComboClose.cpp ...\n');
% mex ComboClose.cpp
% delete *.pdb
