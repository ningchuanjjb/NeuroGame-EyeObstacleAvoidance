/*=================================================================
 * ComboClose.cpp
 * 关闭指定的电生理一体机设备。
 * 输入参数(Matlab中)：ComboOpen返回的一个设备句柄
 * 输出参数(Matlab中)：无
 * 
 * 编译方法：
 *		在Matlab命令行窗口中执行 mex -g ComboClose.cpp

 * This is a MEX-file for MATLAB.
 * Copyright 1949-2015 by Bluesky.
 * All rights reserved.
 *=================================================================*/
#define _AFXDLL
#include "mex.h"
#include <string.h>
#include "stdarg.h"
#include "tchar.h"
#include "afx.h"
#include "afxstr.h"
#include "mmsystem.h"
#include "common.h"


void mexFunction(
	int nlhs, mxArray *plhs[],			// 左值，输出参数表
	int nrhs, const mxArray *prhs[])	// 右值，输入参数表
{
	//
	// chech the input argument 
	//
	if (nrhs < 1)
		mexErrMsgTxt("Has not input. Input argument is the handle of ComboAmplifier device.");
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("Input argument is not type of HANDLE.");

	//
	// 关闭串口
	//
	PHANDLE pDevice = (PHANDLE) mxGetData(prhs[0]);
	CloseHandle(*pDevice);
}
