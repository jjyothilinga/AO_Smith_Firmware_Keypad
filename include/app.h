#include "board.h"




#define MAX_ENTRIES 16
#define	MAX_LENGTH_OF_ENTRY 8 

enum
{
	CMD_GET_LOG_STATUS = 0X80
};

enum
{ 
	PB1_CODE = 0X01,
	PB2_CODE = 0X02
};

typedef enum _STATION
{
	PB_RELEASED = 0,
	PB_HOLD_DOWN
}STATION;

extern void APP_init(void);
extern void APP_task(void);	
