
#import <appkit/appkit.h>
#import "AppDefs.h"

@interface Spin: Control
{
	id		olControl1;
	id		olControl2;

	NXRect 	topRect;
	NXRect 	bottomRect;
	int		buttonDown;
	DPSTimedEntry timer;
	int		nTickCount;
	int		nNextAccelerateCount;
	float		fCurrTickTime;
	double		spinValue;			// Current value of spin
	double		spinStep;				// Step for each tick
	double		spinMin;
	double		spinMax;
	id			myStoredCellClass;	// For getting target/actoion stuff working
}

#define START_TICK_TIME .25
#define START_ACCELERATE_COUNT 3

#define TOP_BUTTON 1
#define BOTTOM_BUTTON 2

- tick;
- setRange: (float) min: (float) max step: (float) step startAt: (float) start;
@end
