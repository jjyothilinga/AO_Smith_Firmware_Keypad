#line 1 "source\digitdisplay.c"
#line 1 "source\digitdisplay.c"

#line 17 "source\digitdisplay.c"
 

typedef enum
{
	STATIC = 0,
	BLINK 
}DISPLAY_MODE;



#line 30 "source\digitdisplay.c"
 





#line 38 "source\digitdisplay.c"
 



#line 45 "source\digitdisplay.c"
 

typedef struct _DigitDisplay
{
	DISPLAY_MODE mode;
	UINT8 buffer[2][MAX_DIGITS];	
	UINT8 noDigits;			
	UINT8 digitIndex;	
	UINT16 blinkCount;	
	UINT16 blinkPeriod;	
	UINT8* dispBuffer; 

}DigitDisplay;



#line 64 "source\digitdisplay.c"
 

static UINT8 SEVENSEGMENT[] ={0x3f,0x06,0x5b,0x4f,0x66,
							  0x6d,0x7d,0x07,0x7f,0x6f,0x00};

#pragma idata	DISPLAY_DATA
DigitDisplay digitDisplay = {0};
#pragma idata

#line 76 "source\digitdisplay.c"
 

static void writeToDisplayPort( UINT8 );
static UINT8 validate( UINT8 value );

#line 84 "source\digitdisplay.c"
 





#line 101 "source\digitdisplay.c"
 

BOOL DigitDisplay_init( UINT8 noDigits )
{
	UINT8 i,j,k;
	if( noDigits > MAX_DIGITS )	
		return FAILURE;

	digitDisplay.noDigits = noDigits;				
	for( i = 0; i < digitDisplay.noDigits; i++)
	{
		digitDisplay.buffer[BLINK][i] = SEVENSEGMENT[10];		
	}
	digitDisplay.dispBuffer = digitDisplay.buffer[STATIC];	

#line 131 "source\digitdisplay.c"
	digitDisplay.digitIndex  = 0;
	
	return SUCCESS;
}


#line 149 "source\digitdisplay.c"
 

void DigitDisplay_task(void)
{
	switch(digitDisplay.mode)
	{
		case STATIC :
			writeToDisplayPort( digitDisplay.dispBuffer[digitDisplay.digitIndex] );
			digitDisplay.digitIndex++;	
			if(digitDisplay.digitIndex >= digitDisplay.noDigits )
			{
				digitDisplay.digitIndex = 0;
			}
		break;

		case BLINK:

			writeToDisplayPort( digitDisplay.dispBuffer[digitDisplay.digitIndex] );
			digitDisplay.digitIndex++;	
			if(digitDisplay.digitIndex >= digitDisplay.noDigits )
			{
				digitDisplay.digitIndex = 0;
			}

			digitDisplay.blinkCount++;
			if( digitDisplay.blinkCount >= digitDisplay.blinkPeriod )
			{
				digitDisplay.blinkCount = 0;
				if( digitDisplay.dispBuffer == digitDisplay.buffer[STATIC] )
					digitDisplay.dispBuffer = digitDisplay.buffer[BLINK];
				else
					digitDisplay.dispBuffer = digitDisplay.buffer[STATIC];
			}
		break;

		default:
		break;
	}
				
		
	
}



#line 206 "source\digitdisplay.c"
 

BOOL DigitDisplay_updateBuffer(UINT8 *buffer)
{
	UINT8 i = 0;

#line 216 "source\digitdisplay.c"
 
	for ( i = 0 ; i < digitDisplay.noDigits ; i++)
	{
		if( buffer[i] == ' ')
		{
			digitDisplay.buffer[STATIC][i] = SEVENSEGMENT[10];
		}
		else
		{
			digitDisplay.buffer[STATIC][i] = SEVENSEGMENT[buffer[i] - '0'];
		}
	}
	digitDisplay.digitIndex = 0;
	return SUCCESS;
}



#line 246 "source\digitdisplay.c"
 

BOOL DigitDisplay_updateBufferBinary(UINT8 *buffer)
{
	UINT8 i = 0;

	for ( i = 0 ; i < digitDisplay.noDigits ; i++)
	{
		digitDisplay.buffer[STATIC][i] = buffer[i] ;

	}
	digitDisplay.digitIndex = 0;
	
}




#line 277 "source\digitdisplay.c"
 

BOOL DigitDisplay_updateDigit(UINT8 index , UINT8 value)
{
	UINT8 i = 0;
	if(index > digitDisplay.noDigits )	
		return FAILURE;

	if ( validate(value) == FAILURE )
		return FAILURE;

	if( value == ' ')
	{
		digitDisplay.buffer[STATIC][index] = SEVENSEGMENT[10];
	}
	else
	{
		digitDisplay.buffer[STATIC][index] = SEVENSEGMENT[value - '0'];
	}

	return SUCCESS;
}



#line 315 "source\digitdisplay.c"
 

void DigitDisplay_blinkOn(UINT16 blinkPeriod)
{
	digitDisplay.blinkPeriod = blinkPeriod /DISPLAY_REFRESH_PERIOD;	
	digitDisplay.blinkCount = 0;									
	digitDisplay.mode = BLINK;										
}	




#line 340 "source\digitdisplay.c"
 

void DigitDisplay_blinkOff()
{
	digitDisplay.dispBuffer = digitDisplay.buffer[STATIC]; 
	digitDisplay.mode = STATIC;							   
}	






#line 363 "source\digitdisplay.c"
 


void DigitDisplay_clear()
{
	UINT8 i;
	for( i = 0 ; i < digitDisplay.noDigits ; i++)
	{
		digitDisplay.buffer[STATIC][i] = SEVENSEGMENT[10];
	}
	digitDisplay.digitIndex = 0;
}







#line 385 "source\digitdisplay.c"
 


#line 399 "source\digitdisplay.c"
 


#line 432 "source\digitdisplay.c"

static void writeToDisplayPort( UINT8 value )
{

	DIGIT_SEL_A = 0;		
	DIGIT_SEL_B = 0;
	

	DISPLAY_PORT = (value);

	switch( digitDisplay.digitIndex )
	{
		case 0:
			DIGIT_SEL_A = 1;
			
		break;

		case 1:
   			DIGIT_SEL_B = 1;
		break;

		
		default:
		break;
	}
	
}

#line 461 "source\digitdisplay.c"



static BOOL validate( UINT8 value)
{
	BOOL result = FAILURE;
	if( value == ' ' )
	{
		result = SUCCESS;
	}
	else if( value >= '0' && value <= '9'  )
	{
		result = SUCCESS;
	}
	return result;
}
		
