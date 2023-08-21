/*=================================================================
 * ComboGetData.cpp
 * 读取已锁定的数据。调用本函数之前，必须先调用一次ComboGetLength函数，获取设备缓存区的数据长度。
 * 输入参数(Matlab中)：	prhs[0]，ComboOpen返回的一个设备句柄；
 *						prhs[1]，需要读取的数据长度，以数据点为单位。
 * 输出参数(Matlab中)：	plhs[0]，一体机设备内已经锁定的ADC24数据；
 *						plhs[1]，一体机设备内已经锁定的Port数据。
 * 
 * 编译方法：
 *		在Matlab命令行窗口中执行 mex -g ComboGetData.cpp -lWinmm.lib
 
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
	if (nrhs < 2)
		mexErrMsgTxt("输入参数错误。\n调用方法：\t[Adc24Data PortData] = ComboGetData(hDeviceHandle, nDataCount);");
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("Input argument is not type of HANDLE.");
	//
	// 获取输入参数
	//
	PHANDLE pDevice = (PHANDLE) mxGetData(prhs[0]);
	HANDLE hDevice = *pDevice;
	PINT32 pDataCount = (PINT32) mxGetData(prhs[1]);
	INT32 nDataCount = *pDataCount;

	//
	// 获取输出接口，并分配输出缓存区
	//
	plhs[0] = mxCreateNumericMatrix(1, nDataCount, mxINT32_CLASS, mxREAL);	// 生成Adc24数据缓存区，并指派给第一个输出参数
	INT32 *pData = (INT32 *)mxGetData(plhs[0]);								// 取得缓存区实际存放数据的地址指针
	plhs[1] = mxCreateNumericMatrix(2, nDataCount, mxINT16_CLASS, mxREAL);	// 生成Adc1数据缓存区，并指派给第二个输出参数
	UINT8 *pAdc1Data = (UINT8 *)mxGetData(plhs[1]);							// 取得缓存区实际存放数据的地址指针
	plhs[2] = mxCreateNumericMatrix(1, nDataCount, mxUINT8_CLASS, mxREAL);	// 生成Port数据缓存区，并指派给第三个输出参数
	UINT8 *pPortData = (UINT8 *)mxGetData(plhs[2]);							// 取得缓存区实际存放数据的地址指针


	DWORD dwRet;
	COMMAND_MESSAGE Cmd = {0};
	CString str;
	DWORD dwTransNum = 0;

	//
	// 要求读取设备缓存区内的ADC及Port数据
	// 
	Cmd.SyncMark = 0xAA5500FF;
	Cmd.nCommand = ADC24_READ_BUFFER;
	Cmd.Param0 = nDataCount;
	if (!WriteFile(hDevice, &Cmd, sizeof(COMMAND_MESSAGE), &dwRet, NULL))
	{
		str.Format("ComboGetData函数：向设备写入数据时发生错误。Handle = %d\n", hDevice);
		mexWarnMsgTxt(str);
	}
	Sleep(0);
	//
	// 读取Port端口数据
	// 
	COMMAND_MESSAGE Vendor;
	Vendor.SyncMark = 0xAA5500FF;
	Vendor.nCommand = CMD_GET_VENDOR;		// 识别设备设计者
	INT32 nNeedCount = nDataCount;
	PUINT8 pReadBuf = pPortData;
	INT32 nExtDataNum = 0;					// 传输堵死计数器
	do 
	{
		DWORD dwTime = timeGetTime();
		ReadFile(hDevice, pPortData, nNeedCount, &dwRet, NULL);
		if (nNeedCount != dwRet)
		{
			DWORD dwDelayTime = timeGetTime();
			pReadBuf += dwRet;
			nNeedCount -= dwRet;
			//// 激活USB通道试试 <-- 写入一个命令后，都不用读，USBlyzer立即监视到有数据从MCU输出到串口缓存区。
			//// 由此证实，IN数据卡死的问题是出在了STM32上，STM32没有送数据出来。
			//// 还不是随便写个什么东西到USB就行的，必须要由STM32发送新的数据，原来在USB缓冲区的数据才能一起出来。
			WriteFile(hDevice, &Vendor, sizeof(COMMAND_MESSAGE), &dwRet, NULL);
			nExtDataNum++;
//			str.Format("STM32的USB IN传输堵死了一次，耗时%d ms。已经恢复现场\n", dwDelayTime - dwTime);
			str.Format("\n", dwDelayTime - dwTime);
			mexWarnMsgTxt(str);
		}
		else
			break;
	} while (nNeedCount);
	while (nExtDataNum--)
		ReadFile(hDevice, &Vendor, sizeof(COMMAND_MESSAGE), &dwRet, NULL);	// 读出全部的开发者信息
	//
	// 读取ADC1数据
	// 
	nNeedCount = nDataCount * 2 * sizeof(UINT16);
	pReadBuf = (PUINT8) pAdc1Data;
	nExtDataNum = 0;					// 传输堵死计数器
	do 
	{
		DWORD dwTime = timeGetTime();
		ReadFile(hDevice, pAdc1Data, nNeedCount, &dwRet, NULL);
		if (nNeedCount != dwRet)
		{
			DWORD dwDelayTime = timeGetTime();
			pReadBuf += dwRet;
			nNeedCount -= dwRet;
			//// 激活USB通道试试 <-- 写入一个命令后，都不用读，USBlyzer立即监视到有数据从MCU输出到串口缓存区。
			//// 由此证实，IN数据卡死的问题是出在了STM32上，STM32没有送数据出来。
			//// 还不是随便写个什么东西到USB就行的，必须要由STM32发送新的数据，原来在USB缓冲区的数据才能一起出来。
			WriteFile(hDevice, &Vendor, sizeof(COMMAND_MESSAGE), &dwRet, NULL);
			nExtDataNum++;
//			str.Format("STM32的USB IN传输堵死了一次，耗时%d ms。已经恢复现场\n", dwDelayTime - dwTime);
			str.Format("\n", dwDelayTime - dwTime);
			mexWarnMsgTxt(str);
		}
		else
			break;
	} while (nNeedCount);
	while (nExtDataNum--)
		ReadFile(hDevice, &Vendor, sizeof(COMMAND_MESSAGE), &dwRet, NULL);	// 读出全部的开发者信息
	//
	// 读取Adc24数据
	// 
	nNeedCount = nDataCount * sizeof(INT32);
	pReadBuf = (PUINT8) pData;
	nExtDataNum = 0;
	do 
	{
		DWORD dwTime = timeGetTime();
		ReadFile(hDevice, pReadBuf, nNeedCount, &dwRet, NULL);
		if (nNeedCount != dwRet)
		{
			DWORD dwDelayTime = timeGetTime();
			pReadBuf += dwRet;
			nNeedCount -= dwRet;
			//// 激活USB通道试试 <-- 写入一个命令后，都不用读，USBlyzer立即监视到有数据从MCU输出到串口缓存区。
			//// 由此证实，IN数据卡死的问题是出在了STM32上，STM32没有送数据出来。
			//// 还不是随便写个什么东西到USB就行的，必须要由STM32发送新的数据，原来在USB缓冲区的数据才能一起出来。
			Vendor.SyncMark = 0xAA5500FF;
			Vendor.nCommand = CMD_GET_VENDOR;		// 识别设备设计者
			WriteFile(hDevice, &Vendor, sizeof(COMMAND_MESSAGE), &dwRet, NULL);
			nExtDataNum++;
//			str.Format("STM32的USB IN传输堵死了一次，耗时%d ms。已经恢复现场\n", dwDelayTime - dwTime);
			str.Format("\n", dwDelayTime - dwTime);
			mexWarnMsgTxt(str);
		}
		else
			break;
	} while (nNeedCount);
	while (nExtDataNum--)
		ReadFile(hDevice, &Vendor, sizeof(COMMAND_MESSAGE), &dwRet, NULL);	// 读出全部的开发者信息
}
