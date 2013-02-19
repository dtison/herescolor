
#import "/LocalLibrary/HERELibrary/Include/ProgressView.h"

@implementation ProgressView

- (BOOL) acceptsFirstResponder
{
	return NO;
}

- (BOOL) acceptsFirstMouse
{
	return NO;
}


/*  Designated Initializer this class */

- initFrame: (const NXRect *) frameRect
{
	[super initFrame: frameRect];
	total 	 = MAXSIZE;
	stepSize    = DEFAULTSTEPSIZE;
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
	PSsetgray (NX_DKGRAY);
	NXFrameRect (&bounds);
	return self;
}

- setStepSize: (int) value
{
	stepSize = value;
	return self;
}

- (int) stepSize
{
	return stepSize;
}

- setRatio: (float) newRatio
{
	if (newRatio > 1.0)
		newRatio = 1.0;
	if (ratio != newRatio) 
	{
		ratio = newRatio;
  		[self display];
		NXPing();
	}
	return self;
}

- increment: sender
{
	count += stepSize;
	[self setRatio: (float) count / (float) total];
	return self;
}

- setPercent: (float) percent
{
	[self setRatio: percent];
	return self;
}

- read: (NXTypedStream *) stream
{
	[super read: stream];
	NXReadTypes (stream, "ii", &total, &stepSize);
	return self;
}

- write: (NXTypedStream *) stream
{
	[super write: stream];
	NXWriteTypes (stream, "ii", &total, &stepSize);
	return self;
}


@end

