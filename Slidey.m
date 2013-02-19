#import "Slidey.h"

@implementation Slidey

- initFrame: (const NXRect *) frameRect
{
	[super initFrame: frameRect];

	[self setRange: 200: 400 startAt: 300];
	
	return self;
}

- drawSelf: (const NXRect *) rects: (int) rectCount
{
	PSsetgray (NX_LTGRAY);
	NXRectFill (&bounds); 
    	if (ratio > 0)
	{
		NXRect r = bounds;  
		r.size.width = bounds.size.width * ratio; 
		PSsetgray (NX_DKGRAY);
		NXRectFill (&r); 
    	}
	PSsetgray (NX_BLACK);
	NXFrameRect (&bounds);

	return self;
}

- mouseDown: (NXEvent *) theEvent
{
	NXPoint *point;

	point = &theEvent -> location;
	[self convertPoint: point fromView: nil];

	slideyPosition = slideyRange *  (point -> x / (bounds.size.width - 1));
	[self setRatio: slideyPosition / slideyRange];
	[self display];

	[window setDocEdited: YES];

    	[window addToEventMask: NX_LMOUSEDRAGGEDMASK];

	return self;
}

- mouseDragged: (NXEvent *) theEvent
{
	NXPoint *point;

	point = &theEvent -> location;
	
	[self convertPoint: point fromView: nil];

	/*  First test for out of bounds  */

	if (! [self mouse: point inRect: &bounds])
	{
		return self;
	}

	slideyPosition = slideyRange *  (point -> x / (bounds.size.width - 1));
	[self setRatio: slideyPosition / slideyRange];
	[self display];

	return self;
}

- mouseUp: (NXEvent *) theEvent
{
    	[window removeFromEventMask: NX_LMOUSEDRAGGEDMASK];
	return self;
}

- setRatio: (float) aRatio
{
	ratio = aRatio;
	
	/*  Also calculate actual position  */

	if (olControl1 != nil)
		[olControl1 setIntValue: (int) rint (slideyPosition + slideyBegin)];

	return self;
}

 - setRange: (float) begin: (float) end startAt: (float) start
{
	slideyBegin 	= begin;
	slideyEnd		= end;
	slideyPosition 	= start - slideyBegin;
	slideyRange 	= slideyEnd - slideyBegin;

	[self setRatio: slideyPosition / slideyRange];

	return self;
}

- takeFloatValueFrom: sender
{
	slideyPosition = [sender floatValue] - slideyBegin;

	if (slideyPosition > slideyRange)
		slideyPosition = slideyEnd - slideyBegin;
	else
		if (slideyPosition < slideyBegin)
			slideyPosition = slideyBegin;
	
	[sender setFloatValue: slideyPosition - slideyBegin];
	[self setRatio: slideyPosition / slideyRange];
	[self display];
	return self;
}

 @end
