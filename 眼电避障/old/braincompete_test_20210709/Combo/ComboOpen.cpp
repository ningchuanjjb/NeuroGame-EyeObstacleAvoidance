/*=================================================================
 * ComboOpen.cpp 
 *	Version 1.10
 * 打开指定的电生理一体机设备
 * 输入参数(Matlab中)：ComboQuery返回的一个设备串口号
 * 输出参数(Matlab中)：设备句柄
 * 
 * 编译方法：
 *		在Matlab命令行窗口中执行 mex -g ComboOpen.cpp

 * This is a MEX-file for MATLAB.
 * Copyright 1949-2017 by Bluesky.
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

HANDLE OpenComm(CString strCom);

void mexFunction(
	int nlhs, mxArray *plhs[],			// 左值，输出参数表
	int nrhs, const mxArray *prhs[])	// 右值，输入参数表
{
	//
	// chech the input argument
	//
	if (nrhs < 1)
		mexErrMsgTxt("Has not input. Input argument is the name of ComboAmplifier device.");
	if (!mxIsChar(prhs[0]))
		mexErrMsgTxt("Input argument is not type of CHAR.");

	//
	// open the device
	//
	size_t nBufLen = mxGetM(prhs[0]) * mxGetN(prhs[0]) * sizeof(mxChar) + 1;
	char *strCom = (char *)calloc(nBufLen, sizeof(char));
	if (strCom==NULL)	mexErrMsgTxt("Not enough memory in heap.");
	mxGetString(prhs[0], strCom, (int)nBufLen);
	HANDLE hDevice = OpenComm(strCom);
	free(strCom);

	plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
	INT32 *pHandle = (INT32 *)mxGetData(plhs[0]);
	*pHandle = (INT32)hDevice;
}

// 打开指定的串口
HANDLE OpenComm(CString strCom)
{
	HANDLE hCom = NULL;
	strCom = "\\\\.\\" + strCom;		//// 微软预定义的标准设备中只含有“COM1”-“COM9”，COM10及以上串行端口应当使用"\\.\COM10"这样的串口专用名称
	//// 1. 打开串口
	hCom = CreateFile(strCom,		// COM口名称
		GENERIC_READ|GENERIC_WRITE, // 允许读和写
		0,							// 独占方式
		NULL,						// 引用安全性属性结构，缺省值为NULL；
		OPEN_EXISTING,				// 打开而不是创建
		0,							// 同步方式
		NULL);
	if (hCom == (HANDLE)-1)
	{
		// ErrorMessage(strCom+_T(": 打开串口失败!"));
		return hCom = NULL;
	}
	//// 2. 设置串口
	//	如果允许超时设置，快速读取虚拟串口数据时会出错。
	//	如果不允许超时，从阻抗测量设备以外的串口读取测试字符时，会因同步等待而无法返回。
	//	因此在查找阻抗测量设备时，以允许超时的方式打开串口，
	//	在正常使用阻抗测量设备时，以禁止超时的方式打开串口。
	//	此处为正常使用设备，因此禁止超时设置。
	SetupComm(hCom, 102400, 524288);		//输出(PC-->USB)缓冲区大小100KB，输入(USB-->PC)缓冲区的大小是512KB
	// COMMTIMEOUTS TimeOuts;					//设定读超时。单位均为ms。
	// TimeOuts.ReadIntervalTimeout = 0;			// 两个连续字节之间的超时时间。=0，表示不使用该超时参数
	// TimeOuts.ReadTotalTimeoutMultiplier = 0;	// 读操作的总超时时间。实际执行的超时时间要乘以读取的字节数。
	// TimeOuts.ReadTotalTimeoutConstant = 50;		// 读操作的超时常数。总超时 = ReadTotalTimeoutConstant + ReadTotalTimeoutMultiplier * 字节数 = 50 ms。
	// TimeOuts.WriteTotalTimeoutMultiplier = 10;
	// TimeOuts.WriteTotalTimeoutConstant = 10;
	// SetCommTimeouts(hCom, &TimeOuts);			// 设置超时
	DCB dcb;
	GetCommState(hCom, &dcb);
	dcb.BaudRate = 115200;						//波特率为115200
	dcb.ByteSize = 8;							//每个字节有8位
	dcb.Parity = NOPARITY;						//无奇偶校验位
	dcb.StopBits = ONESTOPBIT;					//1个停止位
	SetCommState(hCom, &dcb);
	PurgeComm( hCom, PURGE_TXABORT | PURGE_RXABORT | PURGE_TXCLEAR | PURGE_RXCLEAR ); //清干净输入、输出缓冲区
	return hCom;
}
