/*=================================================================
* ComboQuery.cpp 
*	Version 1.10
* 查询电生理一体机设备
* 输入参数(Matlab中)：无
* 输出参数(Matlab中)：Device，设备串口号列表。二维字符串数组，每一行是一个串口设备名称。
* 
* 编译方法：
*		在Matlab命令行窗口中执行 mex -g ComboQuery.cpp

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

#define StrLen 20					// 设备名称的长度，最多20个字符

HANDLE OpenComm(CString strCom);
int SearchDevice(void);
BOOL IdentifyComboAmp(CString tchValue);

TCHAR (*ptcDevice)[StrLen];			// 二维数组指针，保存所有查找到的设备名称。每一行存放一个设备名，属于C语言摆放方式。


void mexFunction(
	int nlhs, mxArray *plhs[],			// 左值，输出参数表
	int nrhs, const mxArray *prhs[])	// 右值，输入参数表
{
	int nDeviceNum = 0;
	ptcDevice = NULL;
	mxArray *pDeviceName;

	nDeviceNum = SearchDevice();
	// mexPrintf("\nFound %d device(s).\n", nDeviceNum);

	if (nDeviceNum > 0)
	{
		// 生成返回值mxArray数组
		mwSize ndim = 2;	// 指定生成数组的维数，二维
		mwSize dims[2];	// 生成 dims[0] * dims[1] 数组
		dims[0] = nDeviceNum; dims[1] = StrLen;
		pDeviceName = mxCreateCharArray (ndim, dims);
		mxChar *charData = (mxChar *)mxGetData(pDeviceName);

		// Matlab内部的字符串数据是按列排放的，所以要转换ptcDevice内数据的行列顺序。
		TCHAR* pMatlabDeviceName = new TCHAR[StrLen*nDeviceNum];
		TCHAR* pTemp = pMatlabDeviceName;
		for (int i=0; i<StrLen; i++)
			for (int k=0; k<nDeviceNum; k++)
				*pTemp++ = ptcDevice[k][i];
		// Matlab的字符串为wchar_t宽字符型，需要将char_t型转换为wchar_t型
		int wLen = MultiByteToWideChar(CP_ACP, 0, (LPCSTR)pMatlabDeviceName, nDeviceNum*StrLen, NULL, 0);	// 第一次调用是取得需要转换空间的大小
		MultiByteToWideChar(CP_ACP, 0, (LPCSTR)pMatlabDeviceName, nDeviceNum*StrLen, charData, wLen);		// 第二次调用完成转换过程


		delete [] ptcDevice;
		delete [] pMatlabDeviceName;
	}
	else
		pDeviceName = mxCreateCharArray (0, 0);

	// 用默认返回值ans传递设备名称
	plhs[0] = pDeviceName;
}


// 搜索串口硬件设备。返回值：设备数量
int SearchDevice(void)
{
	delete [] ptcDevice;
	ptcDevice = NULL;
	int nDeviceNum = 0;
	HKEY hkey;
	LONG lRes = RegOpenKeyEx(HKEY_LOCAL_MACHINE, _T( "HARDWARE\\DEVICEMAP\\SERIALCOMM"), NULL, KEY_QUERY_VALUE | KEY_ENUMERATE_SUB_KEYS | KEY_READ, &hkey);
	if (lRes == ERROR_SUCCESS)
	{ 
		TCHAR tchKey[MAX_PATH];
		TCHAR tchValue[StrLen];
		DWORD dwIndex = 0;
		DWORD dwType = REG_SZ;
		while(lRes == ERROR_SUCCESS)
		{
			DWORD dwCount = MAX_PATH;
			DWORD dwVCount = StrLen;
			for(int k=0; k<StrLen; k++)	tchValue[k] = 0;				// 将字符数组填0
			lRes = RegEnumValue(hkey, dwIndex++, tchKey, &dwCount, NULL, &dwType, (LPBYTE)tchValue, &dwVCount);
			if(lRes == ERROR_SUCCESS)
			{
				if((dwVCount > 0) && (dwCount > 0))
				{
					if (IdentifyComboAmp(tchValue))
					{
						/*	// 调试输出找到的设备
						mexPrintf("Device %d: ", nDeviceNum);
						for (int k=0; k<StrLen; k++)
							mexPrintf("%c(%d) ", tchValue[k], tchValue[k]);
						mexPrintf("\n");
						*/

						nDeviceNum++;
						// m_DeviceComBox.AddString(tchValue);
						TCHAR (*DeviceName)[StrLen] = new TCHAR[nDeviceNum][StrLen];
						if (DeviceName == NULL)	mexErrMsgTxt("Not enough memory in heap.\n");
						else
						{
							for (int i=0; i<nDeviceNum-1; i++)
							{
								for(int k=0; k<StrLen; k++)
									DeviceName[i][k] = ptcDevice[i][k];	// 将原有的设备名称填入数组
							}
							for(int k=0; k<StrLen; k++)
								DeviceName[nDeviceNum-1][k] = tchValue[k];			// 将最新获取的设备名称填入数组
							delete [] ptcDevice;
							ptcDevice = DeviceName;
						}
					}
				}
			}
		}
	}
	RegCloseKey(hkey);

	return nDeviceNum;
}


// 鉴定是否是一体化放大器设备
BOOL IdentifyComboAmp(CString tchValue)
{
	HANDLE hCom = OpenComm(tchValue);	// 串口句柄
	DWORD dwRet;
	COMMAND_MESSAGE Cmd = {0};

	Cmd.SyncMark = 0xAA5500FF;
	Cmd.nCommand = CMD_GET_DEVICE;		// 识别设备
	BOOL bRet = WriteFile(hCom, &Cmd, sizeof(COMMAND_MESSAGE), &dwRet, NULL);		// if (!bRet)	ErrorMessage("WriteFile Error");
	Sleep(20);
	bRet = ReadFile(hCom, &Cmd, sizeof(COMMAND_MESSAGE), &dwRet, NULL);				// if (!bRet)	ErrorMessage("ReadFile Error");
	if (strncmp((char*)&Cmd.Param0, "ComoboAmp", 9) == 0)							//// 一体化放大器会回答“ComoboAmp”
		bRet = TRUE;
	else
	{
		//// 关闭串口
		CloseHandle(hCom);
		return FALSE;
	}

	Cmd.SyncMark = 0xAA5500FF;
	Cmd.nCommand = CMD_GET_VENDOR;		// 识别设备设计者
	bRet = WriteFile(hCom, &Cmd, sizeof(COMMAND_MESSAGE), &dwRet, NULL);		// if (!bRet)	ErrorMessage("WriteFile Error");
	Sleep(2);
	bRet = ReadFile(hCom, &Cmd, sizeof(COMMAND_MESSAGE), &dwRet, NULL);				// if (!bRet)	ErrorMessage("ReadFile Error");
	if (strncmp((char*)&Cmd.Param0, "Bluesky", 9) == 0)							//// 一体化放大器会回答“Bluesky”
		bRet = TRUE;
	else
		bRet = FALSE;

	//// 关闭串口
	CloseHandle(hCom);
	return bRet;
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
	//	在此处为查找设备，因此允许超时设置。
	SetupComm(hCom, 102400, 524288);		//输出(PC-->USB)缓冲区大小100KB，输入(USB-->PC)缓冲区的大小是512KB
	COMMTIMEOUTS TimeOuts;					//设定读超时。单位均为ms。
	TimeOuts.ReadIntervalTimeout = 0;			// 两个连续字节之间的超时时间。=0，表示不使用该超时参数
	TimeOuts.ReadTotalTimeoutMultiplier = 0;	// 读操作的总超时时间。实际执行的超时时间要乘以读取的字节数。
	TimeOuts.ReadTotalTimeoutConstant = 50;		// 读操作的超时常数。总超时 = ReadTotalTimeoutConstant + ReadTotalTimeoutMultiplier * 字节数 = 50 ms。
	TimeOuts.WriteTotalTimeoutMultiplier = 10;
	TimeOuts.WriteTotalTimeoutConstant = 10;
	SetCommTimeouts(hCom, &TimeOuts);			// 设置超时
	DCB dcb; GetCommState(hCom, &dcb);
	dcb.BaudRate = 115200;						//波特率为115200
	dcb.ByteSize = 8;							//每个字节有8位
	dcb.Parity = NOPARITY;						//无奇偶校验位
	dcb.StopBits = ONESTOPBIT;					//1个停止位
	SetCommState(hCom, &dcb);
	PurgeComm( hCom, PURGE_TXABORT | PURGE_RXABORT | PURGE_TXCLEAR | PURGE_RXCLEAR ); //清干净输入、输出缓冲区
	return hCom;
}
