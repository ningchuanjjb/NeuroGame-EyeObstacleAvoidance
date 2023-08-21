/*=================================================================
 * ComboRead.cpp 
 * 从指定的电生理一体机设备读取数据。
 * 语法格式
 *		[A, count] = ComboRead(hDevice, sizeA, precision);
 * 输入参数：	hDevice	- 设备句柄
 *				sizeA	- 读取的数据个数
 *				precision - 每个数据单元占据的字节空间，如INT32占据4字节，该参数就是4。
 * 输出参数：	A		- 读取的数据矩阵，按列优先排放。
 *				count	- 实际读取的数据个数
 
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

#define StrLen 20

void mexFunction(
	int nlhs, mxArray *plhs[],
	int nrhs, const mxArray *prhs[])
{
	UINT8 precision = 1;	// 一个数据通讯单元占据的字节空间。默认为uint8型，每个数据点占用1个字节。
	UINT32 count = 0;		
	char* pPrecisionStr = (char*) mxMalloc(StrLen);
	//
	// chech the input argument 
	//
	if (nlhs < 2)
		mexErrMsgTxt("输入参数错误。\n调用方法：\t[A, count] = ComboRead(hDevice, sizeA, precision);\n\tprecision默认为uint8类型");
	if (nrhs == 3)
	{
		mxGetString(prhs[2], pPrecisionStr, StrLen);
		// int nLen = WideCharToMultiByte(CP_ACP, 0, (LPCWSTR)pPrecisionWStr, -1, NULL, 0, NULL, NULL);	// 第一次调用是取得需要转换空间的大小
		// WideCharToMultiByte(CP_ACP, 0, (LPCWSTR)pPrecisionWStr, -1, pPrecisionStr, nLen, NULL, NULL);	// 第二次调用完成转换过程
		CString strPrecision(pPrecisionStr);
		if (strPrecision.Compare("uchar") == 0)			precision = sizeof(UCHAR);
		else if (strPrecision.Compare("schar") == 0)	precision = sizeof(CHAR);
		else if (strPrecision.Compare("char") == 0)		precision = sizeof(CHAR);
		else if (strPrecision.Compare("int8") == 0)		precision = sizeof(INT8);
		else if (strPrecision.Compare("int16") == 0)	precision = sizeof(INT16);
		else if (strPrecision.Compare("int32") == 0)	precision = sizeof(INT32);
		else if (strPrecision.Compare("uint8") == 0)	precision = sizeof(UINT8);
		else if (strPrecision.Compare("uint16") == 0)	precision = sizeof(UINT16);
		else if (strPrecision.Compare("uint32") == 0)	precision = sizeof(UINT32);
		else if (strPrecision.Compare("short") == 0)	precision = sizeof(SHORT);
		else if (strPrecision.Compare("int") == 0)		precision = sizeof(INT);
		else if (strPrecision.Compare("long") == 0)		precision = sizeof(LONG);
		else if (strPrecision.Compare("ushort") == 0)	precision = sizeof(USHORT);
		else if (strPrecision.Compare("uint") == 0)		precision = sizeof(UINT);
		else if (strPrecision.Compare("ulong") == 0)	precision = sizeof(ULONG);
		else if (strPrecision.Compare("single") == 0)	precision = sizeof(FLOAT);
		else if (strPrecision.Compare("float32") == 0)	precision = sizeof(FLOAT);
		else if (strPrecision.Compare("float") == 0)	precision = sizeof(FLOAT);
		else if (strPrecision.Compare("double") == 0)	precision = sizeof(DOUBLE);
		else if (strPrecision.Compare("float64") == 0)	precision = sizeof(DOUBLE);
		else	mexErrMsgTxt("输入参数错误。precision参数错误，参见fread中的precision有效参数表\n");
	}


	//
	// 获取输入参数
	//
	PHANDLE pDevice = (PHANDLE) mxGetData(prhs[0]);
	HANDLE hDevice = *pDevice;
	PINT32 pSizeA = (PINT32) mxGetData(prhs[1]);
	INT32 size = *pSizeA;


/*
	//
	// 获取输出接口，并分配输出缓存区
	//
	plhs[0] = mxCreateNumericMatrix(1, nDataCount, mxINT32_CLASS, mxREAL);	// 生成缓存区，并指派给第一个输出参数
	INT32 *pData = (INT32 *)mxGetData(plhs[0]);								// 取得缓存区实际存放数据的地址指针

	
	int        i;
       
    / * Examine input (right-hand-side) arguments. * /
    mexPrintf("\nThere are %d right-hand-side argument(s).", nrhs);
    for (i=0; i<nrhs; i++)  {
        mexPrintf("\n\tInput Arg %i is of type:\t%s ",i,mxGetClassName(prhs[i]));
    }
    
    / * Examine output (left-hand-side) arguments. * /
    mexPrintf("\n\nThere are %d left-hand-side argument(s).\n", nlhs);
    if (nlhs > nrhs)
      mexErrMsgIdAndTxt( "MATLAB:mexfunction:inputOutputMismatch",
              "Cannot specify more outputs than inputs.\n");
    
    for (i=0; i<nlhs; i++)  {
        plhs[i]=mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(plhs[i])=(double)mxGetNumberOfElements(prhs[i]);
    }
*/




	if (nlhs == 2)
	{
		plhs[1] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);	// 生成缓存区，并指派给第一个输出参数
		PINT32 pDataCount = (PINT32) mxGetData(plhs[1]);				// 取得缓存区实际存放数据的地址指针，内含实际读取的数据量
		*pDataCount = count;
	}

	mxFree(pPrecisionStr);
}

