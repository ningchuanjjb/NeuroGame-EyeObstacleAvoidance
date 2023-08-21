/*=================================================================
 * ComboWrite.cpp
 * 向指定的电生理一体机设备写入数据。
 * 语法格式
 *		count = ComboWrite(hDevice, sizeA, precision);
 * 输入参数：	hDevice	- 设备句柄
 *				sizeA	- 写入的数据个数
 *				precision - 写入数据的数据精度
 * 输出参数：	count	- 实际写入的数据个数
 
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
	int nlhs, mxArray *plhs[],
	int nrhs, const mxArray *prhs[])
{
    int        i;
       
    /* Examine input (right-hand-side) arguments. */
    mexPrintf("\nThere are %d right-hand-side argument(s).", nrhs);
    for (i=0; i<nrhs; i++)  {
        mexPrintf("\n\tInput Arg %i is of type:\t%s ",i,mxGetClassName(prhs[i]));
    }
    
    /* Examine output (left-hand-side) arguments. */
    mexPrintf("\n\nThere are %d left-hand-side argument(s).\n", nlhs);
    if (nlhs > nrhs)
      mexErrMsgIdAndTxt( "MATLAB:mexfunction:inputOutputMismatch",
              "Cannot specify more outputs than inputs.\n");
    
    for (i=0; i<nlhs; i++)  {
        plhs[i]=mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(plhs[i])=(double)mxGetNumberOfElements(prhs[i]);
    }
}

