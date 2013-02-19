
#import "Curve.h"

@implementation Curve

- initFrame: (const NXRect *) frameRect
{
	[super initFrame: frameRect];
	[self setNumPoints: MIN_POINTS];
	[self setHandleSize: DEFAULT_HANDLE_SIZE];
	[self setupDraw];

	Controls = &olControl0;

	return self;
}
 
/* Gets everything ready for drawing  */

- setupDraw
{
	int		i;
	NXPoint	point;
	NXRect	littleRect;		// Little box
 
	nSections = nNumPoints - 1;
	horizSectionSize =   ((bounds.size.width - 1) / (float) nSections); 
	vertSectionSize =   ((bounds.size.height - 1) / (float) nSections); 

	/*  Calculate the points  */

	nRectMidpoint = (nRectSize >> 1) + 1;
 	littleRect.size.width = littleRect.size.height = (float) nRectSize;

	littleRect.origin.x = 0;
 	littleRect.origin.y = 0;
	pRectangles [0] = littleRect;

	point.x = point.y = 0;
	handlePositions [0] 	= 0.0;
	pPoints [0] 		= point;
	
	for (i = 1; i < nNumPoints; i++)
	{
		littleRect.origin.x += horizSectionSize;
		littleRect.origin.y += vertSectionSize;
		pRectangles [i] = littleRect;			// Save away the rect
		pRectangles [i].origin.x -= (float) nRectMidpoint;
		pRectangles [i].origin.y -= (float) nRectMidpoint;

		point.x += horizSectionSize;
		point.y += vertSectionSize;
 		handlePositions [i] 	= (point.y - 1) / (bounds.size.height - HANDLEOFFSET - 1);
		pPoints [i] = point;				// Save away the point
	}

	return self;
}


- drawSelf: (const NXRect *) rects: (int) rectCount
{
	int		i;

	PSsetgray (NX_LTGRAY);
	NXRectFill (&bounds); 
 
	/*  First draw the (grid) lines  */

	if (! idGridImage)
	{
		
		/*  Have to draw them the slow way once  */

		PSsetgray (NX_WHITE);

		for (i = 0; i < (nNumPoints - 2); i++)
		{
			PSmoveto (0, ((i + 1) * vertSectionSize));
			PSlineto (bounds.size.width, ((i + 1) * vertSectionSize));
		}

		for (i = 0; i < (nNumPoints - 2); i++)
		{
			PSmoveto (((i + 1) * horizSectionSize), 0);
			PSlineto (((i + 1) * horizSectionSize), bounds.size.height);
		}
		PSstroke();
		idGridImage = [NXBitmapImageRep alloc];
		[idGridImage initData: NULL fromRect: &bounds];
	}
	
	[self doDraw];

	return self;
}

- doDraw
{
	int		i;

	PSsetlinewidth (0);
	PSsetgray (NX_LTGRAY);
	NXRectFill (&bounds); 
 
 	[idGridImage draw];

	/*  Now just draw the handles and lines */

	PSsetgray (NX_BLACK);

	PSmoveto (pPoints [0].x, pPoints [0].y);
	if (bIsDragged)
		NXFrameRectWithWidth (&pRectangles [0], 0);
	else
		NXRectFill (&pRectangles [0]);

	for (i = 1; i < nNumPoints; i++)
	{
		if (bIsDragged)
			NXFrameRectWithWidth (&pRectangles [i], 0);
		else
			NXRectFill (&pRectangles [i]);

		PSlineto (pPoints [i].x, pPoints [i].y);
	}

	PSstroke();


	NXFrameRect (&bounds);
	return self;
}



- setNumPoints: (int) numPoints 
{
	nNumPoints = numPoints;

	if (! pRectangles)
	{
		NX_MALLOC (pRectangles, NXRect, nNumPoints);
		NX_MALLOC (pPoints, NXPoint, nNumPoints);
		NX_MALLOC (handlePositions, float, nNumPoints);
	}
	else
	{
		NX_REALLOC (pRectangles, NXRect, nNumPoints);
		NX_REALLOC (pPoints, NXPoint, nNumPoints);
		NX_REALLOC (handlePositions, float, nNumPoints);
	}

	return self;
}

- mouseDown: (NXEvent *) theEvent
{
	int		count = 0;
	BOOL 	found = FALSE;
	NXPoint	*point;


	/*  Lets see if that mouse down is in any of our rectangles  */

	point = &theEvent -> location;
	hitPoint = *point;
	[self convertPoint: point fromView: nil];

	while (! found && count < nNumPoints)
	{
		if (NXMouseInRect (point, &pRectangles [count], NO))
		{
			found = TRUE;
			nSelectedRect = count;
		}
		else
			count++;
	}

	if (found)
	{
	    	[window addToEventMask: NX_LMOUSEDRAGGEDMASK];
		bIsDragged = YES;
		[self display];
	}

	return self;
}

- mouseDragged: (NXEvent *) theEvent
{
	NXPoint	*point = &pPoints [nSelectedRect];
	NXRect 	*rect = &pRectangles [nSelectedRect];
	float		deltaY; 
	NXPoint	testPoint;
	NXRect	testBounds;

	/*  First test for out of bounds  */

	testBounds = bounds;
	testBounds.size.height -= HANDLEOFFSET;
	testPoint = theEvent -> location;
	[self convertPoint: &testPoint fromView: nil];
	if (! [self mouse: &testPoint inRect: &testBounds])
		return self;
	
	[self lockFocus];

	deltaY = theEvent -> location.y - hitPoint.y;
	
	/*  (We don't care about deltaX in this control)  */

	rect -> origin.y += deltaY;
	point -> y += deltaY;

	[self doDraw];

	[self unlockFocus];		

	[window flushWindow];

	handlePositions [nSelectedRect] =
	(testPoint.y - 1) / (bounds.size.height - HANDLEOFFSET - 1);

	[self setFormattedValue: handlePositions [nSelectedRect] 
		forTextField: Controls [nSelectedRect]];

	hitPoint = theEvent -> location;

	[window setDocEdited: YES];

	return self;
}

- mouseUp: (NXEvent *) theEvent
{
    	[window removeFromEventMask: NX_LMOUSEDRAGGEDMASK];
	bIsDragged = NO;
	[self display];

	return self;
}

- free
{
	if (idGridImage)
		[idGridImage free];

	[super free];
	return self;
}


- setHandleSize: (int) size
{
	nRectSize = size;
	[self display];
	return self;
}

/*  Returns index of active rectangle - by default  */

- (int) selectedRect
{
	return nSelectedRect;
}


/*  Derived heavily from setupDraw.  Maybe they should be combined at some point... */

- setPoints: (float *) positions: (int) count
{	
	int		i;
	NXRect	littleRect;		// Little box
 
	/*  Set the points to the passed positions */

 	littleRect.size.width = littleRect.size.height = (float) nRectSize;
	littleRect.origin.x = littleRect.origin.y = 0.0;

	for (i = 0; i < count; i++)
	{
		littleRect.origin.y = (positions [i] * (bounds.size.height - HANDLEOFFSET - 1)) + 1;

		pRectangles [i] = littleRect;			// Save away the rect
		if (i > 0)
		{ 
			pRectangles [i].origin.x -= (float) nRectMidpoint;
 			pRectangles [i].origin.y -= (float) nRectMidpoint;
		}
 		handlePositions [i] 	= positions [i];
		pPoints [i] = littleRect.origin;

		[self setFormattedValue: handlePositions [i] forTextField: Controls [i]];
		littleRect.origin.x += horizSectionSize;
	}

	return self;
}

/*  Gets the points normalized 0..1  Caller responsible for allocating enough space  */

- getPoints: (float *) positions
{
	memcpy (positions, handlePositions, (nNumPoints * sizeof (float)));
	return self;
}

/*  Convert float to a nice display for our (private)  use  */

- setFormattedValue: (float) value forTextField: textField
{
	int	wholePart;
	int	fractionalPart;
	char	szBuffer [80];

	wholePart = (int) (value / 1.0);
	fractionalPart = (int) ((value - wholePart) * 100.0);

	sprintf (szBuffer, "%1d.%02d", wholePart, fractionalPart);
	[textField setStringValue: szBuffer];

	return self;
}



@end
