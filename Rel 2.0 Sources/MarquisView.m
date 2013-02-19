


#import <appkit/appkit.h>
#import "MarquisView.h"
#import "HEREdefs.h"
#import "HEREutils.h"
#import "ImageDocument.h"

#define NUMBER_POINTS  2000

void _TimerProc (DPSTimedEntry timedEntry, double timeNow, void *data);


@implementation MarquisView

- initFrame: (const NXRect *) frameRect
{	
	[super initFrame: frameRect];

	nAvailablePoints 	= NUMBER_POINTS;
	nTotalPoints 		= 0;
	fPattern [0] = 5;
	fPattern [1] = 5;
 	currTimedEntry = NULL;
	nOffset = 0;

	NX_MALLOC (pCurrentPoints, NXPoint, nAvailablePoints);	
	return self;
}


- mouseDown: (NXEvent *) theEvent
{
    	NXPoint mouseLocation;
	id spotToMove = nil;
	int	looping = YES,  oldMask;
	NXColor currColor;
	float	fGray;
	NXRect	cursorRect;	// Temporary bounds checking for drawing marquis
	float		currZoomFactor;
	char 	szBuffer [80];
	
	if (currTimedEntry)
	{
		DPSRemoveTimedEntry (currTimedEntry);
		currTimedEntry = NULL;
	}

	currZoomFactor = [[window delegate] getCurrentZoomFactor];
	currZoomFactor = 1.0 / currZoomFactor;


	[[window contentView] getFrame: &cursorRect];
	cursorRect.size.width -= 22;
	cursorRect.size.height -= 32;
	cursorRect.size.width /= currZoomFactor;
	cursorRect.size.height /= currZoomFactor;


	/*  TODO:  Realloc memory when run out of points  */
	/*  FUTURE:  Use a List of pPoints arrays for multiple masks  */

	if (nTotalPoints)
	{
		nTotalPoints = 0;
		nAvailablePoints = NUMBER_POINTS;
		[superview display];
		[window flushWindow];

	}	
	

	
	mouseLocation = theEvent -> location;

	/*  Normalize to actual image and store away  */


	[self convertPoint: &mouseLocation fromView: nil];
	[self lockFocus];

	PSgsave();

	PSsetlinewidth (0);

	#ifdef SMARTDRAWING
	currColor = NXReadPixel (&mouseLocation);
	NXConvertColorToGray (currColor, &fGray);
	fGray += .6;
	if (fGray > 1)
		fGray -= 1;
	PSsetgray (fGray);
	#endif

	PSnewpath();
	PSmoveto (mouseLocation.x, mouseLocation.y);


	mouseLocation.x = (float) rint (mouseLocation.x * currZoomFactor);
	mouseLocation.y = (float) rint (mouseLocation.y * currZoomFactor);

	pCurrentPoints [nTotalPoints] = mouseLocation;
	nAvailablePoints--;
	nTotalPoints++;

	
	oldMask = [window addToEventMask: NX_LMOUSEDRAGGEDMASK];
	do
	{
		theEvent = [NXApp getNextEvent: NX_MOUSEUPMASK | NX_MOUSEDRAGGEDMASK];

		mouseLocation = theEvent -> location;
		[self convertPoint: &mouseLocation fromView: nil];
		
		sprintf (szBuffer, "Screen: %d %d", (int) mouseLocation.x, (int) mouseLocation.y);
//		[[NXApp delegate] setScreenCoordinates: szBuffer];


		switch (theEvent -> type)
		{
			case NX_MOUSEDOWN:
													//	looping = NO;
				break;

			case NX_MOUSEUP:
				looping = NO;
				//   Now fall thru...

			case NX_MOUSEDRAGGED:
	
				if (! NXMouseInRect (&mouseLocation, &cursorRect, NO))
				{
						NXBeep();
						break;
				}

				PSlineto (mouseLocation.x, mouseLocation.y);
				PSstroke ();
 				PSmoveto (mouseLocation.x, mouseLocation.y);
				
				#ifdef SMARTDRAWING
				currColor = NXReadPixel (&mouseLocation);
				NXConvertColorToGray (currColor, &fGray);
				fGray += .6;
				if (fGray > 1)
					fGray -= 1;
				PSsetgray (fGray);
				#endif

				[window flushWindow];

				if (nAvailablePoints == 0)
					return self;	

				/*  Store points normalized in base image coordinates  */

				mouseLocation.x = (float) rint (mouseLocation.x * currZoomFactor);
				mouseLocation.y = (float) rint (mouseLocation.y * currZoomFactor);

		sprintf (szBuffer, "Normalized: %d %d", (int) mouseLocation.x, (int) mouseLocation.y);
//		[[NXApp delegate] setImageCoordinates: szBuffer];


				pCurrentPoints [nTotalPoints] = mouseLocation;
				nAvailablePoints--;
				nTotalPoints++;

				if (nTotalPoints > 1500)
					NXBeep();
	
				break;
		}
   	} while (looping);

	/*  Can't closepath because of moveto's above  */

	mouseLocation = pCurrentPoints [0];
	PSlineto (mouseLocation.x / currZoomFactor, mouseLocation.y / currZoomFactor);
	PSstroke ();

	[window flushWindow];
	PSgrestore();
	[self unlockFocus];
//	[self display];

	[window setEventMask: oldMask];

	currTimedEntry = DPSAddTimedEntry (0.111, &_TimerProc, self, NX_BASETHRESHOLD);

    	return self;
}

void _TimerProc (DPSTimedEntry timedEntry, double timeNow, void *data)
{
	[(id) data crawl];
}

- crawl
{
	NXPoint point;
	int i;
	float		currZoomFactor;

	currZoomFactor = [[window delegate] getCurrentZoomFactor];
	
	[self lockFocus];

	point = pCurrentPoints [0];

	/*  No convertPoint because points have already been converted and normalized  */

	point.x *= currZoomFactor;
	point.y *= currZoomFactor;

	PSnewpath();
	PSmoveto (point.x, point.y);	

	for (i = 1; i < nTotalPoints; i++)
	{
		point = pCurrentPoints [i];
		point.x *= currZoomFactor;
		point.y *= currZoomFactor;
		PSlineto (point.x, point.y);	
	}

	PSclosepath ();

 	PSsetgray (0);
 	PSsetdash (fPattern, 2, nOffset);
	PSgsave();
 	PSstroke();
	PSgrestore();	

	PSsetgray (1);
 	PSsetdash (fPattern, 2, 5 + nOffset);
 	PSstroke();

	nOffset++;
	if (nOffset > 9)
		nOffset = 0;


	[self unlockFocus];
	[window flushWindow];

	return self;
}

#if 0
- (BOOL) acceptsFirstResponder
{
    return YES;
}
- (BOOL) acceptsFirstMouse
{
    return YES;
}
#endif




- drawSelf: (const NXRect *) rects: (int) rectCount
{
	NXPoint point;
	int 	i;
	char	 szBuffer [90];
	float		currZoomFactor;

	if (nTotalPoints == 0)
		return self;

	currZoomFactor = [[window delegate] getCurrentZoomFactor];


	/*  Play back the points  */
	/*  TODO:  Setup a user path or something to make things go faster  */

	PSsetrgbcolor (0, 0, 0);

	point = pCurrentPoints [0];

	/*  No convertPoint because points have already been converted and normalized  */

	point.x *= currZoomFactor;
	point.y *= currZoomFactor;

	PSnewpath();
	PSmoveto (point.x, point.y);	

	for (i = 1; i < nTotalPoints; i++)
	{
		point = pCurrentPoints [i];
		point.x *= currZoomFactor;
		point.y *= currZoomFactor;
		PSlineto (point.x, point.y);	
	}

	PSclosepath ();
	PSsetgray (0);
	PSstroke();
	return self;
}

/*  Fills in specified rectangle with values that surround current selection  */

- getBoundingBox: (NXRect *) aRect
{
	NXPoint point;
	int 	i;
	float llx, lly, urx, ury;

	/*  (For now, free-form marquis)  */

	if (nTotalPoints == 0)
	{
		NXRect aBounds;

		[superview getBounds: &aBounds];	// (superview = ImageView = size of image)
		*aRect = aBounds;
		return self;
	}

	/*  Play back the points  */
	/*  TODO:  Setup a user path or something to make things go faster  */

	[self lockFocus];
	PSgsave();
	point = pCurrentPoints [0];
	PSmoveto (point.x, point.y);	

	for (i = 1; i < nTotalPoints; i++)
	{
		point = pCurrentPoints [i];
		PSlineto (point.x, point.y);	
	}
	
 	PSclosepath();
	PSpathbbox (&llx, &lly, &urx, &ury);
	aRect -> origin.x 	= llx; 
	aRect -> origin.y 	= lly;
 	aRect -> size.width 	= urx - llx + 1;
	aRect -> size.height = ury - lly + 1;

	#define SHOWBOX

	#ifdef SHOWBOX
	{
		PSsetgray (.5);
		PSmoveto (aRect -> origin.x, aRect -> origin.y);
		PSrlineto (0, aRect -> size.height);
		PSrlineto (aRect -> size.width, 0);
		PSrlineto (0, -aRect -> size.height);
		PSclosepath();
		PSstroke();
		[self display];
	}
	#endif

	PSgrestore();
	[self unlockFocus];

	return self;
}

- (NXPoint *) getSelectionPoints: (int *) count
{
	NXPoint *points;

	if (count)
		*count = nTotalPoints;
	else
		return NULL;
	
	/*  Allocate a copy.  It is the responsibility of the client to free this  */

	NX_MALLOC (points, NXPoint, nTotalPoints);
	memcpy (points, pCurrentPoints, (nTotalPoints * sizeof (NXPoint)));

	return points;
}




@end