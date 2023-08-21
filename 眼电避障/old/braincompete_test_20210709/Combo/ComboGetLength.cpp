/*=================================================================
 * ComboGetLength.cpp 
 * 查询并锁定已采集的数据量
 * 输入参数(Matlab中)：ComboOpen返回的一个设备句柄
 * 输出参数(Matlab中)：一体机内已经采集到的数据长度
 * 
 * 编译方法：
 *		在Matlab命令行窗口中执行 mex -g ComboGetLength.cpp

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
	// 获取串口句柄
	//
	PHANDLE pDevice = (PHANDLE) mxGetData(prhs[0]);
	HANDLE hDevice = *pDevice;
	DWORD dwRet;
	COMMAND_MESSAGE Cmd = {0};
	CString str;

	//
	// 获取设备缓存区内的数据量
	// 
	Cmd.SyncMark = 0xAA5500FF;
	Cmd.nCommand = ADC24_LOCK_BUFFER;
	if (!WriteFile(hDevice, &Cmd, sizeof(COMMAND_MESSAGE), &dwRet, NULL))
	{
		str.Format("ComboGetLength函数：向设备写入数据时发生错误。Handle = %d\n", hDevice);
		mexWarnMsgTxt(str);
	}
	Sleep(1);
	if (!ReadFile(hDevice, &Cmd, sizeof(COMMAND_MESSAGE), &dwRet, NULL))
	{
		str.Format("ComboGetLength函数：读取设备数据时发生错误。Handle = %d\n", hDevice);
		mexWarnMsgTxt(str);
	}
	if (Cmd.SyncMark != 0xAA5500FF)
	{
		str.Format("ComboGetLength函数：设备数据通讯时发生错配，正在清除设备缓存区数据。Handle = %d\n", hDevice);
		mexWarnMsgTxt(str);
		INT32 Err[1000];
		for (int m=0; m<10; m++)
			ReadFile(hDevice, &Err, sizeof(INT32)*1000, &dwRet, NULL);
	}

	plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
	INT32 *pHandle = (INT32 *)mxGetData(plhs[0]);
	*pHandle = (INT32)Cmd.Param0;
}
