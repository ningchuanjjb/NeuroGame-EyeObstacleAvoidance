#pragma once

typedef enum __MESSAGE_TYPE__		// USB传递消息类型枚举
{
	CMD_GET_DEVICE = 0,				// PC-->MCU，询问设备名称。必须应答“ComoboAmp”
	CMD_GET_VENDOR,					// PC-->MCU，询问设备设计师。必须应答“Bluesky”
	ADC24_LOCK_BUFFER,				// PC-->MCU，
	ADC24_READ_BUFFER,				// PC-->MCU，
	ADC16_CONFIG,					// PC-->MCU，
	ADC16_LOCK_BUFFER,				// PC-->MCU，
	ADC16_READ_BUFFER,				// PC-->MCU，
	LED_CMD,						// PC-->MCU，控制LED指令
	TYPE_STATE,						// MCU-->PC，状态信息，含各种错误信息
} USB_Message_Data_Type;

typedef struct						// 指令消息包
{
	UINT32 SyncMark;				// 消息校验符，必须为0xAA5500FF
	UINT32 nCommand;				// 命令字
	UINT32 Param0;					// 消息参数0
	UINT32 Param1;					// 消息参数1
	UINT32 Param2;					// 消息参数2
} COMMAND_MESSAGE, *PCOMMAND_MESSAGE;
