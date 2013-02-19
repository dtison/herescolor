 
#import "Spin.h"

void spinHandler (DPSTimedEntry tag, double now, char *data);

@implementation Spin 

#if 0
+ initialize
{
    	/* Class initialization code. */

    	myStoredCellClass = [Button class];  // The default class
    	return self;
}

+ setCellClass: classId
{
    	myStoredCellClass = classId;
    	return self;
}
#endif

- initFrame: (const NXRect *) frameRect
{
	[super initFrame: frameRect];

	/*  Divide ourself into two rectangles and paint a button in each  */

	topRect = bounds;

	NXInsetRect (&topRect, 1, 1);
	NXDivideRect (&topRect, &bottomRect, (bounds.size.height / 2) - 1, NX_YMIN);

	nNextAccelerateCount = START_ACCELERATE_COUNT;
	fCurrTickTime = START_TICK_TIME;

	[self setRange: 0.000: 1.0 step: 0.01 startAt: 0.5];

	timer = NULL;

	{
   		id oldCell;

    		[super initFrame: frameRect];
    		oldCell = [self setCell: [[myStoredCellClass alloc] init]];
    		[oldCell free];
	}



	return self;
}

- drawSelf: (const NXRect *) rects: (int) rectCount
{
	NXCoord	arrowSize, halfArrowSize;
	NXCoord  halfHorizRemainder;
	NXCoord  halfVertRemainder;
	NXCoord	xOffset;      


	if (buttonDown == 1)	// Top active
	{
		NXDrawGrayBezel (&topRect, &topRect);
		NXDrawButton (&bottomRect, &bottomRect);
	}
	else
		if (buttonDown == 2)	// Bottom active
		{
			NXDrawGrayBezel (&bottomRect, &bottomRect);
			NXDrawButton (&topRect, &topRect);
		}
		else
		{
			NXDrawButton (&topRect, &topRect);
			NXDrawButton (&bottomRect, &bottomRect);
		}


	/*  Now draw the arrows  */

	PSsetgray (0);

	arrowSize = MIN (topRect.size.width, topRect.size.height) * .60;
	arrowSize = rint (arrowSize);

	halfArrowSize = arrowSize / 2;
	halfArrowSize = floor (halfArrowSize);

	halfHorizRemainder = (topRect.size.width - arrowSize) / 2;
	halfVertRemainder = (topRect.size.height - halfArrowSize) / 2;	
	/*  Draw down arrow  */

	PSnewpath();

	xOffset = ((buttonDown == BOTTOM_BUTTON) ? 3 : 1);

	PSmoveto (halfHorizRemainder + halfArrowSize + xOffset, 
			halfVertRemainder + halfArrowSize + 1);
	PSrlineto (-halfArrowSize, 0);
	PSrlineto (halfArrowSize, -halfArrowSize);
	PSrlineto (halfArrowSize, +halfArrowSize);

	PSclosepath ();
	PSfill();

	/*  Now up arrow  */

	PSnewpath();
	PStranslate (0, bottomRect.size.height);

	xOffset = ((buttonDown == TOP_BUTTON) ? 3 : 1);

	PSmoveto (halfHorizRemainder + halfArrowSize + xOffset, halfVertRemainder + 1);
	PSrlineto (-halfArrowSize, 0);
	PSrlineto (halfArrowSize, halfArrowSize);
	PSrlineto (halfArrowSize, -halfArrowSize);

	PSclosepath ();
	PSfill();
	
	{
		NXRect tmpRect = bounds;
		NXInsetRect (&tmpRect, 2, 2); 
//		NXFrameRect (&tmpRect);
	}
	return self;
}

- mouseDown: (NXEvent *) theEvent
{
	NXPoint *point;

	point = &theEvent -> location;
	[self convertPoint: point fromView: nil];

	if (NXMouseInRect (point, &topRect, NO))
		buttonDown = TOP_BUTTON;
	else
		if (NXMouseInRect (point, &bottomRect, NO))
			buttonDown = BOTTOM_BUTTON;

	if (buttonDown)
	{
		/*  Start ticking  */

		[self tick];
		if (! timer)
			timer = DPSAddTimedEntry (fCurrTickTime, (DPSTimedEntryProc) &spinHandler, 
									self, NX_BASETHRESHOLD);

		[self display];
	}

	[window setDocEdited: YES];
	return self;
}

- mouseUp: (NXEvent *) theEvent
{
	buttonDown = NO;
	if (timer)
	{
		DPSRemoveTimedEntry (timer);
		timer = NULL;
	}

	nNextAccelerateCount = START_ACCELERATE_COUNT;
	fCurrTickTime = START_TICK_TIME;
	nTickCount = 0;

	[self display];

	return self;
}


void spinHandler (DPSTimedEntry tag, double now, char *data)
{
	[(id) data tick];
}

/*  Handles our ticks.  Automatically accelerates as user holds button down  */

- tick
{
	float		temp;

	nTickCount++;

	if (nTickCount >= nNextAccelerateCount && fCurrTickTime > .015)
	{
		fCurrTickTime *= .5;
		nNextAccelerateCount = (int) ((float) nNextAccelerateCount * 1.5);
		nTickCount = 0;

		if (timer)
		{
			DPSRemoveTimedEntry (timer);
			timer = DPSAddTimedEntry (fCurrTickTime,
									(DPSTimedEntryProc) &spinHandler, 
									self, 
									NX_BASETHRESHOLD);
		}
	}	

	if (buttonDown == TOP_BUTTON)
	{
		temp = spinValue + spinStep;
		if (temp > spinMax)
			temp = spinMax;

		spinValue = temp;	 
	}
	else
	{
		temp = spinValue - spinStep;
		if (temp < spinMin)
			temp = spinMin;

		spinValue = temp;
	}

	if (olControl1)
	{
		char 	szBuffer [80];

		sprintf (szBuffer, "%4.2f", spinValue);
	 	[olControl1 setStringValue: szBuffer];

	}
	return self;
}

- setFloatValue: (float) value
{
	spinValue = value;
	return self;
}

- (float) floatValue
{
	return spinValue;
}


- setRange: (float) min: (float) max step: (float) step startAt: (float) start
{
	spinMin 	= min;
	spinMax 	= max;
	spinStep 	= step;
	spinValue = start;

	if (olControl1)
	{
		char 	szBuffer [80];

		sprintf (szBuffer, "%4.2f", spinValue);
		[olControl1 setStringValue: szBuffer];
	}


	return self;
}

- takeFloatValueFrom: sender
{
	spinValue = [sender floatValue];
	if (spinValue > spinMax)
		spinValue = spinMax;
	else
		if  (spinValue < spinMin)
			spinValue = spinMin;

	[sender setFloatValue: spinValue];

	return self;
}



@end
