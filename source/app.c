#include "board.h"
#include "app.h"
#include "linearkeypad.h"
#include "timer.h"


/*------------------------------------------------------------------------------
* Private Functions
*------------------------------------------------------------------------------
*/

void logWrite( far UINT8 *data, UINT8 length );
UINT8 logRead( far UINT8 **logBuff );
UINT8 APP_comCallBack( far UINT8 *rxPacket, far UINT8* txCode,far UINT8** txPacket);

/*
*------------------------------------------------------------------------------
* log Structures
*------------------------------------------------------------------------------
*/

typedef struct _EVENT_LOG
{
	UINT8 writeIndex;
	UINT8 readIndex;
	UINT8 logBuffer[MAX_ENTRIES][MAX_LENGTH_OF_ENTRY];
}EVENT_LOG;

/*
*------------------------------------------------------------------------------
* Variables
*------------------------------------------------------------------------------
*/

#pragma idata LOG_DATA
EVENT_LOG log = {0};
#pragma idata

/*
*------------------------------------------------------------------------------
* Global Variables
*------------------------------------------------------------------------------
*/
extern UINT16 PB1DelayCount;
extern UINT16 PB2DelayCount;

/*------------------------------------------------------------------------------
* 	APP STRUCT
*------------------------------------------------------------------------------
*/

typedef struct _APP
{
	UINT8 PB1Data[2];
	UINT8 PB2Data[2];
	STATION M1Status;
	STATION F1Status;
}APP;


APP app = {0};



/*---------------------------------------------------------------------------------------------------------------
*	APP INIT
*----------------------------------------------------------------------------------------------------------------
*/
void APP_init(void)
{
	COM_init(CMD_SOP , CMD_EOP ,RESP_SOP , RESP_EOP , APP_comCallBack);
}


/*---------------------------------------------------------------------------------------------------------------
*	APP TASK
*----------------------------------------------------------------------------------------------------------------
*/		
void APP_task(void)
{      
	if ( (LinearKeyPad_getKeyState(KEY0) == 1) && (app.M1Status != PB_HOLD_DOWN) )
	{
		if( PB1DelayCount >= MAX_PB1DELAYCOUNT)
		{
			app.PB1Data[0] = PB1_CODE;
			app.PB1Data[1] = 0X01;

			logWrite( &app.PB1Data, 2 );    // Write status of PORTB1

			app.M1Status = PB_HOLD_DOWN;
			PB1DelayCount = 0;
		}
	}
	else if (LinearKeyPad_getKeyState(KEY0) == 0)
		app.M1Status = PB_RELEASED;


	if ( (LinearKeyPad_getKeyState(KEY1) == 1)  && (app.F1Status != PB_HOLD_DOWN) )
    {
		if( PB2DelayCount >= MAX_PB2DELAYCOUNT)
		{
			app.PB2Data[0] = PB2_CODE;
			app.PB2Data[1] = 0X01;
	
			logWrite( &app.PB2Data, 2 );    // Write status of PORTB2	
		
			app.F1Status = PB_HOLD_DOWN;
			PB2DelayCount = 0;
		}
	}
	else if (LinearKeyPad_getKeyState(KEY1) == 0)
		app.F1Status = PB_RELEASED;

 
}	




   
/*---------------------------------------------------------------------------------------------------------------
*	void updateLog(void)
*----------------------------------------------------------------------------------------------------------------
*/
void logWrite( far UINT8 *data, UINT8 length )
{
	UINT8 i, j = 0;
	UINT8 temp = 0;
 
	//length = length * 2;   //length multiplied by number of bytes

	//Store data in the buffer
	for( i = 0, j = 0; i < length; i++ )
	{
		temp = *data ;
		temp &= 0XF0;
		temp >>= 4;

		log.logBuffer[log.writeIndex][j++] = (char) (temp + '0');

		temp = *data ;
		temp &= 0X0F;

		log.logBuffer[log.writeIndex][j++] = (char) (temp + '0');
		
		*data++;
	}

	log.logBuffer[log.writeIndex][j] = '\0'; //store null character to indicate end of the packet

	log.writeIndex++;
	if( log.writeIndex >= MAX_ENTRIES)
		log.writeIndex = 0;


}

/*---------------------------------------------------------------------------------------------------------------
*	UINT8 logRead(void)
*----------------------------------------------------------------------------------------------------------------
*/
UINT8 logRead( far UINT8** logBuff )
{
	UINT8 length = 0;

	if( log.writeIndex == log.readIndex )
	{
		*logBuff = 0;
	}
	else
	{
		*logBuff = log.logBuffer[log.readIndex];
		length = strlen( log.logBuffer[log.readIndex] );
		//length = 4;
		
		log.readIndex++;
		if( log.readIndex >= MAX_ENTRIES)
			log.readIndex = 0;	
	}

	return length;
			
}
/*---------------------------------------------------------------------------------------------------------------
*	APP CALLBACK
*----------------------------------------------------------------------------------------------------------------
*/
UINT8 APP_comCallBack( far UINT8 *rxPacket, far UINT8* txCode,far UINT8** txPacket)
{

	UINT8 i;

	UINT8 rxCode = rxPacket[0];
	volatile UINT8 length = 0;

	switch( rxCode )
	{
		case CMD_GET_LOG_STATUS:
			length = (UINT8) logRead(txPacket);
			*txCode = CMD_GET_LOG_STATUS;
		break;

		default:
			length = 0;
			
		break;

	}

	return length;

}